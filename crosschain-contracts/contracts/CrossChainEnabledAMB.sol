// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IAMB.sol";
import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledAMB is CrossChainEnabled {
    address internal immutable amb;

    constructor(address _amb) {
        amb = _amb;
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return msg.sender == amb;
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return IAMB(amb).messageSender();
    }

    function _crossChainCall(address target, bytes memory data, uint256 gas) internal virtual override returns (bool) {
        require(IAMB(amb).maxGasPerTx() <= gas);
        IAMB(amb).requireToPassMessage(target, data, gas);
        return true;
    }
}