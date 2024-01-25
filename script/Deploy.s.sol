// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { StakeManager } from "../src/StakeManager.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        StakeManager implementation = new StakeManager();

        bytes memory data = abi.encode(StakeManager(implementation).initialize.selector);

        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), data);

        vm.stopBroadcast();
        console2.log(address(proxy));
    }
}
