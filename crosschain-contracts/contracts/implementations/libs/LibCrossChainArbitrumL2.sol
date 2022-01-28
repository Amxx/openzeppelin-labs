// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IArbSys as ArbitrumL2_Bridge } from "../../global/interfaces/arbitrum/IArbSys.sol";

library LibCrossChainArbitrumL2 {
    function isCrossChain(ArbitrumL2_Bridge bridge) internal view returns (bool) {
        return bridge.isTopLevelCall();
    }

    function crossChainSender(ArbitrumL2_Bridge bridge) internal view returns (address) {
        return bridge.wasMyCallersAddressAliased()
            ? bridge.myCallersAddressWithoutAliasing()
            : msg.sender;
    }

    function crossChainCall(ArbitrumL2_Bridge bridge, address target, bytes memory data, uint32 /*gas*/) internal returns (bool) {
        bridge.sendTxToL1(target, data);
        return true;
    }

    // Override arbsys
    ArbitrumL2_Bridge internal constant ARBSYS = ArbitrumL2_Bridge(0x0000000000000000000000000000000000000064);

    function isCrossChain() internal view returns (bool) {
        return isCrossChain(ARBSYS);
    }

    function crossChainSender() internal view returns (address) {
        return crossChainSender(ARBSYS);
    }
    function crossChainCall(address target, bytes memory data, uint32 gas) internal returns (bool) {
        return crossChainCall(ARBSYS, target, data, gas);
    }
}
