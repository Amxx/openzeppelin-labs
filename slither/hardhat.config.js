const settings = {
  optimizer: {
    enabled: true,
    runs: 200,
  },
};

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      { version: '0.8.11',  settings },
      { version: '0.7.6',  settings },
      { version: '0.6.12', settings },
      { version: '0.5.16', settings },
    ],
  },
};
