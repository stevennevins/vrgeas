// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

struct Bid {
    uint8 quantity;
    uint88 unitPrice;
    address nextBidder;
}

struct LinkedBidsList {
    /// key unitPrice mapping of bidder addresses to their corresponding bids
    mapping(address => Bid) bids;
    address highestBidder;
}

library LinkedBidsListLib {
    function insert(
        LinkedBidsList storage self,
        address bidder,
        uint8 quantity,
        uint88 unitPrice
    ) internal {
        if (self.highestBidder == address(0)) {
            /// if empty
            self.bids[bidder] = Bid(quantity, unitPrice, address(0));
            self.highestBidder = bidder;
        } else {
            address currentBidder = self.highestBidder;
            Bid storage currentBid = self.bids[currentBidder];
            while (true) {
                if (unitPrice > self.bids[currentBid.nextBidder].unitPrice) break;
                currentBidder = currentBid.nextBidder;
                currentBid = self.bids[currentBidder];
            }
            if (currentBidder == self.highestBidder) {
                self.highestBidder = bidder;
                self.bids[bidder] = Bid(quantity, unitPrice, currentBidder);
            } else {
                self.bids[bidder] = Bid(quantity, unitPrice, currentBid.nextBidder);
                currentBid.nextBidder = bidder;
            }
        }
    }

    function remove(LinkedBidsList storage self, address bidder) internal {
        require(self.highestBidder != address(0), "LinkedBidsList is empty");
        require(self.bids[bidder].quantity > 0, "Bid does not exist");
        if (bidder == self.highestBidder) {
            self.highestBidder = self.bids[self.highestBidder].nextBidder; // update the highestBidder to point to the nextBidder
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
