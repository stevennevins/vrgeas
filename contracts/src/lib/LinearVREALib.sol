// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {toWadUnsafe, wadExp, wadLn, unsafeWadMul, unsafeWadDiv, wadMul, toDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";
import {LinearVREAInfo as LVREAInfo} from "src/interfaces/ILinearVREA.sol";

library LibLinearVRGDA {
    function toHash(LVREAInfo calldata self) public pure returns (bytes32) {
        return keccak256(abi.encode(self));
    }

    /// @dev Given a number of tokens sold, return the target time that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale time for.
    /// @param perTimeUnit The number of tokens to target selling in 1 full unit of time, scaled by 1e18.
    /// @return The target time the tokens should be sold by, scaled by 1e18, where the time is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getTargetSaleTime(
        int256 sold,
        int256 perTimeUnit
    ) public pure returns (int256) {
        return unsafeWadDiv(sold, perTimeUnit);
    }
}
