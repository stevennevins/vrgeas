// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {LinkedBidsListLib, LinkedBidsList, Bid} from "src/lib/LinkedBidListLib.sol";

contract LinkedListTest is Test {
    using LinkedBidsListLib for LinkedBidsList;

    LinkedBidsList public list;

    address public bidder1 = address(1);
    address public bidder2 = address(2);
    address public bidder3 = address(3);
    address public bidder4 = address(4);

    function setUp() public {}

    function test_WhenEmpty_Insert() public {
        uint8 quantity = 1;
        uint88 unitPrice = 1;
        list.insert(bidder2, quantity, unitPrice);

        assertEq(list.highestBidder, bidder2, "highestBidder");
        assertEq(list.bids[bidder2].quantity, 1);
        assertEq(list.bids[bidder2].unitPrice, 1);
    }

    function test_RevertsWhenEmpty_Remove() public {
        vm.expectRevert("LinkedBidsList is empty");
        list.remove(bidder2);
    }

    function test_Remove() public {
        test_WhenEmpty_Insert();

        list.remove(bidder2);

        assertEq(list.highestBidder, address(0), "highestBidder");
    }

    function test_RevertsWhenBidderDoesntExist_Remove() public {
        test_WhenEmpty_Insert();

        vm.expectRevert("Bid does not exist");
        list.remove(bidder1);

        assertEq(list.highestBidder, address(0), "highestBidder");
        assertEq(list.bids[bidder2].quantity, 0);
        assertEq(list.bids[bidder2].unitPrice, 0);
    }

    function test_WhenInOrderMany_Insert() public {
        list.insert(bidder1, 1, 1);
        list.insert(bidder2, 1, 2);
        list.insert(bidder3, 1, 3);

        assertEq(list.highestBidder, bidder3, "highestBidder");
        assertEq(list.bids[bidder1].quantity, 1);
        assertEq(list.bids[bidder1].unitPrice, 1);
        assertEq(
            list.bids[bidder1].nextBidder,
            address(0),
            "nextBidder bidder1"
        );
        assertEq(list.bids[bidder2].quantity, 1);
        assertEq(list.bids[bidder2].unitPrice, 2);
        assertEq(list.bids[bidder2].nextBidder, bidder1, "nextBidder bidder 2");
        assertEq(list.bids[bidder3].quantity, 1);
        assertEq(list.bids[bidder3].unitPrice, 3);
        assertEq(list.bids[bidder3].nextBidder, bidder2, "nextBidder bidder 3");
    }

    function test_WhenOutOfOrderMany_Insert() public {
        list.insert(bidder2, 1, 2);
        list.insert(bidder1, 1, 1);
        list.insert(bidder3, 1, 3);

        assertEq(list.highestBidder, bidder3, "highestBidder");
        assertEq(list.bids[bidder1].quantity, 1);
        assertEq(list.bids[bidder1].unitPrice, 1);
        assertEq(list.bids[bidder2].quantity, 1);
        assertEq(list.bids[bidder2].unitPrice, 2);
        assertEq(list.bids[bidder3].quantity, 1);
        assertEq(list.bids[bidder3].unitPrice, 3);
    }

    function test_WhenRemoveTail_Remove() public {
        list.insert(bidder1, 1, 1);
        list.insert(bidder2, 1, 2);
        list.insert(bidder3, 1, 3);

        assertEq(list.highestBidder, bidder3, "highestBidder");
        list.remove(bidder1);

        assertEq(list.highestBidder, bidder3, "highestBidder");
        assertEq(list.bids[bidder1].quantity, 0);
        assertEq(list.bids[bidder1].unitPrice, 0);
        assertEq(list.bids[bidder2].quantity, 1);
        assertEq(list.bids[bidder2].unitPrice, 2);
        assertEq(list.bids[bidder3].quantity, 1);
        assertEq(list.bids[bidder3].unitPrice, 3);
    }

    function test_WhenRemovehighestBidder_Remove() public {
        list.insert(bidder1, 1, 1);
        list.insert(bidder2, 1, 2);
        list.insert(bidder3, 1, 3);
        assertEq(list.highestBidder, bidder3, "before highestBidder");
        assertEq(list.bids[bidder3].nextBidder, bidder2, "nextBidder");

        list.remove(bidder3);

        assertEq(list.highestBidder, bidder2, "after highestBidder");
        assertEq(list.bids[bidder1].quantity, 1);
        assertEq(list.bids[bidder1].unitPrice, 1);
        assertEq(list.bids[bidder2].quantity, 1);
        assertEq(list.bids[bidder2].unitPrice, 2);
        assertEq(list.bids[bidder3].quantity, 0);
        assertEq(list.bids[bidder3].unitPrice, 0);
    }

    function test_WhenRemoveInner_Remove() public {
        list.insert(bidder1, 1, 1);
        list.insert(bidder2, 1, 2);
        list.insert(bidder3, 1, 3);
        list.remove(bidder2);

        assertEq(list.highestBidder, bidder3, "highestBidder");
        assertEq(list.bids[bidder1].quantity, 1);
        assertEq(list.bids[bidder1].unitPrice, 1);
        assertEq(list.bids[bidder2].quantity, 0);
        assertEq(list.bids[bidder2].unitPrice, 0);
        assertEq(list.bids[bidder3].quantity, 1);
        assertEq(list.bids[bidder3].unitPrice, 3);
    }
}
