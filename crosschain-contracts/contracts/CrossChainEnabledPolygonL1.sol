// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@maticnetwork/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";
import "@maticnetwork/fx-portal/contracts/lib/ExitPayloadReader.sol";
import { RLPReader           } from "@maticnetwork/fx-portal/contracts/lib/RLPReader.sol";
import { MerklePatriciaProof } from "@maticnetwork/fx-portal/contracts/lib/MerklePatriciaProof.sol";
import { Merkle              } from "@maticnetwork/fx-portal/contracts/lib/Merkle.sol";
import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledPolygonL1 is CrossChainEnabled {
    using RLPReader for RLPReader.RLPItem;
    using Merkle for bytes32;
    using ExitPayloadReader for bytes;
    using ExitPayloadReader for ExitPayloadReader.ExitPayload;
    using ExitPayloadReader for ExitPayloadReader.Log;
    using ExitPayloadReader for ExitPayloadReader.LogTopics;
    using ExitPayloadReader for ExitPayloadReader.Receipt;

    // keccak256(MessageSent(bytes))
    bytes32            public constant  SEND_MESSAGE_EVENT_SIG = 0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036;
    IFxStateSender     public immutable fxRoot;
    ICheckpointManager public immutable checkpointManager;
    mapping(bytes32 => bool) public processedExits;

    address private __crossChainSender;

    constructor(address _fxRoot, address _checkpointManager) {
        fxRoot = IFxStateSender(_fxRoot);
        checkpointManager = ICheckpointManager(_checkpointManager);
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        revert();
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        revert();
    }

    function _crossChainCall(address target, bytes memory data, uint32 /*gas*/) internal virtual override returns (bool) {
        IFxStateSender(fxRoot).sendMessageToChild(target, data);
        return true;
    }

    function receiveMessage(bytes memory inputData) public virtual {
        (address sender, bytes memory message) = _validateAndExtractMessage(inputData);
        (address target, bytes memory data)    = abi.decode(message, (address, bytes));
        require(target == address(this));
        __crossChainSender = sender;
        Address.functionDelegateCall(address(this), data);
        __crossChainSender = address(0);
    }

    function _validateAndExtractMessage(bytes memory inputData) internal returns (address, bytes memory) {
        ExitPayloadReader.ExitPayload memory payload = inputData.toExitPayload();

        bytes memory branchMaskBytes = payload.getBranchMaskAsBytes();
        uint256 blockNumber = payload.getBlockNumber();
        // checking if exit has already been processed
        // unique exit is identified using hash of (blockNumber, branchMask, receiptLogIndex)
        bytes32 exitHash = keccak256(
            abi.encodePacked(
                blockNumber,
                // first 2 nibbles are dropped while generating nibble array
                // this allows branch masks that are valid but bypass exitHash check (changing first 2 nibbles only)
                // so converting to nibble array and then hashing it
                MerklePatriciaProof._getNibbleArray(branchMaskBytes),
                payload.getReceiptLogIndex()
            )
        );
        require(processedExits[exitHash] == false, "FxRootTunnel: EXIT_ALREADY_PROCESSED");
        processedExits[exitHash] = true;

        ExitPayloadReader.Receipt memory receipt = payload.getReceipt();
        ExitPayloadReader.Log memory log = receipt.getLog();

        bytes32 receiptRoot = payload.getReceiptRoot();
        // verify receipt inclusion
        require(
            MerklePatriciaProof.verify(receipt.toBytes(), branchMaskBytes, payload.getReceiptProof(), receiptRoot),
            "FxRootTunnel: INVALID_RECEIPT_PROOF"
        );

        // verify checkpoint inclusion
        _checkBlockMembershipInCheckpoint(
            blockNumber,
            payload.getBlockTime(),
            payload.getTxRoot(),
            receiptRoot,
            payload.getHeaderNumber(),
            payload.getBlockProof()
        );

        ExitPayloadReader.LogTopics memory topics = log.getTopics();

        require(
            bytes32(topics.getField(0).toUint()) == SEND_MESSAGE_EVENT_SIG, // topic0 is event sig
            "FxRootTunnel: INVALID_SIGNATURE"
        );

        address emitter = log.getEmitter();
        bytes memory data = abi.decode(log.getData(), (bytes)); // event decodes params again, so decoding bytes to get message
        return (emitter, data);
    }

    function _checkBlockMembershipInCheckpoint(
        uint256 blockNumber,
        uint256 blockTime,
        bytes32 txRoot,
        bytes32 receiptRoot,
        uint256 headerNumber,
        bytes memory blockProof
    ) private view returns (uint256) {
        (
            bytes32 headerRoot,
            uint256 startBlock,
            ,
            uint256 createdAt,
        ) = checkpointManager.headerBlocks(headerNumber);

        require(
            keccak256(
                abi.encodePacked(blockNumber, blockTime, txRoot, receiptRoot)
            ).checkMembership(
                blockNumber-startBlock,
                headerRoot,
                blockProof
            ),
            "FxRootTunnel: INVALID_HEADER"
        );
        return createdAt;
    }
}