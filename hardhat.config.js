/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();
const {
  RINKEBY_PRIVATE_KEY,
  ALCHEMY_API_KEY,
  ETHERSCAN_API_KEY,
  RINKEBY_PRIVATE_KEY_2,
  ALCHEMY_API_KEY_POLYGON,
  POLYGONSCAN_API_KEY,
} = process.env;

module.exports = {
  solidity: {
    compilers: [{ version: "0.8.8" }, { version: "0.5.12" }],
  },
  networks: {
    rinkeby: {
      url: ALCHEMY_API_KEY,
      accounts: [`0x${RINKEBY_PRIVATE_KEY}`, `0x${RINKEBY_PRIVATE_KEY_2}`],
    },
    polygon: {
      url: ALCHEMY_API_KEY_POLYGON,
      accounts: [`0x${RINKEBY_PRIVATE_KEY}`, `0x${RINKEBY_PRIVATE_KEY_2}`],
      gasPrice: 50000000000,
    },

    hardhat: {
      forking: {
        url: ALCHEMY_API_KEY,
      },
    },
  },
  etherscan: {
    apiKey: POLYGONSCAN_API_KEY,
  },
};
