// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { IStakeManager } from "./IStakeManager.sol";
import { Roles } from "./Roles.sol";


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

    /**
    * @dev Enforces slashed staker restriction
    */
    modifier NotRestricted() {
        if (stakers[_msgSender()].cooldown > block.timestamp) {
            revert Restricted();
        }
        _;
    }

    /**
    * @dev Controls access to functions allowed only for staker role
    */
    modifier onlyStaker() {
        if (!hasRole(STAKER_ROLE, _msgSender())) {
            revert NotStaker(_msgSender());
        }
        _;
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

    /**
    * @dev used by stakers to claim roles
    * @param _role the role's "name" (Should be fixed length (bytes32),
    * and by convention is an upper-cased underscored string)
    * Restrictions:
    * - Can be accessed only by stakers
    * - `_role` should be permitted by manager
    * - Calling staker can not be in cooldown period
    * - Staker has not claimed `_role` before
    * - Staker has enough staked funds to claim another role
    */
    function claimRole(bytes32 _role) 
    external
    onlyStaker
    existingRole(_role)
    NotRestricted
    {
        if (hasRole(_role, _msgSender())) {
            revert StakerRoleClaimed(_msgSender(), _role);
        }
        if (
            (stakers[_msgSender()].numRoles + 1) * registrationDepositAmount 
            > 
            stakers[_msgSender()].stake
        ) {
            revert NotEnoughFunds(
                _msgSender(),
                (stakers[_msgSender()].numRoles + 1) * registrationDepositAmount,
                stakers[_msgSender()].stake
            );
        }
        stakerRoles[_msgSender()][stakers[_msgSender()].numRoles] = _role;
        stakers[_msgSender()].numRoles++;
        _grantRole(_role, _msgSender());
        emit RoleClaimed(_msgSender(), _role);
    }

}
