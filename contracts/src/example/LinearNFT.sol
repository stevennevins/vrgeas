// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC721} from 'solmate/tokens/ERC721.sol';
import {SafeTransferLib} from 'solmate/utils/SafeTransferLib.sol';

import {toDaysWadUnsafe} from 'solmate/utils/SignedWadMath.sol';

import {LinearVREA} from 'src/LinearVREA.sol';

contract LinearNFT is ERC721, LinearVREA {
    constructor() ERC721('NFT', 'LINEAR') LinearVREA(69.42e18, 0.31e18, 2e18) {}

    function bid(uint256 amount) external payable {}

    function tokenURI(uint256) public pure override returns (string memory) {
        return '';
    }
}
