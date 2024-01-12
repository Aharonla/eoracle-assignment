// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import {IStakeManager} from "./IStakeManager.sol";

contract StakeManager is IStakeManager {
    function setConfiguration(uint256 registrationDepositAmount, uint256 registrationWaitTime) external {}

    function register() external payable {}

    function unregister() external {}

    function stake() external payable {}

    function unstake() external {}

    function slash(address staker, uint256 amount) external {}
}
