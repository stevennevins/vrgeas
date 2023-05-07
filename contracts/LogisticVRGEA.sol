// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {VRGEA} from "src/VRGEA.sol";
import {wadLn, unsafeDiv, unsafeWadDiv} from "solmate/utils/SignedWadMath.sol";

abstract contract LogisiticVRGEA is VRGEA {
    /// @dev The maximum number of tokens of tokens to sell + 1. We add
    /// 1 because the logistic function will never fully reach its limit.
    /// @dev Represented as an 18 decimal fixed point number.
    int256 internal immutable logisticLimit;

    /// @dev The maximum number of tokens of tokens to sell + 1 multiplied
    /// by 2. We could compute it on the fly each time but this saves gas.
    /// @dev Represented as a 36 decimal fixed point number.
    int256 internal immutable logisticLimitDoubled;

    /// @dev Time scale controls the steepness of the logistic curve,
    /// which affects how quickly we will reach the curve's asymptote.
    /// @dev Represented as an 18 decimal fixed point number.
    int256 internal immutable timeScale;

    constructor(
        uint256 _startTime,
        uint256 _minBidIncrease,
        uint256 _reservePrice,
        int256 _maxSellable,
        int256 _timeScale
    ) VRGEA(_startTime, _minBidIncrease, _reservePrice) {
        // Add 1 wad to make the limit inclusive of _maxSellable.
        logisticLimit = _maxSellable + 1e18;

        // Scale by 2e18 to both double it and give it 36 decimals.
        logisticLimitDoubled = logisticLimit * 2e18;

        timeScale = _timeScale;
    }

    function getTargetSaleTime(
        int256 sold
    ) public view virtual override returns (int256) {
        unchecked {
            return
                -unsafeWadDiv(
                    wadLn(
                        unsafeDiv(logisticLimitDoubled, sold + logisticLimit) -
                            1e18
                    ),
                    timeScale
                );
        }
    }
}
