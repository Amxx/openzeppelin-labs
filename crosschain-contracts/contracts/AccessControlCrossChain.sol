// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./CrossChainEnabled.sol";

abstract contract AccessControlCrossChain is AccessControl, CrossChainEnabled {
    bytes32 public constant CROSSCHAIN_ALIAS = keccak256("CROSSCHAIN_ALIAS");

    // TODO: this should override the existing implementation to alter the onlyRole modifier
    function _checkRole(bytes32 role) internal view virtual /*override*/ {
        bool isCrossChain = _isCrossChain();
        _checkRole(
            isCrossChain ? (role ^ CROSSCHAIN_ALIAS) : role,
            isCrossChain ? _crossChainSender() : _msgSender()
        );
    }
}
