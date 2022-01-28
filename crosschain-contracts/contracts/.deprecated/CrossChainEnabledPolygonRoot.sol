// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@maticnetwork/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";
import "./utils/PolygonUtils.sol";
import "../CrossChainEnabled.sol";

abstract contract CrossChainEnabledPolygonRoot is CrossChainEnabled {
    using BitMaps           for BitMaps.BitMap;
    using RLPReader         for RLPReader.RLPItem;
    using ExitPayloadReader for bytes;
    using ExitPayloadReader for ExitPayloadReader.ExitPayload;
    using ExitPayloadReader for ExitPayloadReader.Log;
    using ExitPayloadReader for ExitPayloadReader.LogTopics;
    using ExitPayloadReader for ExitPayloadReader.Receipt;
    using PolygonUtils      for ExitPayloadReader.ExitPayload;

    bytes32 internal constant EVENT_SIG = keccak256('CrossChainMessage(address,bytes)');

    IFxStateSender     public immutable fxRoot;
    ICheckpointManager public immutable checkpointManager;
    BitMaps.BitMap     private _processedExits;
    address            private __crossChainSender;
    address            private __crossChainRelayer;

    constructor(address _fxRoot, address _checkpointManager) {
        fxRoot = IFxStateSender(_fxRoot);
        checkpointManager = ICheckpointManager(_checkpointManager);
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return __crossChainRelayer == msg.sender && __crossChainSender != address(0);
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return __crossChainSender;
    }

    function _crossChainCall(address target, bytes memory data, uint32 /*gas*/) internal virtual override returns (bool) {
        IFxStateSender(fxRoot).sendMessageToChild(target, data);
        return true;
    }

    function receiveMessage(bytes memory inputData) public virtual {
        ExitPayloadReader.ExitPayload memory payload = inputData.toExitPayload();

        // check double exit & receipt validity & receipt inclusion
        uint256 exitHash = uint256(payload.getExitHash());
        require(!_processedExits.get(exitHash),                      "CrossChainEnabledPolygonRoot: EXIT_ALREADY_PROCESSED");
        require(payload.verifyReceiptInclusion(),                    "CrossChainEnabledPolygonRoot: INVALID_RECEIPT_PROOF");
        require(payload.verifyCheckpointInclusion(checkpointManager),"CrossChainEnabledPolygonRoot: INVALID_HEADER");
        _processedExits.set(exitHash);

        // get log & topics
        ExitPayloadReader.Log       memory log    = payload.getReceipt().getLog();
        ExitPayloadReader.LogTopics memory topics = log.getTopics();

        // check event validity
        require(topics.getField(0).toUint()    == uint256(EVENT_SIG), "CrossChainEnabledPolygonRoot: INVALID_EVENT_SIG");
        require(topics.getField(1).toAddress() == address(this),      "CrossChainEnabledPolygonRoot: INVALID_SENDER");
        bytes memory data = abi.decode(log.getData(), (bytes));

        __crossChainSender  = log.getEmitter();
        __crossChainRelayer = msg.sender;
        Address.functionDelegateCall(address(this), data);
        __crossChainSender  = address(0);
        __crossChainRelayer = address(0); // maybe we shouldn't clean that to improve gas usage
    }
}
