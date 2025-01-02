require("@matterlabs/hardhat-zksync-deploy");
require("@matterlabs/hardhat-zksync-solc");

module.exports = {
  zksolc: {
    version: "1.3.13",
    compilerSource: "binary",
    settings: {},
  },
  defaultNetwork: "zkSyncTestnet",
  networks: {
    hardhat: {
      zksync: true,
    },
    zkSyncTestnet: {
      url: "https://testnet.era.zksync.dev",
      ethNetwork: "goerli",
      zksync: true,
    },
  },
  solidity: {
    version: "0.8.28",
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache-zk",
    artifacts: "./artifacts-zk"
  },
}; 