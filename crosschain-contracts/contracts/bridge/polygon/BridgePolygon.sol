// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@maticnetwork/fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";
import "@maticnetwork/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";

interface IBridge {
    function messageSender() external view returns (address);
    function sendMessage(address target, bytes memory data) external;
}

abstract contract BrigdeBase is IBridge {
    address public messageSender;

    function _encodeMessage(address sender, address target, bytes memory data) internal pure returns (bytes memory message) {
        message = abi.encode(sender, target, data);
    }

    function _decodeMessage(bytes memory message) internal pure returns (address sender, address target, bytes memory data) {
        (sender, target, data) = abi.decode(message, (address, address, bytes));
    }

    function _forward(address sender, address target, bytes memory call) internal {
        messageSender = sender;
        Address.functionCall(target, call);
        messageSender = address(0);
    }
}

contract BrigdePolygonL1 is BrigdeBase, FxBaseRootTunnel {
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

contract BrigdePolygonL2 is BrigdeBase, FxBaseChildTunnel {
    constructor(address _fxChild)
    FxBaseChildTunnel(_fxChild)
    {}

    function sendMessage(address target, bytes calldata data) external {
        _sendMessageToRoot(_encodeMessage(msg.sender, target, data));
    }

    function _processMessageFromRoot(uint256 /*stateId*/, address emitter, bytes memory message) internal override validateSender(emitter) {
        (address sender, address target, bytes memory data) = _decodeMessage(message);
        _forward(sender, target, data);
    }

}