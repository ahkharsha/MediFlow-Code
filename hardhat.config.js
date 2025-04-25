require("@nomicfoundation/hardhat-toolbox");

const NEXT_PUBLIC_RPC_URL = "";
const NEXT_PUBLIC_PRIVATE_KEY = "YOUR_PRIVATE_KEY";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    },
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    // flow_testnet: {
    //   url: NEXT_PUBLIC_RPC_URL,
    //   accounts: [`0x${NEXT_PUBLIC_PRIVATE_KEY}`],
    // },
  },
};
