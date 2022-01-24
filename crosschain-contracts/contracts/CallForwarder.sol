// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./CrossChainEnabled.sol";

// Not cross chain aware: equivalent to a 1 of n multisig
// TODO: emit events
// TODO: add token reception hability (ERC721Receiver, ERC1155Receiver)
abstract contract CallForwarder is Context, AccessControl {
    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER");

    struct Call {
        address target;
        uint256 value;
        bytes   data;
    }

    function execute(Call[] memory calls) public virtual onlyRole(RELAYER_ROLE) returns (bytes[] memory results) {
        results = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            results[i] = Address.functionCallWithValue(calls[i].target, calls[i].data, calls[i].value);
        }
    }
}

// Cross-chain aware (Full duplex)
// TODO: emit events
abstract contract CrossChainCallForwarder is CallForwarder, CrossChainEnabled {
    bytes32 public constant CROSSCHAIN_EMITTER_ROLE = keccak256("CROSSCHAIN_EMITTER");

    function crossChainExecute(address relayer, Call[] memory calls, uint32 gas) public virtual onlyRole(CROSSCHAIN_EMITTER_ROLE) {
        _crossChainCall(
            relayer,
            abi.encodeWithSelector(CallForwarder.execute.selector, calls),
            gas
        );
    }

    function _msgSender() internal view virtual override returns (address) {
        return _isCrossChain() ? _crossChainSender() : super._msgSender();
    }
}