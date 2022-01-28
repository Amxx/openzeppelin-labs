// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibCrossChainArbitrumL2.sol";
import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledArbitrumL1 is CrossChainEnabled {
    address internal immutable bridge;

    constructor(address _bridge) {
        bridge = _bridge;
    }

    function _getBridge() internal view virtual override returns (LibCrossChain.Bridge memory result) {
        return LibCrossChainArbitrumL2.getBridge();
    }
}