// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../CrossChainEnabled.sol";
import "./libs/LibCrossChainOptimism.sol";

abstract contract CrossChainEnabledOptimism is CrossChainEnabled {
    Optimism_Bridge internal immutable bridge;

    constructor(address _bridge) {
        bridge = Optimism_Bridge(_bridge);
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return LibCrossChainOptimism.isCrossChain(bridge);
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return LibCrossChainOptimism.crossChainSender(bridge);
    }

    function _crossChainCall(address target, bytes memory data, uint32 gas) internal virtual override returns (bool) {
        return LibCrossChainOptimism.crossChainCall(bridge, target, data, gas);
    }
}