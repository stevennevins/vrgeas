// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

struct Bid {
    uint8 quantity;
    uint88 unitPrice;
    address nextBidder;
}

struct LinkedBidsList {
    mapping(address bidder => Bid bidInfo) bids;
    address highestBidder;
    uint256 minBidIncrease;
}

library LinkedBidsListLib {
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

    function remove(LinkedBidsList storage self, address bidder, uint256 quantity) internal {
        require(self.highestBidder != address(0), "LinkedBidsList is empty");
        require(self.bids[bidder].quantity > 0, "Bid does not exist");
        require(self.bids[bidder].quantity >= quantity, "Quantity to high");

        if (self.bids[bidder].quantity > quantity) {
            self.bids[bidder].quantity -= uint8(quantity);
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

    function calculateMinIncrease(LinkedBidsList storage self, uint256 rightBidPrice) internal view returns (uint256) {
        return (rightBidPrice * (self.minBidIncrease + 10_000)) / 10_000;
    }
}
