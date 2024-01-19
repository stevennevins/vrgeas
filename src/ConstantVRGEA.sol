// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {VRGEA} from "src/VRGEA.sol";
import {unsafeWadDiv} from "solmate/utils/SignedWadMath.sol";

abstract contract ConstantVRGEA is VRGEA {
    int256 public immutable duration;

    /// @dev _duration must be in dayWads
    constructor(
        uint256 _startTime,
        uint256 _reservePrice,
        uint256 _minBidIncrease,
        int256 _duration
    ) VRGEA(_startTime, _minBidIncrease, _reservePrice) {
        duration = _duration;
    }

    function getTargetSaleTime(int256 /* numSold */) public view virtual override returns (int256) {
        return duration;
    }
}
