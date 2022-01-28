// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IArbSys as ArbitrumL2_Bridge } from "../../global/interfaces/arbitrum/IArbSys.sol";

library LibCrossChainArbitrumL2 {
    ArbitrumL2_Bridge internal constant arbsys = ArbitrumL2_Bridge(0x0000000000000000000000000000000000000064);

    function isCrossChain() internal view returns (bool) {
        return arbsys.isTopLevelCall();
    }

    function crossChainSender() internal view returns (address) {
        return arbsys.wasMyCallersAddressAliased()
            ? arbsys.myCallersAddressWithoutAliasing()
            : msg.sender;
    }

    function crossChainCall(address target, bytes memory data, uint32 /*gas*/) internal returns (bool) {
        arbsys.sendTxToL1(target, data);
        return true;
    }
}
