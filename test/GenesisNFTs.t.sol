// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GenesisNFTs} from "../src/GenesisNFTs.sol";
import {GenesisNFTs_Script} from "../script/GenesisNfts.s.sol";

contract TestNfts is Test {
    GenesisNFTs genesisNFTs;
    address randomAddress;
    uint256 randPrivateKey;

    function setUp() public {
        genesisNFTs = new GenesisNFTs_Script().run();
        (randomAddress, randPrivateKey) = makeAddrAndKey("randomAddress");
    }

    function testFreeMint() public {
        genesisNFTs.mint(randomAddress, 1);
        uint256 balance = genesisNFTs.balanceOf(randomAddress);
        assertEq(balance, 1);

        genesisNFTs.mint(randomAddress, 2);
        uint256 newBalance = genesisNFTs.balanceOf(randomAddress);
        assertEq(newBalance, 2);
    }

    function testWhenFreeMintClosed() public {}
}
