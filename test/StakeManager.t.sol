// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import {StakeManager} from "../src/StakeManager.sol";

/// @dev Tests for the StakeManager contract
contract StakeManagerTest is PRBTest, StdCheats {
    StakeManager internal stakeManager;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        stakeManager = new StakeManager();
    }
}
