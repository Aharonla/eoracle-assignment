// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import {IStakeManager} from "./IStakeManager.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract StakeManager is IStakeManager, AccessControl {
    uint public registrationDepositAmount;
    uint public registrationWaitTime;

    event SetConfiguration(uint indexed amount, uint indexed time);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
    * @dev Used by admin to control state parameters
    * @param _registrationDepositAmount: Amount required to register as staker
    * @param _registrationWaitTime: Cooldown period for slashed stakers
    */
    function setConfiguration(
        uint _registrationDepositAmount, 
        uint _registrationWaitTime
        ) 
        external
    onlyAdmin 
    {
            registrationDepositAmount = _registrationDepositAmount;
            registrationWaitTime = _registrationWaitTime;
            emit SetConfiguration(_registrationDepositAmount, _registrationWaitTime);
        }

    function register() external payable {}

    function unregister() external {}

    function stake() external payable {}

    function unstake() external {}

    function slash(address staker, uint256 amount) external {}
}
