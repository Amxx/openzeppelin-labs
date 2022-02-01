// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibCrossChainArbitrumL1.sol";
import "../CrossChainEnabled.sol";

abstract contract CrossChainEnabledArbitrumL1 is CrossChainEnabled {
    address internal immutable bridge;

    constructor(address _bridge) {
        bridge = _bridge;
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return LibCrossChainArbitrumL1.isCrossChain(bridge);
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return LibCrossChainArbitrumL1.crossChainSender(bridge);
    }

    function _crossChainCall(address target, bytes memory message, uint32 gasLimit) internal virtual override returns (bool) {
        return LibCrossChainArbitrumL1.crossChainCall(bridge, target, message, gasLimit);
    }
}