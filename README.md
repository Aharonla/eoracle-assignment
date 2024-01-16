# Eoracle Solidity Home Assignment
## Overview
This assignment is designed to assess your skills in Solidity development, particularly in implementing smart contracts with specific functionalities and constraints. The focus will be on your ability to follow an interface specification, as well as on the clarity of your code, storage decisions, unit testing, smart contract security, and gas efficiency.
## Assignment Specifications
### Task
Your task is to write a smart contract in Solidity that implements the IStakeManager interface. This contract should manage staking functionality within a system, including registration, configuration management, staking, unstaking, and slashing mechanisms.
Roles and Registration

- Stakers can register, unregister, and be slashed.
- When a staker registers for the first time, they should deposit registrationDepositAmount wei.
- A staker can register for one or more roles.


### Configuration Management

- The configuration should control which roles exist in the system.
- It should specify how much wei a staker should deposit upon registration.
- It should define how long the registration process takes before a staker is able to unstake.

### Interface

```solidity
interface IStakeManager {

 /**
 * @dev Allows an admin to set the configuration of the staking contract.
 * @param registrationDepositAmount Initial registration deposit amount in wei.
 * @param registrationWaitTime The duration a staker must wait after initiating registration.
 */
 function setConfiguration(uint256 registrationDepositAmount, uint256 registrationWaitTime) external;

 /**
 * @dev Allows an account to register as a staker.
 */
 function register() external payable;

 /**
 * @dev Allows a registered staker to unregister and exit the staking system.
 */
 function unregister() external;

 /**
 * @dev Allows registered stakers to stake ether into the contract.
 */
 function stake() external payable;

 /**
 * @dev Allows registered stakers to unstake their ether from the contract.
 */
 function unstake() external;

 /**
 * @dev Allows an admin to slash a portion of the staked ether of a given staker.
 * @param staker The address of the staker to be slashed.
 * @param amount The amount of ether to be slashed from the staker.
 */
 function slash(address staker, uint256 amount) external;
}
```

### Requirements
Implementation: Your contract must implement all functions in the IStakeManager interface.


### Access Control:
- The register function should be callable by anyone. 
- The stake function should be restricted to stakers only.
- The unstake function should be restricted to stakers only.
- The slash function should be restricted to an admin role.
- Ensure that only authorized users can configure the system.

- Testing: Include comprehensive unit tests using Cast / Foundry.


- Upgradeability: The contract should be upgradeable.
- Documentation: Provide clear documentation on how to deploy, interact with, and test the contract.
### Submission Guidelines
- Repository: Submit your project in a GitHub repository.
- EVM Compatibility: Ensure the project is compatible with an EVM-compliant blockchain.
- Assumptions: Document any assumptions made during the development process.
