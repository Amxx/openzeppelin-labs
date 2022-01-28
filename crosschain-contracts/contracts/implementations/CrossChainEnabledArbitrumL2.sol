// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../CrossChainEnabled.sol";
import "./libs/LibCrossChainArbitrumL2.sol";

abstract contract CrossChainEnabledArbitrumL2 is CrossChainEnabled {
    function _isCrossChain() internal view virtual override returns (bool) {
        return LibCrossChainArbitrumL2.isCrossChain();
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return LibCrossChainArbitrumL2.crossChainSender();
    }

    function _crossChainCall(address target, bytes memory data, uint32 gas) internal virtual override returns (bool) {
        return LibCrossChainArbitrumL2.crossChainCall(target, data, gas);
    }
}
