// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {VRGEA} from "src/VRGEA.sol";
import {unsafeWadDiv} from "solmate/utils/SignedWadMath.sol";

abstract contract LinearVRGEA is VRGEA {
    int256 internal immutable perTimeUnit;

    constructor(
        uint256 _reservePrice,
        uint256 _minBidIncrease,
        int256 _perTimeUnit
    ) VRGEA(_reservePrice, _minBidIncrease) {
        perTimeUnit = _perTimeUnit;
    }

    function getTargetSaleTime(
        int256 sold
    ) public view virtual override returns (int256) {
        return unsafeWadDiv(sold, perTimeUnit);
    }
}
