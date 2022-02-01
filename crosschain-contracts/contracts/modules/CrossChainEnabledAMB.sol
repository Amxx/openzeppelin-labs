// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibCrossChainAMB.sol";
import "../CrossChainEnabled.sol";

contract CrossChainEnabledAMB is CrossChainEnabled {
    address internal immutable bridge;

    constructor(address _bridge) {
        bridge = _bridge;
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return LibCrossChainAMB.isCrossChain(bridge);
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return LibCrossChainAMB.crossChainSender(bridge);
    }

    function _crossChainCall(address target, bytes memory message, uint32 gasLimit) internal virtual override returns (bool) {
        return LibCrossChainAMB.crossChainCall(bridge, target, message, gasLimit);
    }
}