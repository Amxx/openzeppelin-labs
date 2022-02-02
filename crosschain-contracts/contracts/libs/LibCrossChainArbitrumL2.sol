// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IArbSys as ArbitrumL2_Bridge } from "../global/interfaces/arbitrum/IArbSys.sol";
import "./LibCrossChain.sol";

library LibCrossChainArbitrumL2 {
    ArbitrumL2_Bridge internal constant ARBSYS = ArbitrumL2_Bridge(0x0000000000000000000000000000000000000064);

    function getBridge() internal pure returns (LibCrossChain.Bridge memory result) {
        result._isCrossChain     = isCrossChain;
        result._crossChainSender = crossChainSender;
        result._crossChainCall   = crossChainCall;
        result._endpoint         = address(ARBSYS);
    }

    function isCrossChain(address bridge) internal view returns (bool) {
        return ArbitrumL2_Bridge(bridge).isTopLevelCall();
    }

    function crossChainSender(address bridge) internal view returns (address) {
        return ArbitrumL2_Bridge(bridge).wasMyCallersAddressAliased()
            ? ArbitrumL2_Bridge(bridge).myCallersAddressWithoutAliasing()
            : msg.sender;
    }

    function crossChainCall(address bridge, address target, bytes memory data, uint32 gas) internal returns (bool) {
        return crossChainCallWithValue(bridge, target, 0, data, gas);
    }

    function crossChainCallWithValue(address bridge, address target, uint256 value, bytes memory data, uint32 /*gas*/) internal returns (bool) {
        ArbitrumL2_Bridge(bridge).sendTxToL1{ value: value }(target, data);
        return true;
    }
}
