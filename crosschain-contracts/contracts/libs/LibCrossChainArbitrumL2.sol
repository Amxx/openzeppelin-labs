// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IArbSys as ArbitrumL2_Bridge } from "../global/interfaces/arbitrum/IArbSys.sol";
import "./LibCrossChain.sol";

library LibCrossChainArbitrumL2 {
    function getBridge() internal pure returns (LibCrossChain.Bridge memory result) {
        result._isCrossChain     = isCrossChain;
        result._crossChainSender = crossChainSender;
        result._crossChainCall   = crossChainCall;
        result._bridge           = 0x0000000000000000000000000000000000000064;
    }

    function isCrossChain(address bridge) private view returns (bool) {
        return ArbitrumL2_Bridge(bridge).isTopLevelCall();
    }

    function crossChainSender(address bridge) private view returns (address) {
        return ArbitrumL2_Bridge(bridge).wasMyCallersAddressAliased()
            ? ArbitrumL2_Bridge(bridge).myCallersAddressWithoutAliasing()
            : msg.sender;
    }

    function crossChainCall(address bridge, address target, bytes memory data, uint32 /*gas*/) private returns (bool) {
        ArbitrumL2_Bridge(bridge).sendTxToL1(target, data);
        return true;
    }
}
