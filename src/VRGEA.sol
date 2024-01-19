// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {toDaysWadUnsafe, toWadUnsafe, fromDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";
import {LinkedBidsListLib, LinkedBidsList, Bid} from "src/lib/LinkedBidsListLib.sol";

/// @title VRGEA - Variable Rate Gradual English Auction
abstract contract VRGEA {
    using LinkedBidsListLib for LinkedBidsList;

    /// @notice The price that a bid must meet or exceed
    uint256 public reservePrice;
    /// @notice The timestamp when the auction starts
    uint256 public startTime;

    /// @notice The data structure containing all the bids
    LinkedBidsList public bidQueue;

    /// @notice The total quantity of items sold in the auction
    uint256 public totalSold;

    /// @notice The cumulative time extended during the auction
    uint256 public extendedTime;

    /// @param _startTime The start time of the auction
    /// @param _minBidIncrease The percent increase required to replace bids
    /// @param _reservePrice The reserve price for the auction
    constructor(uint256 _startTime, uint256 _minBidIncrease, uint256 _reservePrice) {
        bidQueue.minBidIncrease = _minBidIncrease;
        reservePrice = _reservePrice;
        startTime = _startTime;
    }

    /// @notice Allows participants to place a bid with a specified quantity and value
    /// @param quantity The number of items the bidder requests
    /// @param valuePerUnit The value of the bid
    function bid(uint8 quantity, uint256 valuePerUnit) external payable virtual;

    /// @notice Allows participants to withdraw their bids
    function withdraw() external virtual;

    /// @notice Calculates the target sale time based on the quantity sold
    /// @param sold The quantity of items sold
    /// @return The target sale time as an integer value
    function getTargetSaleTime(int256 sold) public view virtual returns (int256);

    /// @notice Gets the fillable quantity based on the elapsed time since the prior settlement
    /// @return The fillable quantity as an unsigned integer
    function getFillableQuantity() public view returns (uint256) {
        return _getFillableQuantity(startTime);
    }

    /// @dev Inserts a bid into the bid queue and fills pending fillable bids
    /// @param bidder The address of the bidder
    /// @param unitPrice The price per unit of the bid
    /// @param quantity The quantity of units bid for
    function _insertBid(address bidder, uint88 unitPrice, uint8 quantity) internal {
        require(quantity != 0, "Bid 0 Amount");
        require(unitPrice >= reservePrice, "Bid too low");
        _processFillableBids();
        bidQueue.insert(bidder, quantity, unitPrice);
    }

    /// @dev Processes fillable bids and removes the bidder from the bid queue
    /// @param bidder The account removed from the bid queue
    /// @return bidAmount The total value of the bid removed
    function _removeBid(address bidder) internal returns (uint256 bidAmount) {
        _processFillableBids();
        Bid memory bidInfo = bidQueue.bids[bidder];
        bidAmount = bidInfo.quantity * bidInfo.unitPrice;
        bidQueue.remove(bidder, bidInfo.quantity);
    }

    /// @dev Processes all fillable bids based on the current time
    function _processFillableBids() internal {
        uint256 quantity = _getFillableQuantity(startTime);
        Bid memory bidInfo = bidQueue.bids[bidQueue.highestBidder];
        totalSold += quantity;

        // remove bidders from the bidQueue while we have remaining quantity
        while (quantity > 0) {
            if (bidInfo.quantity == 0) {
                // if we run out of bidders in the queue extend the auction
                int256 extensionWad = getTargetSaleTime(toWadUnsafe(totalSold)) -
                    getTargetSaleTime(toWadUnsafe(totalSold - quantity));
                extendedTime += fromDaysWadUnsafe(extensionWad);
                totalSold -= quantity;
                quantity = 0;
            } else if (bidInfo.quantity > quantity) {
                // if the highestBidder has more quantity than we are trying to settle
                bidQueue.remove(bidQueue.highestBidder, quantity);
                quantity = 0;
            } else {
                // if the highestBidder had less quantity than we were trying to settle
                quantity -= bidInfo.quantity;
                bidQueue.remove(bidQueue.highestBidder, bidInfo.quantity);
                bidInfo = bidQueue.bids[bidQueue.highestBidder];
            }
        }
    }

    /// @dev Calculates the fillable quantity of items based on the auction's start time
    /// @param _startTime The auction's start time
    /// @return quantity The fillable quantity based on the start time
    function _getFillableQuantity(uint256 _startTime) internal view returns (uint256) {
        uint256 quantity;
        int256 timeSinceStart = toDaysWadUnsafe(block.timestamp - _startTime - extendedTime);

        while (getTargetSaleTime(toWadUnsafe(totalSold + quantity + 1)) <= timeSinceStart) {
            quantity++;
        }
        return quantity;
    }
}
