// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {toDaysWadUnsafe, toWadUnsafe, fromDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";
import {LinkedBidsListLib, LinkedBidsList, Bid} from "contracts/lib/LinkedBidsListLib.sol";

abstract contract VRGEA {
    using LinkedBidsListLib for LinkedBidsList;
    uint256 public immutable reservePrice;
    uint256 public immutable startTime;

    LinkedBidsList public bidQueue;
    uint256 public totalSold;
    uint256 public extendedTime;

    constructor(
        uint256 _startTime,
        uint256 _minBidIncrease,
        uint256 _reservePrice
    ) {
        bidQueue.minBidIncrease = _minBidIncrease;
        reservePrice = _reservePrice;
        startTime = _startTime;
    }

    function bid(uint8 quantity, uint256 value) external payable virtual;

    function withdraw() external virtual;

    function getTargetSaleTime(
        int256 sold
    ) public view virtual returns (int256);

    function getFillableQuantity() public view returns (uint256) {
        return _getFillableQuantity(startTime);
    }

    function _insertBid(
        address bidder,
        uint88 unitPrice,
        uint8 quantity
    ) internal {
        require(unitPrice >= reservePrice, "Bid too low");
        _processFillableBids();
        bidQueue.insert(bidder, quantity, unitPrice);
    }

    function _removeBid(address bidder) internal returns (uint256 bidAmount) {
        _processFillableBids();
        Bid memory bidInfo = bidQueue.bids[bidder];
        bidAmount = bidInfo.quantity * bidInfo.unitPrice;
        bidQueue.remove(bidder, bidInfo.quantity);
    }

    function _processFillableBids() internal {
        uint256 quantity = _getFillableQuantity(startTime);
        Bid memory bidInfo = bidQueue.bids[bidQueue.highestBidder];
        totalSold += quantity;

        /// pull from queue while we have remaining quantity
        while (quantity > 0) {
            if (bidInfo.quantity == 0) {
                /// if we run out of bidders in the queue extend the auction
                int256 extensionWad = getTargetSaleTime(
                    toWadUnsafe(totalSold)
                ) - getTargetSaleTime(toWadUnsafe(totalSold - quantity));
                extendedTime += fromDaysWadUnsafe(extensionWad);
                totalSold -= quantity;
                quantity = 0;
            } else if (bidInfo.quantity > quantity) {
                /// if the highestBidder has more quantity than we are trying to settle
                bidQueue.remove(bidQueue.highestBidder, quantity);
                quantity = 0;
            } else {
                /// if the highestBidder had less quantity than we were trying to settle
                quantity -= bidInfo.quantity;
                bidQueue.remove(bidQueue.highestBidder, bidInfo.quantity);
                bidInfo = bidQueue.bids[bidQueue.highestBidder];
            }
        }
    }

    function _getFillableQuantity(
        uint256 _startTime
    ) internal view returns (uint256 quantity) {
        int256 timeSinceStart = toDaysWadUnsafe(
            block.timestamp - _startTime - extendedTime
        );

        while (
            getTargetSaleTime(toWadUnsafe(totalSold + quantity + 1)) <=
            timeSinceStart
        ) {
            quantity++;
        }
    }
}
