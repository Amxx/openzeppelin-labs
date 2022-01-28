// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibCrossChainPolygon.sol";
import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledPolygon is CrossChainEnabled {
    address internal immutable bridge;

    constructor(address _bridge) {
        bridge = _bridge;
    }

    function _getBridge() internal view virtual override returns (LibCrossChain.Bridge memory result) {
        return LibCrossChainPolygon.getBridge(bridge);
    }
}