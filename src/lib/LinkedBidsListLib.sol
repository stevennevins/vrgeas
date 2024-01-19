// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {SafeCastLib} from "solmate/utils/SafeCastLib.sol";

struct Bid {
    uint8 quantity;
    uint88 unitPrice;
    address nextBidder;
}

struct LinkedBidsList {
    mapping(address => Bid) bids;
    address highestBidder;
    uint256 minBidIncrease;
}

/// @title A library for managing a linked list of bids.
library LinkedBidsListLib {
    /// @notice Inserts a new bid into the linked list.
    /// @dev The bid list is ordered based on the unit price.
    /// @param self The linked list to operate on.
    /// @param bidder The address of the bidder.
    /// @param quantity The quantity of items the bidder commits to purchase.
    /// @param unitPrice The price per unit of the bid.
    function insert(LinkedBidsList storage self, address bidder, uint8 quantity, uint88 unitPrice) internal {
        require(quantity > 0, "Quantity > 0");
        require(unitPrice > 0, "Price > 0");
        address leftBidder;
        address rightBidder = self.highestBidder;
        Bid storage rightNode = self.bids[rightBidder];
        while (rightNode.unitPrice >= unitPrice) {
            (leftBidder, rightBidder) = (rightBidder, rightNode.nextBidder);
            rightNode = self.bids[rightBidder];
        }

        require(unitPrice >= calculateMinIncrease(self, rightNode.unitPrice), "Invalid Bid");
        if (self.highestBidder == rightBidder) self.highestBidder = bidder;
        self.bids[bidder] = Bid(quantity, unitPrice, rightBidder);
        self.bids[leftBidder].nextBidder = bidder;
    }

    /// @notice Removes a specified quantity from a bid in the linked list.
    /// @dev If the quantity to remove equals the quantity of the bid, the bid is deleted.
    /// @param self The linked list to operate on.
    /// @param bidder The address of the bidder whose bid to remove quantity from.
    /// @param quantity The quantity to remove from the bid.
    function remove(LinkedBidsList storage self, address bidder, uint256 quantity) internal {
        require(self.highestBidder != address(0), "LinkedBidsList is empty");
        require(self.bids[bidder].quantity > 0, "Bid does not exist");
        require(self.bids[bidder].quantity >= quantity, "Quantity too high");

        if (self.bids[bidder].quantity > quantity) {
            self.bids[bidder].quantity -= SafeCastLib.safeCastTo8(quantity);
        } else {
            if (bidder == self.highestBidder) {
                // update the highestBidder to point to the nextBidder
                self.highestBidder = self.bids[self.highestBidder].nextBidder;
            } else {
                address currentBidder = self.highestBidder;
                while (self.bids[currentBidder].nextBidder != bidder) {
                    currentBidder = self.bids[currentBidder].nextBidder;
                }
                self.bids[currentBidder].nextBidder = self.bids[bidder].nextBidder;
            }
            delete self.bids[bidder]; // delete the currentBid from the mapping
        }
    }

    /// @notice Calculates the bid to replace rightBid
    /// @param self The linked list to operate on.
    /// @param rightBidPrice The price of the bid to calculate the increase over.
    /// @return The increase required over the right bid price.
    function calculateMinIncrease(LinkedBidsList storage self, uint256 rightBidPrice) internal view returns (uint256) {
        return (rightBidPrice * (self.minBidIncrease + 10_000)) / 10_000;
    }
}
