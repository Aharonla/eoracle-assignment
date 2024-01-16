// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { Script } from "forge-std/src/Script.sol";
import { StakeManager } from "../src/StakeManager.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        StakeManager stakeManager = new StakeManager();

        vm.stopBroadcast();
    }
}
