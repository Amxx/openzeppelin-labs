// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../modules/CrossChainEnabledAMB.sol";
import "../modules/CrossChainEnabledArbitrumL1.sol";
import "../modules/CrossChainEnabledArbitrumL2.sol";
import "../modules/CrossChainEnabledOptimism.sol";

abstract contract Receiver is CrossChainEnabled {
    event CrossChainCall(address);

    function restricted() external onlyCrossChain() {
        emit CrossChainCall(_crossChainSender());
    }
}

/**
 * AMB
 */
contract CrossChainEnabledAMBMock is Receiver, CrossChainEnabledAMB {
    constructor(address bridge) CrossChainEnabledAMB(bridge) {}
}

/**
 * Arbitrum
 */
contract CrossChainEnabledArbitrumL1Mock is Receiver, CrossChainEnabledArbitrumL1 {
    constructor(address bridge) CrossChainEnabledArbitrumL1(bridge) {}
}
contract CrossChainEnabledArbitrumL2Mock is Receiver, CrossChainEnabledArbitrumL2 {
}

/**
 * Optimism
 */
contract CrossChainEnabledOptimismMock is Receiver, CrossChainEnabledOptimism {
    constructor(address bridge) CrossChainEnabledOptimism(bridge) {}
}