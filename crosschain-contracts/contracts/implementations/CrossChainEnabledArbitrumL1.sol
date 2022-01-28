// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../CrossChainEnabled.sol";
import "./libs/LibCrossChainArbitrumL1.sol";

abstract contract CrossChainEnabledArbitrumL1 is CrossChainEnabled {
    ArbitrumL1_Bridge internal immutable bridge;

    constructor(address _bridge) {
        bridge = ArbitrumL1_Bridge(_bridge);
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return LibCrossChainArbitrumL1.isCrossChain(bridge);
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return LibCrossChainArbitrumL1.crossChainSender(bridge);
    }

    function _crossChainCall(address target, bytes memory data, uint32 gas) internal virtual override returns (bool) {
        return LibCrossChainArbitrumL1.crossChainCall(bridge, target, data, gas);
    }
}