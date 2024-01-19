// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {VRGEA} from "src/VRGEA.sol";
import {unsafeWadDiv} from "solmate/utils/SignedWadMath.sol";

/// @title ConstantVRGEA - Constant Rate Gradual English Auction
/// @notice This contract extends VRGEA with a constant target sale time for the auction regardless of the amount sold.
abstract contract ConstantVRGEA is VRGEA {
    /// @notice The fixed duration for the auction in dayWads (fixed-point representation of days).
    int256 public duration;

    /// @dev Initializes a ConstantVRGEA contract with specified parameters.
    /// @param _startTime The start time of the auction.
    /// @param _reservePrice The reserve price for the auction.
    /// @param _minBidIncrease The percentage by which a new bid must exceed the previous bid.
    /// @param _duration The constant duration of the auction in dayWads.
    constructor(
        uint256 _startTime,
        uint256 _reservePrice,
        uint256 _minBidIncrease,
        int256 _duration
    ) VRGEA(_startTime, _minBidIncrease, _reservePrice) {
        duration = _duration;
    }

    /// @notice Returns the constant target sale time for the auction.
    /// @dev Overrides the getTargetSaleTime function from the VRGEA contract to provide a constant target sale time.
    /// @param numSold The number of items sold, which is not used in this constant implementation.
    /// @return The constant target sale time for the auction.
    function getTargetSaleTime(int256 /* numSold */) public view virtual override returns (int256) {
        return duration;
    }
}
