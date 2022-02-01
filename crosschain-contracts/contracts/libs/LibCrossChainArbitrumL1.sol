// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IBridge as ArbitrumL1_Bridge } from "../global/interfaces/arbitrum/IBridge.sol";
import { IInbox  as ArbitrumL1_Inbox  } from "../global/interfaces/arbitrum/IInbox.sol";
import { IOutbox as ArbitrumL1_Outbox } from "../global/interfaces/arbitrum/IOutbox.sol";
import "./LibCrossChain.sol";

library LibCrossChainArbitrumL1 {
    function getBridge(address inbox) internal pure returns (LibCrossChain.Bridge memory result) {
        result._isCrossChain     = isCrossChain;
        result._crossChainSender = crossChainSender;
        result._crossChainCall   = crossChainCall;
        result._endpoint         = inbox;
    }

    function isCrossChain(address inbox) internal view returns (bool) {
        return msg.sender == ArbitrumL1_Inbox(inbox).bridge();
    }

    function crossChainSender(address inbox) internal view returns (address) {
        return ArbitrumL1_Outbox(ArbitrumL1_Bridge(ArbitrumL1_Inbox(inbox).bridge()).activeOutbox()).l2ToL1Sender();
    }

    function crossChainCall(address bridge, address target, bytes memory data, uint32 gas) internal returns (bool) {
        ArbitrumL1_Inbox(bridge).sendContractTransaction(
            gas,
            0, // gasPriceBid
            target,
            0,
            data
        );
        return true;
    }
}
