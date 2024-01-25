// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import { Upgrades, Options } from "openzeppelin-foundry-upgrades/Upgrades.sol";

import { StakeManager } from "../src/StakeManager.sol";

/// @dev Tests for the StakeManager contract
contract StakeManagerTest is PRBTest, StdCheats {
    StakeManager internal stakeManager;
    ERC1967Proxy internal proxy;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant STAKER_ROLE = keccak256("STAKER_ROLE");

    event SetConfiguration(uint256 indexed amount, uint256 indexed time);
    event Register(uint256 indexed stake);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event Unregister(uint256 indexed stake);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event Stake(uint256 indexed stake);
    event Unstake(uint256 indexed stake);
    event Slash(address indexed staker, uint256 indexed amount, uint256 indexed cooldown);
    event Withdraw(uint256 amount);
    event FakeEvent();

    error NotAdmin(address from);
    error IncorrectAmountSent();
    error NotStaker(address caller);
    error RoleNotAllowed(bytes32 role);
    error Restricted();
    error NotEnoughFunds(address staker, uint256 requiredFunds, uint256 availableFunds);
    error StakerRoleClaimed(address staker, bytes32 role);

    receive() external payable { }

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        StakeManager implementation = new StakeManager();
        proxy = new ERC1967Proxy(address(implementation), abi.encodeWithSelector(implementation.initialize.selector));
        stakeManager = StakeManager(address(proxy));
    }

    function test_Upgrade() public {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        Options memory opts;
        opts.unsafeSkipAllChecks = true;
        Upgrades.upgradeProxy(address(proxy), "StakeManagerV2.sol:StakeManagerV2", "", opts);
        vm.expectEmit(false, false, false, false);
        emit FakeEvent();
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
    }

    /// @dev Test correct call to setConfiguration
    function test_SetConfiguration(uint128 amount, uint64 time) public {
        vm.expectEmit(true, true, true, false);
        emit SetConfiguration(amount, time);
        stakeManager.setConfiguration(amount, time);
    }

    /// @dev Test failure in case of setConfiguration called by non-owner
    function test_RevertWhen_SetConfiguration_NotOwner(address notAdmin) public {
        vm.assume(notAdmin != address(this));
        vm.expectRevert(abi.encodeWithSelector(NotAdmin.selector, notAdmin));
        vm.prank(notAdmin);
        stakeManager.setConfiguration(1, 1);
    }

    /// @dev Test correct call to register
    function test_Register() public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        vm.expectEmit(true, false, false, false);
        emit Register(registrationDepositAmount);
        stakeManager.register{ value: registrationDepositAmount }();
        assertEq(address(stakeManager).balance, registrationDepositAmount);
    }

    function test_RevertWhen_Register_WrongAmountSent(uint256 amount) public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        vm.assume(amount != registrationDepositAmount);
        vm.assume(amount < address(this).balance);
        vm.expectRevert(IncorrectAmountSent.selector);
        stakeManager.register{ value: amount }();
    }

    function test_ClaimRole() public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        bytes32 newRole = "NEW_ROLE";
        stakeManager.addRole("NEW_ROLE");
        stakeManager.register{ value: registrationDepositAmount }();
        vm.expectEmit(true, true, false, false);
        emit RoleGranted(newRole, address(this), address(this));
        stakeManager.claimRole("NEW_ROLE");
    }

    function test_RevertWhen_ClaimRole_NotStaker(address sender, address staker) public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.addRole("NEW_ROLE");
        vm.assume(sender != staker);
        vm.prank(staker);
        vm.deal(staker, registrationDepositAmount);
        stakeManager.register{ value: registrationDepositAmount }();
        vm.stopPrank();
        vm.prank(sender);
        vm.expectRevert(abi.encodeWithSelector(NotStaker.selector, sender));
        stakeManager.claimRole("NEW_ROLE");
    }

    function test_RevertWhen_ClaimRole_NoExistingRole() public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        bytes32 newRole = "NEW_ROLE";
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.register{ value: registrationDepositAmount }();
        vm.expectRevert(abi.encodeWithSelector(RoleNotAllowed.selector, newRole));
        stakeManager.claimRole("NEW_ROLE");
    }

    function test_RevertWhen_ClaimRole_RestrictedStaker(uint64 time) public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        vm.assume(time < registrationWaitTime);
        stakeManager.addRole("NEW_ROLE");
        stakeManager.register{ value: registrationDepositAmount }();
        stakeManager.slash(address(this), registrationDepositAmount);
        vm.expectRevert(Restricted.selector);
        vm.warp(block.timestamp + time);
        stakeManager.claimRole("NEW_ROLE");
    }

    function test_RevertWhen_ClaimRole_NotEnoughFunds(uint256 amount) public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        vm.assume(amount < registrationDepositAmount);
        stakeManager.addRole("NEW_ROLE");
        stakeManager.addRole("SECOND_ROLE");
        stakeManager.register{ value: registrationDepositAmount }();
        stakeManager.stake{ value: amount }();
        stakeManager.claimRole("NEW_ROLE");
        vm.expectRevert(
            abi.encodeWithSelector(
                NotEnoughFunds.selector,
                address(this),
                2 * registrationDepositAmount,
                registrationDepositAmount + amount
            )
        );
        stakeManager.claimRole("SECOND_ROLE");
    }

    function test_RevertWhen_ClaimRole_StakerHasRole() public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        bytes32 newRole = "NEW_ROLE";
        stakeManager.addRole("NEW_ROLE");
        stakeManager.register{ value: registrationDepositAmount }();
        stakeManager.claimRole("NEW_ROLE");
        vm.expectRevert(abi.encodeWithSelector(StakerRoleClaimed.selector, address(this), newRole));
        stakeManager.claimRole("NEW_ROLE");
    }

    function test_Unregister() public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        bytes32 newRole = "NEW_ROLE";
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.addRole("NEW_ROLE");
        stakeManager.register{ value: registrationDepositAmount }();
        stakeManager.claimRole(newRole);
        uint256 oldBalance = address(this).balance;
        vm.expectEmit(true, false, false, false);
        emit RoleRevoked(newRole, address(stakeManager), address(this));
        vm.expectEmit(true, true, false, false);
        emit RoleRevoked(STAKER_ROLE, address(this), address(this));
        vm.expectEmit(true, true, false, false);
        emit Unregister(registrationDepositAmount);
        stakeManager.unregister();
        assertEq(address(this).balance, oldBalance + registrationDepositAmount);
    }

    function test_RevertWhen_Unregister_RestrictedStaker(uint64 time) public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        vm.assume(time < registrationWaitTime);
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.addRole("NEW_ROLE");
        stakeManager.addRole("SECOND_ROLE");
        stakeManager.register{ value: registrationDepositAmount }();
        stakeManager.slash(address(this), registrationDepositAmount);
        vm.expectRevert(Restricted.selector);
        vm.warp(block.timestamp + time);
        stakeManager.unregister();
    }

    function test_RevertWhen_Unregister_NotStaker(address staker, address sender) public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        vm.assume(staker != sender);
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.addRole("NEW_ROLE");
        stakeManager.addRole("SECOND_ROLE");
        vm.deal(staker, registrationDepositAmount);
        vm.prank(staker);
        stakeManager.register{ value: registrationDepositAmount }();
        vm.stopPrank();
        vm.prank(sender);
        vm.expectRevert(abi.encodeWithSelector(NotStaker.selector, sender));
        stakeManager.unregister();
    }

    function test_Stake(uint256 amount) public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.register{ value: registrationDepositAmount }();
        vm.assume(amount <= address(this).balance);
        vm.expectEmit(true, false, false, false);
        emit Stake(amount);
        stakeManager.stake{ value: amount }();
    }

    function test_RevertWhen_Stake_NotStaker(address staker, address sender, uint256 amount) public payable {
        vm.assume(staker != sender);
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        vm.assume(amount < type(uint256).max - registrationDepositAmount);
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        vm.prank(staker);
        vm.deal(staker, registrationDepositAmount);
        stakeManager.register{ value: registrationDepositAmount }();
        vm.stopPrank();
        vm.prank(sender);
        vm.deal(sender, amount);
        console2.log(amount);
        vm.expectRevert(abi.encodeWithSelector(NotStaker.selector, sender));
        stakeManager.stake{ value: amount }();
    }

    function test_Unstake() public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.register{ value: registrationDepositAmount }();
        stakeManager.stake{ value: 100 }();
        uint256 balanceBefore = address(this).balance;
        vm.expectEmit(true, false, false, false);
        emit Unstake(100);
        stakeManager.unstake(100);
        assertEq(address(this).balance, balanceBefore + 100);
    }

    function test_RevertWhen_Unstake_NotStaker(address staker, address sender) public payable {
        vm.assume(staker != sender);
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        vm.startPrank(staker);
        vm.deal(staker, registrationDepositAmount + 100);
        stakeManager.register{ value: registrationDepositAmount }();
        stakeManager.stake{ value: 100 }();
        vm.stopPrank();
        vm.prank(sender);
        vm.expectRevert(abi.encodeWithSelector(NotStaker.selector, sender));
        stakeManager.unstake(100);
    }

    function test_RevertWhen_Unstake_RestrictedStaker(uint64 time) public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        vm.assume(time < registrationWaitTime);
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.register{ value: registrationDepositAmount }();
        stakeManager.stake{ value: 100 }();
        stakeManager.slash(address(this), registrationDepositAmount);
        vm.warp(block.timestamp + time);
        vm.expectRevert(Restricted.selector);
        stakeManager.unstake(100);
    }

    function test_RevertWhen_Unstake_NotEnoughFunds(uint128 amount) public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        vm.assume(amount < registrationDepositAmount && amount != 0);
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.addRole("NEW_ROLE");
        stakeManager.register{ value: registrationDepositAmount }();
        stakeManager.claimRole("NEW_ROLE");
        vm.expectRevert(abi.encodeWithSelector(NotEnoughFunds.selector, address(this), amount, 0));
        stakeManager.unstake(amount);
    }

    function test_Slash(address staker, uint128 amount, uint64 time) public payable {
        uint128 registrationDepositAmount = 100;
        vm.assume(time < type(uint64).max - block.timestamp);
        uint64 registrationWaitTime = time;
        vm.assume(amount <= registrationDepositAmount);
        vm.assume(staker != address(this));
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        vm.deal(staker, registrationDepositAmount);
        vm.prank(staker);
        stakeManager.register{ value: registrationDepositAmount }();
        vm.expectEmit(true, true, true, false);
        emit Slash(staker, amount, block.timestamp + time);
        stakeManager.slash(staker, amount);
    }

    function test_RevertWhen_Slash_NotAdmin(address sender, address staker) public payable {
        vm.assume(sender != address(this));
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        vm.deal(staker, registrationDepositAmount);
        vm.prank(staker);
        stakeManager.register{ value: registrationDepositAmount }();
        vm.expectRevert(abi.encodeWithSelector(NotAdmin.selector, sender));
        vm.prank(sender);
        stakeManager.slash(staker, 50);
    }

    function test_revertWhen_Slash_NotEnoughFunds(uint128 amount, address staker) public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        vm.assume(amount > registrationDepositAmount);
        vm.deal(staker, registrationDepositAmount);
        vm.prank(staker);
        stakeManager.register{ value: registrationDepositAmount }();
        vm.stopPrank();
        vm.expectRevert(abi.encodeWithSelector(NotEnoughFunds.selector, staker, amount, registrationDepositAmount));
        stakeManager.slash(staker, amount);
    }

    function test_Withdraw() public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        stakeManager.register{ value: registrationDepositAmount }();
        stakeManager.slash(address(this), 50);
        uint256 balanceBefore = address(this).balance;
        vm.expectEmit(true, false, false, false);
        emit Withdraw(50);
        stakeManager.withdraw();
        assertEq(address(this).balance, balanceBefore + 50);
    }

    function test_RevertWhen_Withdraw_NotAdmin(address sender, address staker, uint128 amount) public payable {
        uint128 registrationDepositAmount = 100;
        uint64 registrationWaitTime = 3600;
        stakeManager.setConfiguration(registrationDepositAmount, registrationWaitTime);
        vm.assume(staker != address(this) && staker != sender);
        vm.assume(sender != address(this));
        vm.assume(amount <= registrationDepositAmount);
        vm.deal(staker, registrationDepositAmount);
        vm.prank(staker);
        stakeManager.register{ value: registrationDepositAmount }();
        vm.stopPrank();
        stakeManager.slash(staker, amount);
        vm.prank(sender);
        vm.expectRevert(abi.encodeWithSelector(NotAdmin.selector, sender));
        stakeManager.withdraw();
    }
}
