// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/git/contracts/access/AccessControl.sol";
import "./CrossChainEnabled.sol";

abstract contract AccessControlCrossChain is AccessControl, CrossChainEnabled {
    bytes32 public constant CROSSCHAIN_ALIAS = keccak256("CROSSCHAIN_ALIAS");

    function _checkRole(bytes32 role) internal view virtual override {
        if (_isCrossChain()) {
            _checkRole(role ^ CROSSCHAIN_ALIAS, _crossChainSender());
        } else {
            super._checkRole(role);
        }
    }
}
