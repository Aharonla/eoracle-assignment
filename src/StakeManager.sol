// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import {IStakeManager} from "./IStakeManager.sol";

    uint public registrationDepositAmount;
    uint public registrationWaitTime;

    function register() external payable {}

    function unregister() external {}

    function stake() external payable {}

    function unstake() external {}

    function slash(address staker, uint256 amount) external {}
}
