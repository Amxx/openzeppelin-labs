// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibCrossChainArbitrumL2.sol";
import "../CrossChainEnabled.sol";

abstract contract CrossChainEnabledArbitrumL2 is CrossChainEnabled {
    function _isCrossChain() internal view virtual override returns (bool) {
        return LibCrossChainArbitrumL2.isCrossChain(address(LibCrossChainArbitrumL2.ARBSYS));
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return LibCrossChainArbitrumL2.crossChainSender(address(LibCrossChainArbitrumL2.ARBSYS));
    }

    function _crossChainCall(address target, bytes memory message, uint32 gasLimit) internal virtual override returns (bool) {
        return LibCrossChainArbitrumL2.crossChainCall(address(LibCrossChainArbitrumL2.ARBSYS), target, message, gasLimit);
    }
}