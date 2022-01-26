require('dotenv/config');

const { ethers                      } = require('ethers');
const { POSClient, use, setProofApi } = require('@maticnetwork/maticjs');
const { Web3ClientPlugin            } = require('@maticnetwork/maticjs-ethers');

const argv = require('yargs/yargs')(process.argv.slice(2))
    .env('')
    .options({
        network:   { type: 'string', choices: [ 'mainnet-v1', 'testnet-mumbai' ], default: 'testnet-mumbai'        },
        proofApi:  { type: 'string', default: 'https://apis.matic.network/'                                        },
        parentRPC: { type: 'string', default: process.env.GOERLI_NODE                                              },
        childRPC:  { type: 'string', default: process.env.POLYGON_MUMBAI_NODE                                      },
        mnemonic:  { type: 'string', default: 'test test test test test test test test test test test junk'        }, // This is not actually needed
        txHash:    { type: 'string', default: '0x0bfe5f44b5836f6ce1ad8bd43002f9f3d1dd4ebcfe5b4e7a2cff01ddc6c05949' },
        eventSig:  { type: 'string', default: 'MessageSent(bytes)'                                                 },
    })
    .argv;

use(Web3ClientPlugin)
setProofApi(argv.proofApi);

async function main() {
    const signers = {
        parent: ethers.Wallet.fromMnemonic(argv.mnemonic).connect(ethers.getDefaultProvider(argv.parentRPC)),
        child:  ethers.Wallet.fromMnemonic(argv.mnemonic).connect(ethers.getDefaultProvider(argv.childRPC)),
    };

    const [ network, version ] = argv.network.split('-');

    const client = new POSClient();
    await client.init({
        network,
        version,
        parent:  { provider: signers.parent, defaultConfig: { from: signers.parent.address }},
        child:   { provider: signers.child,  defaultConfig: { from: signers.child.address  }},
    });

    const proof = await client.exitUtil.buildPayloadForExit(argv.txHash, ethers.utils.id(argv.eventSig), !!argv.proofApi);
    console.log(proof)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
