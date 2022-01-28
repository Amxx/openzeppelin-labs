// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAMB as AMB_Bridge } from "../../global/interfaces/amb/IAMB.sol";

library LibCrossChainAMB {
    function isCrossChain(AMB_Bridge bridge) internal view returns (bool) {
        return msg.sender == address(bridge);
    }

    function crossChainSender(AMB_Bridge bridge) internal view returns (address) {
        return bridge.messageSender();
    }

    function crossChainCall(AMB_Bridge bridge, address target, bytes memory data, uint32 gas) internal returns (bool) {
        require(bridge.maxGasPerTx() <= gas);
        bridge.requireToPassMessage(target, data, gas);
        return true;
    }
}
