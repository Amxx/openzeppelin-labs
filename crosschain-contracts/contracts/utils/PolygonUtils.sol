// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { ICheckpointManager  } from "@maticnetwork/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";
import { ExitPayloadReader   } from "@maticnetwork/fx-portal/contracts/lib/ExitPayloadReader.sol";
import { Merkle              } from "@maticnetwork/fx-portal/contracts/lib/Merkle.sol";
import { MerklePatriciaProof } from "@maticnetwork/fx-portal/contracts/lib/MerklePatriciaProof.sol";

/**
 * @dev Inspired by @maticnetwork/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol:FxBaseRootTunnel
 */
library PolygonUtils {
    using ExitPayloadReader for ExitPayloadReader.ExitPayload;
    using ExitPayloadReader for ExitPayloadReader.Receipt;

    // unique exit is identified using hash of (blockNumber, branchMask, receiptLogIndex)
    function getExitHash(ExitPayloadReader.ExitPayload memory payload) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            payload.getBlockNumber(),
            // first 2 nibbles are dropped while generating nibble array
            // this allows branch masks that are valid but bypass exitHash check (changing first 2 nibbles only)
            // so converting to nibble array and then hashing it
            MerklePatriciaProof._getNibbleArray(payload.getBranchMaskAsBytes()),
            payload.getReceiptLogIndex()
        ));
    }

    function verifyReceiptInclusion(ExitPayloadReader.ExitPayload memory payload) internal pure returns (bool) {
        return MerklePatriciaProof.verify(
            payload.getReceipt().toBytes(),
            payload.getBranchMaskAsBytes(),
            payload.getReceiptProof(),
            payload.getReceiptRoot()
        );
    }

    function verifyCheckpointInclusion(ExitPayloadReader.ExitPayload memory payload, ICheckpointManager checkpointManager) internal view returns (bool) {
        (bytes32 headerRoot, uint256 startBlock,,,) = checkpointManager.headerBlocks(payload.getHeaderNumber());
        uint256 blockNumber = payload.getBlockNumber();

        return Merkle.checkMembership(
            keccak256(abi.encodePacked(
                blockNumber,
                payload.getBlockTime(),
                payload.getTxRoot(),
                payload.getReceiptRoot()
            )),
            blockNumber - startBlock,
            headerRoot,
            payload.getBlockProof()
        );
    }
}
