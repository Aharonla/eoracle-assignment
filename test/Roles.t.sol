// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import {Roles} from "../src/Roles.sol";

/// @dev Tests for the Roles contract
contract RolesTest is PRBTest, StdCheats {
    event RoleAdded(bytes32 indexed role);
    event RoleRemoved(bytes32 indexed role);
    error NotAdmin(address from);
    error RoleAllowed(bytes32 role);
    error RoleNotAllowed(bytes32 role);

    Roles internal roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    error NoPublicGrantRole();

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        roles = new Roles();
    }

    /// @dev Test failure in case of external call to grantRole
    function test_RevertWhen_ExternalGrantRole() public {
        vm.expectRevert(NoPublicGrantRole.selector);
        roles.grantRole(DEFAULT_ADMIN_ROLE, address(0));
    }

    /// @dev Test addRole success
    function test_AddRole() public {
        vm.expectEmit(true, false, false, false);
        emit RoleAdded("NEW_ROLE");
        roles.addRole("NEW_ROLE");
    }

    /// @dev Test addRole failure in case of call by non-owner
    function test_RevertWhen_AddRole_NotOwner() public {
        vm.expectRevert(
            abi.encodeWithSelector(NotAdmin.selector, address(1))
        );
        vm.prank(address(1));
        roles.addRole("NEW_ROLE");
    }

    function test_RevertWhen_AddRole_RoleExists() public {
        bytes32 newRole = "NEW_ROLE";
        roles.addRole("NEW_ROLE");
        vm.expectRevert(
            abi.encodeWithSelector(RoleAllowed.selector, newRole)
        );
        roles.addRole("NEW_ROLE");
    }

    function test_RemoveRole() public {
        roles.addRole("NEW_ROLE");
        vm.expectEmit(true, false, false, false);
        emit RoleRemoved("NEW_ROLE");
        roles.removeRole("NEW_ROLE");
    }

    function test_RevertWhen_RemoveRole_NotOwner() public {
        roles.addRole("NEW_ROLE");
        vm.expectRevert(
            abi.encodeWithSelector(NotAdmin.selector, address(1))
        );
        vm.prank(address(1));
        roles.removeRole("NEW_ROLE");
    }

    function test_RevertWhen_AddRole_RoleDoesNotExists() public {
        bytes32 newRole = "NEW_ROLE";
        vm.expectRevert(
            abi.encodeWithSelector(RoleNotAllowed.selector, newRole)
        );
        roles.removeRole("NEW_ROLE");
    }
}
