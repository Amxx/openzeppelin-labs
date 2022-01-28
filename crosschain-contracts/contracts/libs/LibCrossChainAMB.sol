// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IAMB as AMB_Bridge } from "../global/interfaces/amb/IAMB.sol";
import "./LibCrossChain.sol";

library LibCrossChainAMB {
    function getBridge(address bridge) internal pure returns (LibCrossChain.Bridge memory result) {
        result._isCrossChain     = isCrossChain;
        result._crossChainSender = crossChainSender;
        result._crossChainCall   = crossChainCall;
        result._bridge           = bridge;
    }

    function isCrossChain(address bridge) private view returns (bool) {
        return msg.sender == bridge;
    }

    function crossChainSender(address bridge) private view returns (address) {
        return AMB_Bridge(bridge).messageSender();
    }

    function crossChainCall(address bridge, address target, bytes memory data, uint32 gas) private returns (bool) {
        require(AMB_Bridge(bridge).maxGasPerTx() <= gas);
        AMB_Bridge(bridge).requireToPassMessage(target, data, gas);
        return true;
    }
}
