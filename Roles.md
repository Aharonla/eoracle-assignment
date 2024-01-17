# Roles
**Inherits:**
IRoles, AccessControlUpgradeable


## State Variables
### STAKER_ROLE

```solidity
bytes32 public constant STAKER_ROLE = keccak256("STAKER_ROLE");
```


### roles

```solidity
mapping(bytes32 role => bool isAllowed) private roles;
```

## Modifiers

### onlyAdmin


```solidity
modifier onlyAdmin();
```

### existingRole


```solidity
modifier existingRole(bytes32 _role);
```

## Functions

### grantRole

*Overrides AccessControl's `grantRole` function to allow only internal use of _grantRole*


```solidity
function grantRole(bytes32, address) public pure override;
```

### addRole

*Adds role to allowed roles*


```solidity
function addRole(bytes32 _role) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_role`|`bytes32`|The role to add|


### removeRole

*Removes role from allowed roles*


```solidity
function removeRole(bytes32 _role) external onlyAdmin existingRole(_role);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_role`|`bytes32`|The role to remove|



