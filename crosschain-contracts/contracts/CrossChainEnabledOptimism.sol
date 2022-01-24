// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledOptimism is CrossChainEnabled {
    address internal immutable crossdomainmessenger;

    constructor(address _crossdomainmessenger) {
        crossdomainmessenger = _crossdomainmessenger;
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return msg.sender == crossdomainmessenger;
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return ICrossDomainMessenger(crossdomainmessenger).xDomainMessageSender();
    }

    function _crossChainCall(address target, bytes memory data, uint32 gas) internal virtual override returns (bool) {
        ICrossDomainMessenger(crossdomainmessenger).sendMessage(target, data, gas);
        return true;
    }
}