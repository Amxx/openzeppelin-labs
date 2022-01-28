// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IBridge as ArbitrumL1_Bridge } from "../../global/interfaces/arbitrum/IBridge.sol";
import { IInbox  as ArbitrumL1_Inbox  } from "../../global/interfaces/arbitrum/IInbox.sol";
import { IOutbox as ArbitrumL1_Outbox } from "../../global/interfaces/arbitrum/IOutbox.sol";

library LibCrossChainArbitrumL1 {
    function isCrossChain(ArbitrumL1_Bridge bridge) internal view returns (bool) {
        return msg.sender == address(bridge);
    }

    function crossChainSender(ArbitrumL1_Bridge bridge) internal view returns (address) {
        return ArbitrumL1_Outbox(bridge.activeOutbox()).l2ToL1Sender();
    }

    function crossChainCall(ArbitrumL1_Bridge /*bridge*/, address /*target*/, bytes memory /*data*/, uint32 /*gas*/) internal pure returns (bool) {
        revert("not-implemented-yet");
    }
}
