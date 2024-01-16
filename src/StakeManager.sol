// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { IStakeManager } from "./IStakeManager.sol";


contract StakeManager is IStakeManager, Roles {
    /**
    * @dev Stores staker's info:
    * stakeTime: The time of the last stake
    * stake: All of the staker's staked funds
    * cooldown: For penalized stakers, a cooldown period until staker rights can be used
    * numRoles: Number of roles the staker has, to control permitted number of roles by `stake`  
    */
    struct StakerInfo {
        uint stakeTime;
        uint stake;
        uint cooldown;
        uint8 numRoles;
    }

    uint private registrationDepositAmount;
    uint private registrationWaitTime;
    uint private slashedFunds;
    mapping (address staker => StakerInfo info) private stakers;
    /**
    * @dev Stores the staker's roles by index (iMax = stakers[staker].numRoles) 
    * to allow revoking roles iteratively once staker unregisters.
    */
    mapping (address staker => mapping(uint index => bytes32 role)) private stakerRoles;


    /**
    * @dev Enforces `registrationDepositAmount` for new stakers registration.
    */
    modifier CheckRegistrationAmount() {
        if (msg.value != registrationDepositAmount) {
            revert IncorrectAmountSent();
        }
        _;
    }
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

    /**
    * @dev Registers a user as staker
    * Restrictions:
    * - msg.value should equal `_registrationDepositAmount`
    */
    function register()
    external 
    payable 
    CheckRegistrationAmount
    {
        stakers[_msgSender()].stakeTime = block.timestamp;
        stakers[_msgSender()].stake += msg.value;
        _grantRole(STAKER_ROLE, _msgSender());
        emit Register(
            stakers[_msgSender()].stakeTime,
            stakers[_msgSender()].stake,
            STAKER_ROLE
        );
    }

    function unregister() external {}

    function stake() external payable {}

    function unstake() external {}

    function slash(address staker, uint256 amount) external {}
}
