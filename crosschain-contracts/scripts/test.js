const { ethers } = require('hardhat');
const { expect } = require('chai');
const { attach, deploy } = require('@amxx/hre/scripts');


const wait = (ms = 1000) => new Promise(resolve => setTimeout(resolve, ms));


const ADDRESSES = {
    "Lib_AddressManager":                '0x5FbDB2315678afecb367f032d93F642f64180aa3', /* L1 & L2 */
    "ChainStorageContainer-CTC-batches": '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512', /* L1      */
    "ChainStorageContainer-SCC-batches": '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0', /* L1      */
    "CanonicalTransactionChain":         '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9', /* L1 & L2 */
    "StateCommitmentChain":              '0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9', /* L1      */
    "BondManager":                       '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707', /* L1      */
    "OVM_L1CrossDomainMessenger":        '0x0165878A594ca255338adfa4d48449f69242Eb8F', /* L1 & L2 */
    "Proxy__OVM_L1CrossDomainMessenger": '0x8A791620dd6260079BF849Dc5567aDC3F2FdC318', /* L1 & L2 */
    "Proxy__OVM_L1StandardBridge":       '0x610178dA211FEF7D417bC0e6FeD39F05609AD788', /* L1      */
    "AddressDictator":                   '0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e', /* L1      */
    "L2CrossDomainMessenger":            '0x4200000000000000000000000000000000000007', /*      L2 */
    "OVM_Sequencer":                     '0x70997970C51812dc3A010C7d01b50e0d17dc79C8', /*         */
    "OVM_Proposer":                      '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC', /*         */
    "ChugSplashDictator":                '0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1', /* L1      */
}


const MNEMONIC     = 'test test test test test test test test test test test junk';
const RELAYER_ROLE = ethers.utils.id('RELAYER_ROLE');
const L1           = {};
const L2           = {};


async function main () {
    L1.provider  = ethers.getDefaultProvider('http://127.0.0.1:9545');
    L2.provider  = ethers.getDefaultProvider('http://127.0.0.1:8545');
    L1.signer    = ethers.Wallet.fromMnemonic(MNEMONIC).connect(L1.provider);
    L2.signer    = ethers.Wallet.fromMnemonic(MNEMONIC).connect(L2.provider);
    L1.messenger = await attach('L1CrossDomainMessenger',    ADDRESSES.Proxy__OVM_L1CrossDomainMessenger,  { signer: L1.signer });
    L2.messenger = await attach('L2CrossDomainMessenger',    ADDRESSES.L2CrossDomainMessenger,             { signer: L2.signer });
    L1.manager   = await attach('Lib_AddressManager',        ADDRESSES.Lib_AddressManager,                 { signer: L1.signer });
    L1.canonical = await attach('CanonicalTransactionChain', ADDRESSES.CanonicalTransactionChain,          { signer: L1.signer });

    L1.instance  = await attach('RelayOptimism',             '0x04C89607413713Ec9775E14b954286519d836FEf', { signer: L1.signer });
    L2.instance  = await attach('RelayOptimism',             '0xc3e53F4d16Ae77Db1c982e75a937B9f60FE63690', { signer: L2.signer });

    const blocksBefore = await Promise.all([
        L1.provider.getBlock(),
        L2.provider.getBlock(),
    ]);

    const target = '0x7859821024E633C5dC8a4FcF86fC52e7720Ce525';
    const value  = 0;
    const data   = '0x';
    const gas    = 1_000_000;

    await L1.instance.sendCrossChainTx(target, value, data, gas, { gasLimit: 1000000 })
    await wait(10000);

    const blocksAfter = await Promise.all([
        L1.provider.getBlock(),
        L2.provider.getBlock(),
    ]);

    console.log(blocksBefore.map(({ number }) => number));
    console.log(blocksAfter.map(({ number }) => number));

    const receiptsL1 = await Promise.all(blocksAfter[0].transactions.map(transaction => L1.provider.getTransaction(transaction).then(tx => tx.wait())));
    const receiptsL2 = await Promise.all(blocksAfter[1].transactions.map(transaction => L2.provider.getTransaction(transaction).then(tx => tx.wait())));

    const eventsL1 = [].concat(
        ...receiptsL1.map(({ logs }) => logs.filter(({ address }) => address === L1.messenger.address).map(ev => L1.messenger.interface.parseLog(ev))),
        ...receiptsL1.map(({ logs }) => logs.filter(({ address }) => address === L1.instance.address ).map(ev => L1.instance.interface.parseLog(ev))),
    );
    const eventsL2 = [].concat(
        ...receiptsL2.map(({ logs }) => logs.filter(({ address }) => address === L2.messenger.address).map(ev => L2.messenger.interface.parseLog(ev))),
        ...receiptsL2.map(({ logs }) => logs.filter(({ address }) => address === L2.instance.address ).map(ev => L2.instance.interface.parseLog(ev))),
    );

    console.log(eventsL1);
    console.log(eventsL2);
};


main();