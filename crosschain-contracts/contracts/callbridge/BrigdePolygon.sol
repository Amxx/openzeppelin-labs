// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@maticnetwork/fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";
import "@maticnetwork/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";
import "./core/BridgeBase.sol";

contract BrigdePolygonChild is BrigdeBase, FxBaseChildTunnel {
    constructor(address _fxChild)
    FxBaseChildTunnel(_fxChild)
    {}

    function sendMessage(address target, bytes calldata data, uint32) external {
        _sendMessageToRoot(_encodeMessage(msg.sender, target, data));
    }

    function _processMessageFromRoot(uint256 /*stateId*/, address emitter, bytes memory message) internal override validateSender(emitter) {
        (address sender, address target, bytes memory data) = _decodeMessage(message);
        _forward(sender, target, data);
    }
}

contract BrigdePolygonRoot is BrigdeBase, FxBaseRootTunnel {
    constructor(address _checkpointManager, address _fxRoot)
    FxBaseRootTunnel(_checkpointManager, _fxRoot)
    {}

    function sendMessage(address target, bytes calldata data, uint32) external {
        _sendMessageToChild(_encodeMessage(msg.sender, target, data));
    }

    function _processMessageFromChild(bytes memory message) internal override {
        (address sender, address target, bytes memory data) = _decodeMessage(message);
        _forward(sender, target, data);
    }
}