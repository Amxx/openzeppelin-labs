// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledArbitrumL2 is CrossChainEnabled {
    uint160 constant offset = uint160(0x1111000000000000000000000000000000001111);

    function _isCrossChain() internal view virtual override returns (bool) {
        return true; // TODO: can we detect that ?
    }

    function _crossChainSender() internal view virtual override returns (address) {
        return address(uint160(msg.sender) - offset); // TODO: if crosschain, then get L1 by reverting L1toL2Alias
    }
}