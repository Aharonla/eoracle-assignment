// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import {StakeManager} from "../src/StakeManager.sol";

/// @dev Tests for the StakeManager contract
contract StakeManagerTest is PRBTest, StdCheats {
    StakeManager internal stakeManager;

    event SetConfiguration(uint indexed amount, uint indexed time);

    error notOwner();

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        stakeManager = new StakeManager();
    }

    /// @dev Test correct call to setConfiguration
    function test_SetConfiguration() public {
        uint registrationDepositAmount = 10;
        uint registrationWaitTime = 100;
        assertEq(stakeManager.registrationDepositAmount(), 0);
        assertEq(stakeManager.registrationWaitTime(), 0);
        vm.expectEmit(true, true, false, false);
        emit SetConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        assertEq(stakeManager.registrationDepositAmount(), registrationDepositAmount);
        assertEq(stakeManager.registrationWaitTime(), registrationWaitTime);
    }

    /// @dev Test failure in case of setConfiguration called by non-owner
    function test_RevertWhen_NotOwner() public {
        vm.expectRevert(notOwner);
        vm.prank(address(0));
        stakeManager.setConfiguration(1, 1);
    }
}