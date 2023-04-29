// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {VREA} from 'src/VREA.sol';
import {unsafeWadDiv} from 'solmate/utils/SignedWadMath.sol';

abstract contract LinearVREA is VREA {
    int256 internal immutable perTimeUnit;

    constructor(
        uint256 _reservePrice,
        uint256 _minBidIncrease,
        int256 _perTimeUnit
    ) VREA(_reservePrice, _minBidIncrease) {
        perTimeUnit = _perTimeUnit;
    }

    function getTargetSaleTime(
        int256 sold
    ) public view virtual override returns (int256) {
        return unsafeWadDiv(sold, perTimeUnit);
    }
}
