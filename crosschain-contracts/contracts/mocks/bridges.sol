// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

abstract contract BaseRelayMock {
    address public _sender;

    function relayAs(address target, bytes calldata data, address sender) external {
        address previousSender = _sender;

        _sender = sender;
        Address.functionCall(target, data);
        _sender = previousSender;
    }
}

/**
 * AMB
 */
contract BridgeAMBMock is BaseRelayMock {
    function messageSender() public view returns (address) { return _sender; }
}

/**
 * Arbitrum
 */
contract BridgeArbitrumL1Mock is BaseRelayMock {
    address internal immutable _inbox  = address(new BridgeArbitrumL1Inbox());
    address internal immutable _outbox = address(new BridgeArbitrumL1Outbox());

    function activeOutbox() public view returns (address) { return _outbox; }
}

contract BridgeArbitrumL1Inbox {
    address internal immutable _bridge = msg.sender;

    function bridge() public view returns (address) { return _bridge; }
}

contract BridgeArbitrumL1Outbox {
    address internal immutable _bridge = msg.sender;

    function l2ToL1Sender() public view returns (address) { return BaseRelayMock(_bridge)._sender(); }
}

contract BridgeArbitrumL2Mock is BaseRelayMock{
    function wasMyCallersAddressAliased() public pure returns (bool) { return true; }
    function myCallersAddressWithoutAliasing() public view returns (address) { return _sender; }
}
/**
 * Optimism
 */
contract BridgeOptimismMock is BaseRelayMock {
    function xDomainMessageSender() public view returns (address) { return _sender; }
}