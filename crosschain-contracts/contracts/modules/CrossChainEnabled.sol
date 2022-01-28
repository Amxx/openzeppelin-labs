// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibCrossChain.sol";
import "../ICrossChainEnabled.sol";

abstract contract CrossChainEnabled is ICrossChainEnabled {
    using LibCrossChain for LibCrossChain.Bridge;

    function _getBridge() internal view virtual returns (LibCrossChain.Bridge memory);

    function _isCrossChain() internal view virtual override returns (bool) {
        return _getBridge().isCrossChain();
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return _getBridge().crossChainSender();
    }

    function _crossChainCall(address target, bytes memory message, uint32 gasLimit) internal virtual override returns (bool) {
        return _getBridge().crossChainCall(target, message, gasLimit);
    }
}
