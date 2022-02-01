// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibCrossChainOptimism.sol";
import "../CrossChainEnabled.sol";

abstract contract CrossChainEnabledOptimism is CrossChainEnabled {
    address internal immutable bridge;

    constructor(address _bridge) {
        bridge = _bridge;
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return LibCrossChainOptimism.isCrossChain(bridge);
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return LibCrossChainOptimism.crossChainSender(bridge);
    }

    function _crossChainCall(address target, bytes memory message, uint32 gasLimit) internal virtual override returns (bool) {
        return LibCrossChainOptimism.crossChainCall(bridge, target, message, gasLimit);
    }
}