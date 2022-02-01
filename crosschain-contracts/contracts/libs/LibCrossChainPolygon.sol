// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IBridge as Polygon_Bridge } from "../global/polygon-callbridge/IBridge.sol";
import "./LibCrossChain.sol";

library LibCrossChainPolygon {
    function getBridge(address bridge) internal pure returns (LibCrossChain.Bridge memory result) {
        result._isCrossChain     = isCrossChain;
        result._crossChainSender = crossChainSender;
        result._crossChainCall   = crossChainCall;
        result._endpoint         = bridge;
    }

    function isCrossChain(address bridge) internal view returns (bool) {
        return msg.sender == bridge;
    }

    function crossChainSender(address bridge) internal view returns (address) {
        return Polygon_Bridge(bridge).messageSender();
    }

    function crossChainCall(address bridge, address target, bytes memory data, uint32 /*gas*/) internal returns (bool) {
        Polygon_Bridge(bridge).sendMessage(target, data);
        return true;
    }
}