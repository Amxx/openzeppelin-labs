// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@maticnetwork/fx-portal/contracts/FxChild.sol";
import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledPolygonL2 is CrossChainEnabled, IFxMessageProcessor {
    // MessageTunnel on L1 will get data from this event
    event MessageSent(bytes message);

    address public immutable fxChild;
    address private __crossChainSender;

    constructor(address _fxChild) {
        fxChild = _fxChild;
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return msg.sender == fxChild;
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return __crossChainSender;
    }

    function _crossChainCall(address target, bytes memory data, uint32 /*gas*/) internal virtual override returns (bool) {
        emit MessageSent(abi.encode(target, data));
        return true;
    }

    function processMessageFromRoot(
        uint256 /*stateId*/,
        address rootMessageSender,
        bytes calldata data
    ) external virtual onlyCrossChain() {
        __crossChainSender = rootMessageSender;
        Address.functionDelegateCall(address(this), data);
        __crossChainSender = address(0);
    }
}