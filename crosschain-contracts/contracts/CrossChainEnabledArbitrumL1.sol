// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/arbitrum/IBridge.sol";
import "./interfaces/arbitrum/IInbox.sol";
import "./interfaces/arbitrum/IOutbox.sol";
import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledArbitrumL1 is CrossChainEnabled {
    address internal immutable inbox;

    constructor(address _inbox) {
        inbox = _inbox;
    }

    function _isCrossChain() internal view virtual override returns (bool) {
        return msg.sender == IInbox(inbox).bridge();
    }

    function _crossChainSender() internal view virtual override returns (address) {
        address bridge = IInbox(inbox).bridge();
        if (msg.sender != bridge) revert NotCrossChainCall();
        return IOutbox(IBridge(bridge).activeOutbox()).l2ToL1Sender();
    }
}