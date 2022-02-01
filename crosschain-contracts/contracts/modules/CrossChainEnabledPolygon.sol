// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibCrossChainPolygon.sol";
import "../CrossChainEnabled.sol";

abstract contract CrossChainEnabledPolygon is CrossChainEnabled {
    address internal immutable bridge;

    constructor(address _bridge) {
        bridge = _bridge;
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return LibCrossChainPolygon.isCrossChain(bridge);
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return LibCrossChainPolygon.crossChainSender(bridge);
    }

    function _crossChainCall(address target, bytes memory message, uint32 gasLimit) internal virtual override returns (bool) {
        return LibCrossChainPolygon.crossChainCall(bridge, target, message, gasLimit);
    }
}