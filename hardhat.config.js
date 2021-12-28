/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const {mnemonic, projectId} = require("./secrets.prod.json")

require('@nomiclabs/hardhat-ethers');
module.exports = {
  solidity: "0.6.2",
  networks: {
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${projectId}`,
      accounts: { mnemonic: mnemonic },
    },
    production: {
      url: `https://eth-mainnet.alchemyapi.io/v2/${projectId}`,
      accounts: { mnemonic: mnemonic },
    },
  },
};
