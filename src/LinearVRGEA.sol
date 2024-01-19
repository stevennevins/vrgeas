// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {VRGEA} from "src/VRGEA.sol";
import {unsafeWadDiv} from "solmate/utils/SignedWadMath.sol";

abstract contract LinearVRGEA is VRGEA {
    int256 public immutable perTimeUnit;

    constructor(
        uint256 _startTime,
        uint256 _reservePrice,
        uint256 _minBidIncrease,
        int256 _perTimeUnit
    ) VRGEA(_startTime, _minBidIncrease, _reservePrice) {
        perTimeUnit = _perTimeUnit;
    }

    function getTargetSaleTime(int256 sold) public view virtual override returns (int256) {
        return unsafeWadDiv(sold, perTimeUnit);
    }
}
