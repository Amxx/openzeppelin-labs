// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./AccessControlCrossChain.sol";

struct Call { address target; uint256 value; bytes data; }

// Not cross chain aware: equivalent to a 1 of n multisig
// TODO: emit events
abstract contract CallForwarder is AccessControl, ERC721Holder, ERC1155Holder {
    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");

    receive() external payable {}

    function execute(Call[] memory calls) public virtual onlyRole(RELAYER_ROLE) returns (bytes[] memory results) {
        results = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            results[i] = Address.functionCallWithValue(calls[i].target, calls[i].data, calls[i].value);
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

// Cross-chain aware (Full duplex)
// TODO: emit events
abstract contract CrossChainCallForwarder is CallForwarder, AccessControlCrossChain {
    bytes32 public constant EMITTER_ROLE = keccak256("EMITTER_ROLE");
    bytes32 public constant CROSSCHAIN_RELAYER_ROLE = RELAYER_ROLE ^ CROSSCHAIN_ALIAS;
    bytes32 public constant CROSSCHAIN_EMITTER_ROLE = EMITTER_ROLE ^ CROSSCHAIN_ALIAS;

    function crossChainExecute(address relayer, Call[] memory calls, uint32 gas) public virtual onlyRole(EMITTER_ROLE) {
        _crossChainCall(
            relayer,
            abi.encodeWithSelector(CallForwarder.execute.selector, calls),
            gas
        );
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(CallForwarder, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}