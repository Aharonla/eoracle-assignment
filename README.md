# Eoracle Solidity Home Assignment documentation


## Project setup

Before use of the contents of this repository you should take the following steps:
- Install foundry: https://book.getfoundry.sh/getting-started/installation (might require installation of rust as well).
- Install dependencies: `npm install` from the project's root directory.

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
- To get the latest deployed contract address, type `npm run address`. This will write the address to a file `latestAddress` at the project's root folder.
Alternatively, the address can be found at line 7 of `broadcast/Deploy.s.sol/80001/run-latest.json` or in the output logs after deployment.

An example of a deployed and verified contract can be found at https://mumbai.polygonscan.com/address/0x4a46bF449F890E1Ce5A6933Ec7D8FE81CB71170E


## Smart contract interface documentation:

See [StakeManager](/StakeManager.md), [Roles](/Roles.md)