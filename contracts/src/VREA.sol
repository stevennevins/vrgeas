// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {toDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";

abstract contract VREA {
    uint256 public immutable reservePrice;
    uint256 public immutable minBidIncrease;
    uint256 public immutable maxSortedBidders = 10_000;

    uint256 public totalSold;
    uint256 public startTime = block.timestamp;

    constructor(uint256 _reservePrice, uint256 _minBidIncrease) {
        reservePrice = _reservePrice;
        minBidIncrease = _minBidIncrease;
    }

    function getTargetSaleTime(
        int256 sold
    ) public view virtual returns (int256);

    function _getFillableQuantity() internal view returns (uint256 quantity) {
        int256 timeSinceStart = toDaysWadUnsafe(block.timestamp - startTime);
        while (
            getTargetSaleTime(int256(totalSold + quantity)) < timeSinceStart
        ) {
            quantity++;
        }
    }
}
