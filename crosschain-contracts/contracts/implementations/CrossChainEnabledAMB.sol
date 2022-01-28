// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../CrossChainEnabled.sol";
import "./libs/LibCrossChainAMB.sol";

abstract contract CrossChainEnabledAMB is CrossChainEnabled {
    AMB_Bridge internal immutable bridge;

    constructor(address _bridge) {
        bridge = AMB_Bridge(_bridge);
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return LibCrossChainAMB.isCrossChain(bridge);
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return LibCrossChainAMB.crossChainSender(bridge);
    }

    function _crossChainCall(address target, bytes memory data, uint32 gas) internal virtual override returns (bool) {
        return LibCrossChainAMB.crossChainCall(bridge, target, data, gas);
    }
}