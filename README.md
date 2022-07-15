# UPGRADABLE-STABLECOIN-STAKING-CONTRACT

## Technology Stack & Tools

- Solidity (Writing Smart Contract)

- Javascript (React & Testing)

- Ethers (Blockchain Interaction)

- Hardhat (Development Framework)

## MyToken.sol contarct

#### Custom ERC20 token:-"BRUCE TOKEN" symbol :-"BTKN", this token will be distributed as a reward for staking.

- Contract deployed on Polygon Mumbai test network at:

> [MyToken Contract Address](https://mumbai.polygonscan.com/token/0x5f8B87F01d4Cc518d96E936B95DD47E19eB5eC1f)

## chainlinkAggregator.sol contarct

#### chainlink price aggregator to get USD value of tokens staked in order to calculate perks.

- Contract deployed on Polygon Mumbai test network  at:

> [chainlinkAggregator Contract Address](https://mumbai.polygonscan.com/address/0x62112087302d981159b8D46A812E05860fD2eF97)

## staking.sol contarct

Reward for staking stablecoins based on the time tokens are staked are given below
| STAKING TIME | APR% |
| ------------- | ------------- |
|0-1 Month | 5% |
| 1-6 Month | 10 % |
| 6-12 Month | 15% |
| above 12 Month | 18% |

If the USD Value of tokens staked is more than 100 dollars users get additional APR PERKS on their tokens staked
| USD VALUE | EXTRA APR% |
| ------------- | ------------- |
|above 100$ | 2% |
|above 500$ | 5 % |
|above 1000$ | 10% |

- Contract deployed on Polygon Mumbai test network at:

> [staking Proxy Contract Address](https://mumbai.polygonscan.com/address/0xDa9974d844F56c02Ae274E2Ce2E157fC225F4b57) </br>
> [staking implementation Contract Address](https://mumbai.polygonscan.com/address/0x8e78EF7B43014404b1Ff5278E940231FFd6E38F9) </br>

#### Function addNewStableCoin

- lets only owner add new stablecoin support </br>
- Tx hash:- [addNewStableCoin](https://mumbai.polygonscan.com/tx/0xdd3696c49c59c5ddbeda30ada9025888f2a41e931624112ca883f83bd11ca8dc) </br>

#### Function removeStablecoin

- lets owner remove stablecoin support </br>
- Tx hash:- [removeStablecoin](https://mumbai.polygonscan.com/tx/0xd432a2b5d56de2dba04f021e6b2cc008cead72f6db7961758c5723d1e3419deb) </br>



## Requirements For Initial Setup

- Install NodeJS, should work with any node version below 16.5.0

- Install Hardhat

## Setting Up

1. Clone/Download the Repository </br>

> git clone https://github.com/majinbruce/TOKEN-VESTING-CONTRACT.git

2. Install Dependencies:

> npm init --yes </br>

> npm install --save-dev hardhat </br>

> npm install dotenv --save </br>

3. Install Plugins:

> npm install --save-dev @nomiclabs/hardhat-ethers ethers @nomiclabs/hardhat-waffle ethereum-waffle chai </br>

> npm install --save-dev @nomiclabs/hardhat-etherscan </br>

> npm install @openzeppelin/contracts

4. Compile:

> npx hardhat compile

5. Migrate Smart Contracts

> npx hardhat run scripts/deploy.js --network <network-name>

6. Run Tests

> npx hardhat test

7. verify contract

> npx hardhat verify <contract address> --constructor-args --network rinkeby
