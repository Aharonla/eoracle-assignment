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
