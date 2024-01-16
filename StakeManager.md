# StakeManager
[Git Source](https://github.com/Aharonla/Eoracle-assignment/blob/7db76df3801c3532d6529fee9d7faf2bcd647e83/src/StakeManager.sol)

**Inherits:**
IStakeManager, Roles


## State Variables
### registrationDepositAmount

```solidity
uint256 private registrationDepositAmount;
```


### registrationWaitTime

```solidity
uint64 private registrationWaitTime;
```


### slashedFunds

```solidity
uint256 private slashedFunds;
```


### stakers

```solidity
mapping(address staker => StakerInfo info) private stakers;
```


### stakerRoles
*Stores the staker's roles by index (iMax = stakers[staker].numRoles)
to allow revoking roles iteratively once staker unregisters.*


```solidity
mapping(address staker => mapping(uint256 index => bytes32 role)) private stakerRoles;
```

## Modifiers

### CheckRegistrationAmount

*Enforces `registrationDepositAmount` for new stakers registration.*


```solidity
modifier CheckRegistrationAmount();
```

### NotRestricted

*Enforces slashed staker restriction*


```solidity
modifier NotRestricted();
```

### onlyStaker

*Controls access to functions allowed only for staker role*


```solidity
modifier onlyStaker();
```

## Functions

### setConfiguration

*Used by admin to control state parameters*


```solidity
function setConfiguration(uint256 _registrationDepositAmount, uint64 _registrationWaitTime) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_registrationDepositAmount`|`uint256`||
|`_registrationWaitTime`|`uint64`||


### register

Restrictions:
- msg.value should equal `_registrationDepositAmount`

*Registers a user as staker*


```solidity
function register() external payable CheckRegistrationAmount;
```

### claimRole

Restrictions:
- Can be accessed only by stakers
- `_role` should be permitted by manager
- Calling staker can not be in cooldown period
- Staker has not claimed `_role` before
- Staker has enough staked funds to claim another role

*used by stakers to claim roles*


```solidity
function claimRole(bytes32 _role) external onlyStaker existingRole(_role) NotRestricted;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_role`|`bytes32`|the role's "name" (Should be fixed length (bytes32), and by convention is an upper-cased underscored string)|


### unregister

Restrictions:
- Callable only by stakers
- Calling staker can not be in cooldown period

*used to renounce all roles (including `staker`) and get staked funds refunded*


```solidity
function unregister() external payable onlyStaker NotRestricted;
```

### stake

Restrictions:
- Only stakers can call

*used to add staked funds by staker*


```solidity
function stake() external payable onlyStaker;
```

### unstake

Restrictions:
- Only stakers can call
- Staker should not be in cooldown period
- Staker can not withdraw if
- Staker has enough staked funds for existing roles after withdrawal.
If last restriction is not met, staker should call `renounceRole`
to reduce the number of roles until unstaking is possible

*used to withdraw staked funds by staker*


```solidity
function unstake(uint256 _amount) external onlyStaker NotRestricted;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|Amount of funds to withdraw|


### slash

Restrictions:
- Only admin can call
- `amount` is higher than or equal the staker's funds

*Used to penalize a staker by slashing part or all of their staked funds
The penalty also involves a cooldown period, restricting staker's actions*


```solidity
function slash(address staker, uint256 amount) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|The penalized staker|
|`amount`|`uint256`|The amount of funds to slash|


### withdraw

Restrictions:
- Callable only by admin

*used to withdraw all slashed funds from the contract*


```solidity
function withdraw() external payable onlyAdmin;
```

## Structs
### StakerInfo
*Stores staker's info:
stake: All of the staker's staked funds
cooldown: For penalized stakers, a cooldown period until staker rights can be used
numRoles: Number of roles the staker has, to control permitted number of roles by `stake`*


```solidity
struct StakerInfo {
    uint256 stake;
    uint64 cooldown;
    uint8 numRoles;
}
```

