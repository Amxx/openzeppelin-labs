// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBridge {
    function messageSender() external view returns (address);
    function sendMessage(address target, bytes memory data, uint32 gas) external;
}
