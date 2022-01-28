// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibCrossChainOptimism.sol";
import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledOptimism is CrossChainEnabled {
    address internal immutable bridge;

    constructor(address _bridge) {
        bridge = _bridge;
    }

    function _getBridge() internal view virtual override returns (LibCrossChain.Bridge memory result) {
        return LibCrossChainOptimism.getBridge(bridge);
    }
}