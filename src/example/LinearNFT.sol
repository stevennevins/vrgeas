// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {SafeCastLib} from "solmate/utils/SafeCastLib.sol";
import {toDaysWadUnsafe, toWadUnsafe, fromDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";
import {LinkedBidsListLib, LinkedBidsList, Bid} from "src/lib/LinkedBidsListLib.sol";

import {LinearVRGEA} from "src/LinearVRGEA.sol";

contract LinearNFT is ERC721, LinearVRGEA {
    using SafeCastLib for uint256;
    using SafeTransferLib for address;
    using LinkedBidsListLib for LinkedBidsList;

    constructor()
        ERC721("NFT", "LINEAR")
        LinearVRGEA(block.timestamp, 1e18, 0.31e18, 1e18)
    {}

    function bid(uint8 amount) external payable {
        require(amount > 0, "Amount 0");
        uint256 unitPrice = msg.value / amount;
        _insertBid(unitPrice.safeCastTo88(), amount);
    }

    function removeBid() external {
        uint256 refund = _removeBid(msg.sender);
        msg.sender.safeTransferETH(refund);
    }

    function tokenURI(uint256) public pure override returns (string memory) {
        return "";
    }
}
