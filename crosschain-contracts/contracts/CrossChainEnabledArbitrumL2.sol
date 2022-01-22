// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IArbSys.sol";
import "./CrossChainEnabled.sol";

abstract contract CrossChainEnabledArbitrumL2 is CrossChainEnabled {
    IArbSys internal constant arbsys = IArbSys(0x0000000000000000000000000000000000000064);

    function _isCrossChain() internal view virtual override returns (bool) {
        return arbsys.isTopLevelCall();
    }

    function _crossChainSender() internal view virtual override onlyCrossChain() returns (address) {
        return arbsys.wasMyCallersAddressAliased()
            ? arbsys.myCallersAddressWithoutAliasing()
            : msg.sender;
    }
}
