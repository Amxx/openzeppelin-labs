// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./bridge/polygon/IBridge.sol";
import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledPolygon is CrossChainEnabled {
    address internal immutable bridge;

    constructor(address _bridge) {
        bridge = _bridge;
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return msg.sender == bridge;
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return IBridge(bridge).messageSender();
    }

    function _crossChainCall(address target, bytes memory data, uint32 /*gas*/) internal virtual override returns (bool) {
        IBridge(bridge).sendMessage(target, data);
        return true;
    }
}