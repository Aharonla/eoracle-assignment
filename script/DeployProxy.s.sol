// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { StakeManager } from "../src/StakeManager.sol";

contract DeployProxy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address _implementation = 0xD434D9f8293Be6c473FA55D1103103b83197225E; // Replace with your implementation address
        vm.startBroadcast(deployerPrivateKey);

        if (_implementation == address(0)) {
            revert("No implementation address available");
        }
        bytes memory data = abi.encode(StakeManager(_implementation).initialize.selector);

        ERC1967Proxy proxy = new ERC1967Proxy(_implementation, data);

        vm.stopBroadcast();

        console2.log("Proxy Address:", address(proxy));
    }
}