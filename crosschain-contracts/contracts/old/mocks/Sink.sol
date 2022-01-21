// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Sink {
    event TX(address indexed from, uint256 value, bytes data);

    fallback() external payable {
        emit TX(msg.sender, msg.value, msg.data);
    }
}
