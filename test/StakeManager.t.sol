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
    event Register(uint indexed stake);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event Unregister(uint indexed stake);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event Stake(uint indexed stake);
    event Unstake(uint indexed stake);
    event Slash(address indexed staker, uint indexed amount, uint indexed cooldown);
    event Withdraw(uint amount);
    error NotAdmin(address from);
    error IncorrectAmountSent();
    error NotStaker(address caller);
    error RoleNotAllowed(bytes32 role);
    error Restricted();
    error NotEnoughFunds(address staker, uint requiredFunds, uint availableFunds);
    error StakerRoleClaimed(address staker, bytes32 role);

    receive() external payable {}

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        stakeManager = new StakeManager();
    }

    /// @dev Test correct call to setConfiguration
    function test_SetConfiguration() public {
        uint registrationDepositAmount = 10;
        uint64 registrationWaitTime = 100;
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
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(
            registrationDepositAmount, 
            registrationWaitTime
        );
        vm.expectEmit(true, false, false, false);
        emit Register(registrationDepositAmount);
        stakeManager.register{value: registrationDepositAmount}();
        assertEq(address(stakeManager).balance, registrationDepositAmount);
    }

    function test_RevertWhen_Register_WrongAmountSent() public payable {
        uint registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(
            registrationDepositAmount, 
            registrationWaitTime
        );
        vm.expectRevert(IncorrectAmountSent.selector);
        stakeManager.register{value: registrationDepositAmount + 1}();
    }

    function test_ClaimRole() public payable {
        uint registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(
            registrationDepositAmount, 
            registrationWaitTime
        );
        bytes32 newRole = "NEW_ROLE";
        stakeManager.addRole("NEW_ROLE");
        stakeManager.register{value: registrationDepositAmount}();
        vm.expectEmit(true, true, false, false);
        emit RoleGranted(newRole, address(this), address(this));
        stakeManager.claimRole("NEW_ROLE");
        }

        function test_RevertWhen_ClaimRole_NotStaker() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount, 
                registrationWaitTime
            );
            stakeManager.addRole("NEW_ROLE");
            vm.expectRevert(
                abi.encodeWithSelector(NotStaker.selector, address(this))
            );
            stakeManager.claimRole("NEW_ROLE");
        }

        function test_RevertWhen_ClaimRole_NoExistingRole() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            bytes32 newRole = "NEW_ROLE";
            stakeManager.setConfiguration(
                registrationDepositAmount, 
                registrationWaitTime
            );
            stakeManager.register{value: registrationDepositAmount}();
            vm.expectRevert(
                abi.encodeWithSelector(RoleNotAllowed.selector, newRole)
            );
            stakeManager.claimRole("NEW_ROLE");
        }

        function test_RevertWhen_ClaimRole_RestrictedStaker() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount, 
                registrationWaitTime
            );
            stakeManager.addRole("NEW_ROLE");
            stakeManager.register{value: registrationDepositAmount}();
            stakeManager.slash(address(this), registrationDepositAmount);
            vm.expectRevert(Restricted.selector);
            stakeManager.claimRole("NEW_ROLE");
        }
        
        function test_RevertWhen_ClaimRole_NotEnoughFunds() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount, 
                registrationWaitTime
            );
            stakeManager.addRole("NEW_ROLE");
            stakeManager.addRole("SECOND_ROLE");
            stakeManager.register{value: registrationDepositAmount}();
            stakeManager.claimRole("NEW_ROLE");
            vm.expectRevert(
                abi.encodeWithSelector(
                    NotEnoughFunds.selector, 
                    address(this), 
                    2 * registrationDepositAmount, 
                    registrationDepositAmount
                    )
            );
            stakeManager.claimRole("SECOND_ROLE");
        }
        
        function test_RevertWhen_ClaimRole_StakerHasRole() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount, 
                registrationWaitTime
            );
            bytes32 newRole = "NEW_ROLE";
            stakeManager.addRole("NEW_ROLE");
            stakeManager.register{value: registrationDepositAmount}();
            stakeManager.claimRole("NEW_ROLE");
            vm.expectRevert(
                abi.encodeWithSelector(
                    StakerRoleClaimed.selector,
                    address(this),
                    newRole
                    )
            );
            stakeManager.claimRole("NEW_ROLE");
        }

        function test_Unregister() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            bytes32 newRole = "NEW_ROLE";
            stakeManager.setConfiguration(
                registrationDepositAmount, 
                registrationWaitTime
            );
            stakeManager.addRole("NEW_ROLE");
            stakeManager.register{value: registrationDepositAmount}();
            stakeManager.claimRole(newRole);
            vm.expectEmit(true, false, false, false);
            emit RoleRevoked(newRole, address(stakeManager), address(this));
            vm.expectEmit(true, true, false, false);
            emit RoleRevoked(STAKER_ROLE, address(this), address(this));
            vm.expectEmit(true, true, false, false);
            emit Unregister(registrationDepositAmount);
            stakeManager.unregister();
        }

        function test_RevertWhen_Unregister_RestrictedStaker() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount, 
                registrationWaitTime
            );
            stakeManager.addRole("NEW_ROLE");
            stakeManager.addRole("SECOND_ROLE");
            stakeManager.register{value: registrationDepositAmount}();
            stakeManager.slash(address(this), registrationDepositAmount);
            vm.expectRevert(Restricted.selector);
            stakeManager.unregister();
        }
        
        function test_RevertWhen_Unregister_NotStaker() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount, 
                registrationWaitTime
            );
            stakeManager.addRole("NEW_ROLE");
            stakeManager.addRole("SECOND_ROLE");
            vm.expectRevert(abi.encodeWithSelector(NotStaker.selector, address(this)));
            stakeManager.unregister();
        }

        function test_Stake() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount, 
                registrationWaitTime
            );
            stakeManager.register{value: registrationDepositAmount}();
            vm.expectEmit(true, false, false, false);
            emit Stake(100);
            stakeManager.stake{value: 100}();
        }
        
        function test_RevertWhen_Stake_NotStaker() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount, 
                registrationWaitTime
            );
            vm.expectRevert(
                abi.encodeWithSelector(
                    NotStaker.selector, 
                    address(this)
                )
            );
            stakeManager.stake{value: 100}();
        }

        function test_Unstake() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount,
                registrationWaitTime
            );
            stakeManager.register{value: registrationDepositAmount}();
            stakeManager.stake{value: 100}();
            uint balanceBefore = address(this).balance;
            vm.expectEmit(true, false, false, false);
            emit Unstake(100);
            stakeManager.unstake(100);
            assertEq(address(this).balance, balanceBefore + 100);
        }

        function test_RevertWhen_Unstake_NotStaker() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount,
                registrationWaitTime
            );
            stakeManager.register{value: registrationDepositAmount}();
            stakeManager.stake{value: 100}();
            stakeManager.unregister();
            vm.expectRevert(
                abi.encodeWithSelector(NotStaker.selector, address(this))
            );
            stakeManager.unstake(100);
        }

        function test_RevertWhen_Unstake_RestrictedStaker() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount,
                registrationWaitTime
            );
            stakeManager.register{value: registrationDepositAmount}();
            stakeManager.stake{value: 100}();
            stakeManager.slash(address(this), registrationDepositAmount);
            vm.expectRevert(Restricted.selector);
            stakeManager.unstake(100);
        }

        function test_RevertWhen_Unstake_NotEnoughFunds() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount,
                registrationWaitTime
            );
            stakeManager.addRole("NEW_ROLE");
            stakeManager.register{value: registrationDepositAmount}();
            stakeManager.claimRole("NEW_ROLE");
            vm.expectRevert(
                abi.encodeWithSelector(
                    NotEnoughFunds.selector, 
                    address(this), 
                    100, 
                    0
                )
            );
            stakeManager.unstake(100);
        }

        function test_Slash() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount,
                registrationWaitTime
            );
            stakeManager.register{value: registrationDepositAmount}();
            vm.expectEmit(true, true, true, false);
            emit Slash(address(this), 50, block.timestamp + 3600);
            stakeManager.slash(address(this), uint(50));
        }

        function test_RevertWhen_Slash_NotAdmin() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount,
                registrationWaitTime
            );
            stakeManager.register{value: registrationDepositAmount}();
            vm.expectRevert(
                abi.encodeWithSelector(NotAdmin.selector, address(1))
            );
            vm.prank(address(1));
            stakeManager.slash(address(this), 50);
        }

        function test_revertWhen_Slash_NotEnoughFunds() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount,
                registrationWaitTime
            );
            stakeManager.register{value: registrationDepositAmount}();
            vm.expectRevert(
                abi.encodeWithSelector(NotEnoughFunds.selector, address(this), 101, 100)
            );
            stakeManager.slash(address(this), 101);
        }

        function test_Withdraw() public payable {
            uint registrationDepositAmount = 100;
            uint64 registrationWaitTime = 3600;
            stakeManager.setConfiguration(
                registrationDepositAmount,
                registrationWaitTime
            );
            stakeManager.register{value: registrationDepositAmount}();
            stakeManager.slash(address(this), 50);
            uint balanceBefore = address(this).balance;
            vm.expectEmit(true, false, false, false);
            emit Withdraw(50);
            stakeManager.withdraw();
            assertEq(address(this).balance, balanceBefore + 50);
        }
}
