// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { StakeManager } from "../src/StakeManager.sol";

contract DeployImplementation is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        StakeManager implementation = new StakeManager();

        vm.stopBroadcast();
        console2.log(address(implementation));
    }
}
