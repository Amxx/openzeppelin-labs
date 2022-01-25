// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./CrossChainEnabled.sol";

// Not cross chain aware: equivalent to a 1 of n multisig
// TODO: emit events
abstract contract CallForwarder is
    Context,
    AccessControl,
    ERC721Holder,
    ERC1155Holder
{
    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER");

    struct Call {
        address target;
        uint256 value;
        bytes   data;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function execute(Call[] memory calls) public virtual returns (bytes[] memory results) {
        require(_isAuthorized(), "Unauthorized call");

        results = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            results[i] = Address.functionCallWithValue(calls[i].target, calls[i].data, calls[i].value);
        }
    }

    function _isAuthorized() internal virtual returns (bool) {
        return hasRole(RELAYER_ROLE, _msgSender());
    }
}

// Cross-chain aware (Full duplex)
// TODO: emit events
abstract contract CrossChainCallForwarder is
    CallForwarder,
    CrossChainEnabled
{
    bytes32 public constant CROSSCHAIN_RELAYER_ROLE = keccak256("CROSSCHAIN_RELAYER");
    bytes32 public constant CROSSCHAIN_EMITTER_ROLE = keccak256("CROSSCHAIN_EMITTER");

    function crossChainExecute(address relayer, Call[] memory calls, uint32 gas) public virtual onlyRole(CROSSCHAIN_EMITTER_ROLE) {
        _crossChainCall(
            relayer,
            abi.encodeWithSelector(CallForwarder.execute.selector, calls),
            gas
        );
    }

    function _isAuthorized() internal virtual override returns (bool) {
        return _isCrossChain()
            ? hasRole(CROSSCHAIN_RELAYER_ROLE, _crossChainSender())
            : super._isAuthorized();
    }
}