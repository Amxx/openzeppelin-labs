// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IBridge as Polygon_Bridge } from "../../global/polygon-callbridge/IBridge.sol";

library LibCrossChainPolygon {
    function isCrossChain(Polygon_Bridge bridge) internal view returns (bool) {
        return msg.sender == address(bridge);
    }

    function crossChainSender(Polygon_Bridge bridge) internal view returns (address) {
        return bridge.messageSender();
    }

    function crossChainCall(Polygon_Bridge bridge, address target, bytes memory data, uint32 /*gas*/) internal returns (bool) {
        bridge.sendMessage(target, data);
        return true;
    }
}