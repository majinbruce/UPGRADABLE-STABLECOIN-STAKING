/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config({ path: "../.env" });
const {
  RINKEBY_PRIVATE_KEY,
  ALCHEMY_API_KEY,
  ETHERSCAN_API_KEY,
  RINKEBY_PRIVATE_KEY_2,
} = process.env;

module.exports = {
  solidity: {
    compilers: [{ version: "0.8.8" }, { version: "0.5.12" }],
  },
  networks: {
    rinkeby: {
      url: ALCHEMY_API_KEY,
      accounts: [`0x${RINKEBY_PRIVATE_KEY}`, `0x${RINKEBY_PRIVATE_KEY_2}`],
      gasPrice: 20e9,
      gas: 25e6,
    },

    hardhat: {
      forking: {
        url: ALCHEMY_API_KEY,
      },
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
