require('dotenv/config');

const { ethers } = require('hardhat');
const { expect } = require('chai');
const { attach, deploy } = require('@amxx/hre/scripts');

const argv = require('yargs/yargs')(process.argv.slice(2))
    .env('')
    .options({
        rootChain:  { type: 'string', default: process.env.GOERLI_NODE                                       },
        childChain: { type: 'string', default: process.env.POLYGON_MUMBAI_NODE                               },
        mnemonic:   { type: 'string', default: 'test test test test test test test test test test test junk' },
    })
    .argv;

const ENV = {
    1: {
        fxRoot:            '0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2',
        checkpointManager: '0x86E4Dc95c7FBdBf52e33D563BbDB00823894C287',
    },
    5: {
        fxRoot:            '0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA',
        checkpointManager: '0x2890bA17EfE978480615e330ecB65333b880928e',
    },
    137: {
        fxChild:           '0x8397259c983751DAf40400790063935a11afa28a',
    },
    80001: {
        fxChild:           '0xCf73231F28B7331BBe3124B907840A94851f9f11',
    },
};

async function main () {
    const providers = {}, signers = {}, networks = {}, instances = {};
    providers.root   = ethers.getDefaultProvider(argv.rootChain);
    providers.child  = ethers.getDefaultProvider(argv.childChain);
    signers.root     = ethers.Wallet.fromMnemonic(argv.mnemonic).connect(providers.root);
    signers.child    = ethers.Wallet.fromMnemonic(argv.mnemonic).connect(providers.child);
    networks.root    = await providers.root.getNetwork();
    networks.child   = await providers.child.getNetwork();

    console.log('Root chain: ', networks.root);
    console.log('Child chain:', networks.child);
    console.log('Signer on root chain:  ', signers.root.address);
    console.log('Signer on child chain: ', signers.child.address);
    console.log('Balance on root chain: ', await providers.root.getBalance(signers.root.address).then(ethers.utils.formatEther));
    console.log('Balance on child chain:', await providers.child.getBalance(signers.child.address).then(ethers.utils.formatEther));

    const { fxChild, fxRoot, checkpointManager } = Object.assign({}, ENV[networks.root.chainId], ENV[networks.child.chainId]);
    console.log({ fxChild, fxRoot, checkpointManager });

    instances.root  = await attach('BrigdePolygonRoot',  '0x3b3e8234761e223d0A24C1C9762970DD5E8EFb43', { signer: signers.root  });
    instances.child = await attach('BrigdePolygonChild', '0x5DcC175dc593D835c320264BF2E21aC3CfD5F9e0', { signer: signers.child });
    // instances.root  = await deploy('BrigdePolygonRoot',  [ checkpointManager, fxRoot  ], { signer: signers.root  });
    // instances.child = await deploy('BrigdePolygonChild', [                    fxChild ], { signer: signers.child });
    // await instances.root.setFxChildTunnel(instances.child.address); //.then(tx => tx.wait());
    // await instances.child.setFxRootTunnel(instances.root.address, { gasLimit: 100000 }); //.then(tx => tx.wait());

    expect(await instances.root.fxRoot()           ).to.be.equal(fxRoot);
    expect(await instances.root.checkpointManager()).to.be.equal(checkpointManager);
    expect(await instances.root.fxChildTunnel()    ).to.be.equal(instances.child.address);
    expect(await instances.child.fxChild()         ).to.be.equal(fxChild);
    expect(await instances.child.fxRootTunnel()    ).to.be.equal(instances.root.address);

    console.log("Root: ", instances.root.address);
    console.log("Child:", instances.child.address);

    return;
};


main().catch(console.error);