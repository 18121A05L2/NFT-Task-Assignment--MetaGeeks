// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {GenesisNFTs} from "../src/GenesisNFTs.sol";
import {Constants} from "../src/Constants.sol";

contract GenesisNFTs_Script is Script, Constants {
    function run() external returns (GenesisNFTs genesisNFTs) {
        vm.startBroadcast(OWNER);
        genesisNFTs = new GenesisNFTs();
        vm.stopBroadcast();
    }
}
