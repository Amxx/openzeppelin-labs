// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@maticnetwork/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";
import "./CrossChainEnabled.sol";
import "./utils/PolygonUtils.sol";

abstract contract CrossChainEnabledPolygonL1 is CrossChainEnabled {
    // keccak256(MessageSent(bytes))
    IFxStateSender     public immutable fxRoot;
    ICheckpointManager public immutable checkpointManager;
    BitMaps.BitMap     private _processedExits;
    address            private __crossChainSender;

    constructor(address _fxRoot, address _checkpointManager) {
        fxRoot = IFxStateSender(_fxRoot);
        checkpointManager = ICheckpointManager(_checkpointManager);
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return __crossChainSender != address(0); // reentrancy can break that, should receiveMessage store something else?
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return __crossChainSender;
    }

    function _crossChainCall(address target, bytes memory data, uint32 /*gas*/) internal virtual override returns (bool) {
        IFxStateSender(fxRoot).sendMessageToChild(target, data);
        return true;
    }

    function receiveMessage(bytes memory inputData) public virtual {
        (address sender, bytes memory message) = PolygonUtils.validateAndExtractMessage(checkpointManager, _processedExits, inputData);
        (address target, bytes memory data   ) = abi.decode(message, (address, bytes));
        require(target == address(this));
        __crossChainSender = sender;
        Address.functionDelegateCall(address(this), data);
        __crossChainSender = address(0);
    }
}