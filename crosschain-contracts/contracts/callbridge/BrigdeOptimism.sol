// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibCrossChainOptimism.sol";
import "./core/BridgeBase.sol";

contract BrigdeOptimism is BrigdeBase {
    address public immutable bridge;
    address public immutable foreign;

    constructor(address _bridge, address _foreign)
    {
        bridge = _bridge;
        foreign = _foreign;
    }

    function sendMessage(address target, bytes calldata data, uint32 gas) external {
        LibCrossChainOptimism.crossChainCall(
            bridge,
            foreign,
            abi.encodeCall(this.__relay, (msg.sender, target, data)),
            gas
        );
    }

    function __relay(address sender, address target, bytes calldata data) external {
        require(LibCrossChainOptimism.isCrossChain(bridge) && LibCrossChainOptimism.crossChainSender(bridge) == foreign, "Unauthorized");
        _forward(sender, target, data);
    }
}