// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import {StakeManager} from "../src/StakeManager.sol";

/// @dev Tests for the StakeManager contract
contract StakeManagerTest is PRBTest, StdCheats {
    StakeManager internal stakeManager;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant STAKER_ROLE = keccak256("STAKER_ROLE");

    event SetConfiguration(uint indexed amount, uint indexed time);
    event Register(uint indexed stakeTime, uint indexed stake, bytes32 role);
    error NotAdmin(address from);
    error IncorrectAmountSent();

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        stakeManager = new StakeManager();
    }

    /// @dev Test correct call to setConfiguration
    function test_SetConfiguration() public {
        uint registrationDepositAmount = 10;
        uint registrationWaitTime = 100;
        vm.expectEmit(true, true, true, false);
        emit SetConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.setConfiguration(
            registrationDepositAmount, 
            registrationWaitTime
        );
    }

    /// @dev Test failure in case of setConfiguration called by non-owner
    function test_RevertWhen_SetConfiguration_NotOwner() public {
        vm.expectRevert(
            abi.encodeWithSelector(NotAdmin.selector, address(1))
        );
        vm.prank(address(1));
        stakeManager.setConfiguration(1, 1);
    }


    /// @dev Test correct call to register

    function test_Register() public payable {
        uint registrationDepositAmount = 100;
        uint registrationWaitTime = 3600;
        stakeManager.setConfiguration(
            registrationDepositAmount, 
            registrationWaitTime
        );
        vm.expectEmit(true, true, true, false);
        emit Register(block.timestamp, registrationDepositAmount, STAKER_ROLE);
        stakeManager.register{value: registrationDepositAmount}();
        assertEq(address(stakeManager).balance, registrationDepositAmount);
    }

    function test_RevertWhen_Register_WrongAmountSent() public payable {
        uint registrationDepositAmount = 100;
        uint registrationWaitTime = 3600;
        stakeManager.setConfiguration(
            registrationDepositAmount, 
            registrationWaitTime
        );
        vm.expectRevert(IncorrectAmountSent.selector);
        stakeManager.register{value: registrationDepositAmount + 1}();
    }

