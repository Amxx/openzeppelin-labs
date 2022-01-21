// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/IFxMessageProcessor.sol";
import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledPolygonL2 is CrossChainEnabled, IFxMessageProcessor {
    address internal immutable fxChild;
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