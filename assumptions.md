# Assumtions

## Slashing
No slashing cause was specified.  
No slashing rate was specified.
Distribution method of slashed ETH was not specified.

- Cause of slashing will be decided by `admin` role, which might be either a governance protocol, a multisig/safe contract, or a single admin. This will stay outside the scope of this assignment.
- Slashing rate will be set, with initial value of 100%, and can be changed by admin role.
- Distribution of slashed ETH will ideally be between stakers, which will require some "staker token" for fair distribution. For the cause of this assignment the funds will be sent to a treasury address, which might be implemented in the future as a distribution contract, but for now will be assumed to be an EOA.

## Staking
No staking reward mechanism was specified (see Slashing section).  
Stakers should deposit an amount `registrationDepositAmount` on first registration. It is unclear if this deposit grants registration rights for one role at a time, or multiple simultaneous roles.

- Staking will, for now, be rewarded only by registration rights only, and might be compensated in future version (Slashing section).  
- Deposit will be made once, and grant registration rights for all roles simultaneously.

## Registration
- Ideally registration implementation will be as simple as using the openZeppelin's `AccessControl` contract.
- Setting `admin` role will be in a function `setAdmin`, will make use of `_grantRole` with an `onlyAdmin` modifier.

## Upgradability
- Contracts will be deployed using openZeppelin's `upgradable`


# Implementaion conclusions

## Configuration Management

### AccessControl approach

Initial approach of using AccessControl needs some modification, as openZeppelin's AccessControl contract allows coupling an address to any role, and doesn't restrict the roles.  
A `Roles.sol` contract will expand the functionality of `AccessControl` to make such restriction possible.

This approach imposes another problem - AccessControl's `grantRole` function demands that the role can be granted by `roleAdmin` only.
A staker can be granted `STAKER_ROLE`, and `STAKER_ROLE` can be added as `roleAdmin` for each `allowedRole`, but this means that a staker can grant any role to anyone infinately.

A partial solution will be to impose that `claimRole` grants the chosen role to `msg.sender`, and `grantRole` will be overriden to have no functionality. To disallow infinite self-grants (not clear in the specs if this is desired or not).
