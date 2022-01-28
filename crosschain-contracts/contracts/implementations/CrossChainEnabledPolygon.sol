// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../CrossChainEnabled.sol";
import "./libs/LibCrossChainPolygon.sol";

abstract contract CrossChainEnabledPolygon is CrossChainEnabled {
    Polygon_Bridge internal immutable bridge;

    constructor(address _bridge) {
        bridge = Polygon_Bridge(_bridge);
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return LibCrossChainPolygon.isCrossChain(bridge);
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return LibCrossChainPolygon.crossChainSender(bridge);
    }

    function _crossChainCall(address target, bytes memory data, uint32 gas) internal virtual override returns (bool) {
        return LibCrossChainPolygon.crossChainCall(bridge, target, data, gas);
    }
}