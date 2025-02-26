// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {GenesisNFTs} from "../src/GenesisNFTs.sol";

contract GenesisNFTs_Script is Script {
    function run() external returns (GenesisNFTs genesisNFTs) {
        vm.startBroadcast();
        genesisNFTs = new GenesisNFTs();
        vm.stopBroadcast();
    }
}
