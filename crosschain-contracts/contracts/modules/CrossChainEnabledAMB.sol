// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibCrossChainAMB.sol";
import "./CrossChainEnabled.sol";

contract CrossChainEnabledAMB is CrossChainEnabled {
    address internal immutable bridge;

    constructor(address _bridge) {
        bridge = _bridge;
    }

    function _getBridge() internal view virtual override returns (LibCrossChain.Bridge memory result) {
        return LibCrossChainAMB.getBridge(bridge);
    }
}