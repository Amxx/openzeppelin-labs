// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { ICheckpointManager  } from "@maticnetwork/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";
import { ExitPayloadReader   } from "@maticnetwork/fx-portal/contracts/lib/ExitPayloadReader.sol";
import { RLPReader           } from "@maticnetwork/fx-portal/contracts/lib/RLPReader.sol";
import { MerklePatriciaProof } from "@maticnetwork/fx-portal/contracts/lib/MerklePatriciaProof.sol";
import { Merkle              } from "@maticnetwork/fx-portal/contracts/lib/Merkle.sol";

library PolygonUtils {
    using BitMaps           for BitMaps.BitMap;
    using RLPReader         for RLPReader.RLPItem;
    using Merkle            for bytes32;
    using ExitPayloadReader for bytes;
    using ExitPayloadReader for ExitPayloadReader.ExitPayload;
    using ExitPayloadReader for ExitPayloadReader.Log;
    using ExitPayloadReader for ExitPayloadReader.LogTopics;
    using ExitPayloadReader for ExitPayloadReader.Receipt;

    bytes32 public constant SEND_MESSAGE_EVENT_SIG = 0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036;

    function validateAndExtractMessage(
        ICheckpointManager checkpointManager,
        BitMaps.BitMap storage exits,
        bytes memory inputData
    ) internal returns (address, bytes memory) {
        ExitPayloadReader.ExitPayload memory payload         = inputData.toExitPayload();
        bytes                         memory branchMaskBytes = payload.getBranchMaskAsBytes();
        uint256                              blockNumber     = payload.getBlockNumber();

        // checking if exit has already been processed
        // unique exit is identified using hash of (blockNumber, branchMask, receiptLogIndex)
        uint256 exitHash = uint256(keccak256(abi.encodePacked(
            blockNumber,
            // first 2 nibbles are dropped while generating nibble array
            // this allows branch masks that are valid but bypass exitHash check (changing first 2 nibbles only)
            // so converting to nibble array and then hashing it
            MerklePatriciaProof._getNibbleArray(branchMaskBytes),
            payload.getReceiptLogIndex()
        )));
        require(!exits.get(exitHash), "PolygonUtils: EXIT_ALREADY_PROCESSED");
        exits.set(exitHash);

        ExitPayloadReader.Receipt   memory receipt = payload.getReceipt();
        ExitPayloadReader.Log       memory log     = receipt.getLog();
        ExitPayloadReader.LogTopics memory topics  = log.getTopics();

        // verify event sig
        require(
            bytes32(topics.getField(0).toUint()) == SEND_MESSAGE_EVENT_SIG,
            "PolygonUtils: INVALID_SIGNATURE"
        );

        // verify receipt inclusion
        bytes32 receiptRoot = payload.getReceiptRoot();
        require(
            MerklePatriciaProof.verify(receipt.toBytes(), branchMaskBytes, payload.getReceiptProof(), receiptRoot),
            "PolygonUtils: INVALID_RECEIPT_PROOF"
        );

        // verify checkpoint inclusion
        (bytes32 headerRoot, uint256 startBlock,,,) = checkpointManager.headerBlocks(payload.getHeaderNumber());
        require(
            keccak256(abi.encodePacked(
                blockNumber,
                payload.getBlockTime(),
                payload.getTxRoot(),
                receiptRoot
            )).checkMembership(
                blockNumber - startBlock,
                headerRoot,
                payload.getBlockProof()
            ),
            "FxRootTunnel: INVALID_HEADER"
        );

        address emitter = log.getEmitter();
        bytes memory data = abi.decode(log.getData(), (bytes)); // event decodes params again, so decoding bytes to get message
        return (emitter, data);
    }
}
