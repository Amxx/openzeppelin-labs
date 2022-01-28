// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IBridge as ArbitrumL1_Bridge } from "../global/interfaces/arbitrum/IBridge.sol";
import { IInbox  as ArbitrumL1_Inbox  } from "../global/interfaces/arbitrum/IInbox.sol";
import { IOutbox as ArbitrumL1_Outbox } from "../global/interfaces/arbitrum/IOutbox.sol";
import "./LibCrossChain.sol";

library LibCrossChainArbitrumL1 {
    function getBridge(address bridge) internal pure returns (LibCrossChain.Bridge memory result) {
        result._isCrossChain     = isCrossChain;
        result._crossChainSender = crossChainSender;
        result._crossChainCall   = crossChainCall;
        result._bridge           = bridge;
    }

    function isCrossChain(address bridge) private view returns (bool) {
        return msg.sender == bridge;
    }

    function crossChainSender(address bridge) private view returns (address) {
        return ArbitrumL1_Outbox(ArbitrumL1_Bridge(bridge).activeOutbox()).l2ToL1Sender();
    }

    function crossChainCall(address /*bridge*/, address /*target*/, bytes memory /*data*/, uint32 /*gas*/) private pure returns (bool) {
        revert("not-implemented-yet");
    }
}
