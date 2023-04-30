// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {toDaysWadUnsafe, toWadUnsafe} from "solmate/utils/SignedWadMath.sol";
import {LinkedBidsListLib, LinkedBidsList, Bid} from "src/lib/LinkedBidsListLib.sol";

abstract contract VRGEA {
    using LinkedBidsListLib for LinkedBidsList;
    uint256 public immutable reservePrice;
    uint256 public immutable minBidIncrease;
    uint256 public immutable startTime;

    LinkedBidsList public bidQueue;
    uint256 public totalSold;
    uint256 public extendedTime;

    constructor(
        uint256 _startTime,
        uint256 _minBidIncrease,
        uint256 _reservePrice
    ) {
        reservePrice = _reservePrice;
        minBidIncrease = _minBidIncrease;
        startTime = _startTime;
    }

    function getTargetSaleTime(
        int256 sold
    ) public view virtual returns (int256);

    function getFillableQuantity() public view returns (uint256) {
        return _getFillableQuantity(startTime);
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
