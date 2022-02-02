// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IBridge as ArbitrumL1_Bridge } from "../global/interfaces/arbitrum/IBridge.sol";
import { IInbox  as ArbitrumL1_Inbox  } from "../global/interfaces/arbitrum/IInbox.sol";
import { IOutbox as ArbitrumL1_Outbox } from "../global/interfaces/arbitrum/IOutbox.sol";
import "./LibCrossChain.sol";

error InsuficientFunds();

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
        return crossChainCallWithValue(bridge, target, 0, data, gas);
    }

    function crossChainCallWithValue(address bridge, address target, uint256 value, bytes memory data, uint32 gas) internal returns (bool) {
        uint256 submissionCost = crossChainCallCost(bridge, target, data, gas);
        return createRetryableTicket(
            bridge,
            target,
            value,
            data,
            address(this),
            gas,
            0,
            submissionCost,
            submissionCost + value
        );
    }

    /**
     * This low level mechanism can be used to drain the funds that would accumulate
     * on L2 (at the aliased address), due to over-estimation of the submission cost.
     */
    function createRetryableTicket(
        address      bridge,
        address      target,
        uint256      value,
        bytes memory data,
        address      refund,
        uint32       gas,
        uint256      gasPriceBid,
        uint256      submissionCost,
        uint256      l1Value
    ) internal returns (bool) {
        if (address(this).balance < l1Value) {
            revert InsuficientFunds();
        }

        ArbitrumL1_Inbox(bridge).createRetryableTicket{ value: l1Value }(
            target,         // destAddr
            value,          // arbTxCallValue
            submissionCost, // maxSubmissionCost
            refund,         // submissionRefundAddress
            refund,         // valueRefundAddress
            gas,            // maxGas
            gasPriceBid,    // gasPriceBid
            data            // data
        );

        return true;
    }

    function crossChainCallCost(address /*bridge*/, address /*target*/, bytes memory data, uint32 /*gas*/) internal view returns (uint256) {
        return (block.basefee * 3 / 2) * (1 + data.length / 256); // take 50% margin over basefee ?
    }
}
