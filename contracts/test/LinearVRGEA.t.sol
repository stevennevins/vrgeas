// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {toDaysWadUnsafe, toWadUnsafe} from "solmate/utils/SignedWadMath.sol";
import {LinearNFT} from "src/example/LinearNFT.sol";

contract LinearVRGEATest is Test {
    uint256 public WAD = 10 ** 18;
    LinearNFT public vrgea;

    address public bidder1 = address(1);
    address public bidder2 = address(2);
    address public bidder3 = address(3);
    address public bidder4 = address(4);

    function setUp() public {
        vm.deal(bidder1, 100 ether);
        vm.deal(bidder2, 100 ether);
        vm.deal(bidder3, 100 ether);
        vm.deal(bidder4, 100 ether);
        vrgea = new LinearNFT();
    }

    function test_Bid() public {
        uint256 reservePrice = vrgea.reservePrice();
        vm.prank(bidder1);
        vrgea.bid{value: reservePrice}(1);
        assertEq(bidder1.balance, 99 ether);
        assertEq(address(vrgea).balance, 1 ether);
    }

    function test_24Hours_Bid() public {
        vm.warp(block.timestamp + 1 days);
        uint256 reservePrice = vrgea.reservePrice();
        vm.prank(bidder1);
        vrgea.bid{value: reservePrice}(1);
        assertEq(bidder1.balance, 99 ether);
        assertEq(address(vrgea).balance, 1 ether);
    }

    function test_RevertsWhenUnderReserve_Bid() public {
        uint256 reservePrice = vrgea.reservePrice();
        vm.expectRevert("Bid too low");
        vm.prank(bidder1);
        vrgea.bid{value: reservePrice - 1}(1);
    }

    function test_RevertsWhenQuantity0_Bid() public {
        uint256 reservePrice = vrgea.reservePrice();
        vm.expectRevert("Amount 0");
        vm.prank(bidder1);
        vrgea.bid{value: reservePrice}(0);
    }

    function test_RemoveBid() public {
        uint256 reservePrice = vrgea.reservePrice();
        vm.prank(bidder1);
        vrgea.bid{value: reservePrice}(1);
        assertEq(bidder1.balance, 99 ether);

        vm.prank(bidder1);
        vrgea.removeBid();

        assertEq(bidder1.balance, 100 ether);
    }

    function test_GetFillableQuantity() public {
        assertEq(uint256(vrgea.getFillableQuantity()), 0);

        vm.warp(block.timestamp + 1 days);
        assertEq(uint256(vrgea.getFillableQuantity()), 1);

        vm.warp(block.timestamp + 1 days);
        assertEq(uint256(vrgea.getFillableQuantity()), 2);
    }

    function test_WhenFillable_GetFillableQuantity() public {
        uint256 reservePrice = vrgea.reservePrice();
        assertEq(uint256(vrgea.getFillableQuantity()), 0);
        vrgea.bid{value: reservePrice}(1);

        vm.warp(block.timestamp + 1 days);
        vm.prank(bidder1);
        assertEq(uint256(vrgea.getFillableQuantity()), 1, "before bid");
        vrgea.bid{value: reservePrice}(1);
        assertEq(uint256(vrgea.getFillableQuantity()), 0, "after bid");
        assertEq(uint256(vrgea.totalSold()), 1, "sold");
    }

    function test_WhenUnFillable_GetFillableQuantity() public {
        assertEq(uint256(vrgea.getFillableQuantity()), 0);

        uint256 reservePrice = vrgea.reservePrice();
        vm.warp(block.timestamp + 1 days);
        vm.prank(bidder1);
        assertEq(uint256(vrgea.getFillableQuantity()), 1, "before bid");
        vrgea.bid{value: reservePrice}(1);
        assertEq(uint256(vrgea.getFillableQuantity()), 0, "after bid");
        assertEq(uint256(vrgea.totalSold()), 0, "sold");
    }

    function test_TargetSaleTime() public {
        assertEq(WAD, uint256(vrgea.getTargetSaleTime(toWadUnsafe(1))));
        assertEq(2 * WAD, uint256(vrgea.getTargetSaleTime(toWadUnsafe(2))));
    }

    function test_WadDays() public {
        assertEq(WAD, uint256(toDaysWadUnsafe(1 days)));
    }
}
