// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ICrossDomainMessenger as Optimism_Bridge } from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

library LibCrossChainOptimism {
    function isCrossChain(Optimism_Bridge bridge) internal view returns (bool) {
        return msg.sender == address(bridge);
    }

    function crossChainSender(Optimism_Bridge bridge) internal view returns (address) {
        return bridge.xDomainMessageSender();
    }

    function crossChainCall(Optimism_Bridge bridge, address target, bytes memory data, uint32 gas) internal returns (bool) {
        bridge.sendMessage(target, data, gas);
        return true;
    }
}
