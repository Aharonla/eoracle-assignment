// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import {IStakeManager} from "./IStakeManager.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract StakeManager is IStakeManager, AccessControl {
    uint public registrationDepositAmount;
    uint public registrationWaitTime;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    function register() external payable {}

    function unregister() external {}

    function stake() external payable {}

    function unstake() external {}

    function slash(address staker, uint256 amount) external {}
}
