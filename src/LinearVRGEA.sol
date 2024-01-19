// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRGEA} from "src/VRGEA.sol";
import {unsafeWadDiv} from "solmate/utils/SignedWadMath.sol";

/// @title LinearVRGEA - Linear Variable Rate Gradual English Auction
/// @notice This contract extends the VRGEA contract with a linear pricing function that defines the rate at which items are available for sale
abstract contract LinearVRGEA is VRGEA {
    int256 public perTimeUnit;

    constructor(
        uint256 _startTime,
        uint256 _reservePrice,
        uint256 _minBidIncrease,
        int256 _perTimeUnit
    ) VRGEA(_startTime, _minBidIncrease, _reservePrice) {
        perTimeUnit = _perTimeUnit;
    }

    /// @notice Calculates the target sale time based on the amount sold using a linear formula.
    /// @dev Overrides the getTargetSaleTime function from the VRGEA contract with a linear sale supply schedule.
    /// @param sold The cumulative amount sold in the auction.
    /// @return The target sale time based on the linear pricing function.
    function getTargetSaleTime(int256 sold) public view virtual override returns (int256) {
        return unsafeWadDiv(sold, perTimeUnit);
    }
}
