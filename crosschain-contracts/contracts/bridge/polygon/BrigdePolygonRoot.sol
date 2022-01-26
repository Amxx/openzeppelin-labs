// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@maticnetwork/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";
import "./BridgeBase.sol";

contract BrigdePolygonRoot is BrigdeBase, FxBaseRootTunnel {
    constructor(address _checkpointManager, address _fxRoot)
    FxBaseRootTunnel(_checkpointManager, _fxRoot)
    {}

    function sendMessage(address target, bytes calldata data) external {
        _sendMessageToChild(_encodeMessage(msg.sender, target, data));
    }

    function _processMessageFromChild(bytes memory message) internal override {
        (address sender, address target, bytes memory data) = _decodeMessage(message);
        _forward(sender, target, data);
    }
}