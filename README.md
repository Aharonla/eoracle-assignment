# Eoracle Solidity Home Assignment documentation


## Project setup

Before use of the contents of this repository you should take the following steps:
- Install foundry: https://book.getfoundry.sh/getting-started/installation (might require installation of rust as well).
- Install dependencies: `npm install` from the project's root directory and then `npm run installdeps`

## Testing
To test the smart contracts in this repository,type `forge test` or `forge test --gas-report` to test with gas-consumption reports output to the console.

## Deployment
To deploy the `StakeManager` smart contract, follow the next steps:
- Change the file `.env.example`'s name to `.env`.
- Paste your mumbai secret-key to the variable `SECRET_KEY` in `.env`.
- Get a PolygonScan API key (Sign up https://polygonscan.com/register or sign in https://polygonscan.com/login and create a key or get an existing one). Paste the API key to `API_KEY_POLYGONSCAN` in `.env`.
- Get or create an Alchemy API key (sign up or sign in at https://www.alchemy.com/). Paste the API key to `API_KEY_ALCHEMY` in `.env`.
- In the console, type `source .env` and then `npm run deploy`.
- Smart contracts are verified, but if changes were to be made, type `source .env` and then `npm run deploy:verify`.
- To get the latest deployed contract addresses, type `npm run address`. This will write the addresses to a file `latestAddress` at the project's root folder (first address is the implementation contract, the second address is the proxy contract).
Alternatively, the addresses can be found in the output logs after deployment.

An example of a deployed and verified contracts can be found at [implementation](https://mumbai.polygonscan.com/address/0x81be88e3ee54a17ff4a87a95fc34be1ace9502ca),  [proxy](https://mumbai.polygonscan.com/address/0xdE40023758c35124482AcBDDa5C7b2a7DA0d5d73)


## Smart contract interface documentation:

See [StakeManager](/StakeManager.md), [Roles](/Roles.md) for full smart contract documentation (generated from solidity natSpec).