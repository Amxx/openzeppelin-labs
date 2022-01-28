// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ICrossDomainMessenger as Optimism_Bridge } from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import "./LibCrossChain.sol";

library LibCrossChainOptimism {
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
        return Optimism_Bridge(bridge).xDomainMessageSender();
    }

    function crossChainCall(address bridge, address target, bytes memory data, uint32 gas) private returns (bool) {
        Optimism_Bridge(bridge).sendMessage(target, data, gas);
        return true;
    }
}
