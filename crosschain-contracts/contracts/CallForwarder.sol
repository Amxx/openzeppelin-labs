// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./CrossChainEnabled.sol";

abstract contract CallForwarder is Context, AccessControl {
    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER");

    struct Call {
        address target;
        uint256 value;
        bytes   data;
    }

    function execute(Call[] memory calls) public virtual returns (bytes[] memory) {
        require(_isAuthorized(), "Unauthorized call");

        bytes[] memory results = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            results[i] = Address.functionCallWithValue(calls[i].target, calls[i].data, calls[i].value);
        }
        return results;
    }

    function _isAuthorized() internal virtual returns (bool) {
        return hasRole(RELAYER_ROLE, _msgSender());
    }
}

abstract contract CCCallForwarder is CallForwarder, CrossChainEnabled {
    bytes32 public constant CROSSCHAIN_RELAYER_ROLE = keccak256("CROSSCHAIN_RELAYER");

    function _isAuthorized() internal virtual override returns (bool) {
        if (_isCrossChain()) {
            return hasRole(CROSSCHAIN_RELAYER_ROLE, _crossChainSender());
        } else {
            return super._isAuthorized();
        }
    }
}