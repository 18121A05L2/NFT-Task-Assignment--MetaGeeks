// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GenesisNFTs} from "../src/GenesisNFTs.sol";
import {GenesisNFTs_Script} from "../script/GenesisNFTs.s.sol";
import {Constants} from "../src/Constants.sol";
import {IERC721Errors} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestNfts is Test, Constants {
    GenesisNFTs genesisNFTs;
    address randomAddress;
    uint256 randPrivateKey;
    address secondRandom;
    uint256 secondPrivateKey;

    uint256 notMinPrice = 0.02 ether;
    uint256 gtThanMinSellPrice = 0.3 ether;

    function setUp() public {
        genesisNFTs = new GenesisNFTs_Script().run();
        (randomAddress, randPrivateKey) = makeAddrAndKey("randomAddress");
        (secondRandom, secondPrivateKey) = makeAddrAndKey("second");
        vm.deal(secondRandom, 10 ether);
    }

    modifier mintSomeNfts() {
        vm.startPrank(randomAddress);
        for (uint256 i = 0; i < 10; i++) {
            genesisNFTs.mint(randomAddress);
        }
        vm.stopPrank();
        _;
    }

    function testOwnerShip() public view {
        address currentOwner = genesisNFTs.owner();
        assertEq(currentOwner, OWNER);
    }

    function testFreeMint() public {
        genesisNFTs.mint(randomAddress);
        uint256 balance = genesisNFTs.balanceOf(randomAddress);
        assertEq(balance, 1);

        genesisNFTs.mint(randomAddress);
        uint256 newBalance = genesisNFTs.balanceOf(randomAddress);
        assertEq(newBalance, 2);
    }

    function testWhenFreeMintClosed() public {
        vm.store(address(genesisNFTs), bytes32(uint256(8)), bytes32(uint256(1001)));
        vm.expectRevert(GenesisNFTs.GenesisNFTs_FreeMintClosed.selector);
        genesisNFTs.mint(randomAddress);
    }

    function testOwnerTriesToMintAfterACertailLimit() public {
        vm.store(address(genesisNFTs), bytes32(uint256(8)), bytes32(uint256(1200)));
        vm.prank(OWNER);
        genesisNFTs.mint(OWNER);
    }

    function testSellFunctionReverts() public mintSomeNfts {
        vm.startPrank(secondRandom);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidOwner.selector, secondRandom));
        genesisNFTs.sell(1, notMinPrice);
        vm.stopPrank();

        vm.startPrank(randomAddress);
        vm.expectRevert(GenesisNFTs.GenesisNFTs_MinimumSalePriceNotMet.selector);
        genesisNFTs.sell(1, notMinPrice);

        vm.expectRevert(GenesisNFTs.GenesisNFTs_SaleClosed.selector);
        genesisNFTs.sell(1, gtThanMinSellPrice);
        vm.stopPrank();
    }

    function testSellFunctionSuccess() public mintSomeNfts {
        vm.startPrank(randomAddress);

        vm.store(address(genesisNFTs), bytes32(uint256(6)), bytes32(abi.encode(true)));
        assertEq(genesisNFTs.isSaleOpen(), true);

        genesisNFTs.approve(address(genesisNFTs), 1);
        genesisNFTs.sell(1, gtThanMinSellPrice);
        assertEq(genesisNFTs.ownerOf(1), address(genesisNFTs));
        vm.stopPrank();
    }

    function testBuyBasedOnSaleIsOpenedOrNot() public {
        vm.expectRevert(GenesisNFTs.GenesisNFTs_NotAvailableForSale.selector);
        genesisNFTs.buy(randomAddress, 1, randomAddress);

        testSellFunctionSuccess();

        uint256 secondRandomBalance = address(secondRandom).balance;
        uint256 randomBalance = address(randomAddress).balance;
        uint256 contractBalance = address(genesisNFTs).balance;

        (uint256 price,, address owner) = genesisNFTs.nftSaleInfo(1);
        (uint256 finalAmountReceivedToSeller, uint256 feeCollectedByContract) = genesisNFTs.calculateFees(1);
        vm.prank(secondRandom);
        genesisNFTs.buy{value: price}(secondRandom, 1, owner);
        assertEq(genesisNFTs.ownerOf(1), secondRandom);
        assertEq(address(randomAddress).balance, randomBalance + finalAmountReceivedToSeller);
        assertEq(address(secondRandom).balance, secondRandomBalance - price);
        assertEq(address(genesisNFTs).balance, contractBalance + feeCollectedByContract);
    }

    function testCancelOrSellFunction() public {
        testSellFunctionSuccess();

        vm.startPrank(randomAddress);
        genesisNFTs.cancelSellOrder(1);
        assertEq(genesisNFTs.ownerOf(1), randomAddress);
        vm.stopPrank();
        (uint256 price, bool isOpenForSale, address owner) = genesisNFTs.nftSaleInfo(1);
        assertEq(owner, address(0));
        assertEq(isOpenForSale, false);
        assertEq(price, 0);
    }
}
