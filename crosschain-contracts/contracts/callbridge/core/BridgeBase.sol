// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IBridge.sol";

abstract contract BrigdeBase is IBridge {
    using Counters for Counters.Counter;

    event CallSuccess(address indexed sender, address indexed target, bytes data);
    event CallFailure(address indexed sender, address indexed target, bytes data);
    event RetrySuccess(address indexed sender, address indexed target, bytes data);

    mapping(bytes32 => Counters.Counter) private retryTickets;

    function retry(address sender, address target, bytes calldata data) external {
        retryTickets[keccak256(abi.encode(sender, target, data))].decrement(); // revert if overflow

        (bool success, bytes memory returndata) = _tryExecute(sender, target, data);
        Address.verifyCallResult(success, returndata, "Call execution failure");

        emit RetrySuccess(sender, target, data);
    }

    function _forward(address sender, address target, bytes memory data) internal {
        (bool success,) = _tryExecute(sender, target, data);

        if (success) {
            emit CallSuccess(sender, target, data);
        } else {
            retryTickets[keccak256(abi.encode(sender, target, data))].increment();
            emit CallFailure(sender, target, data);
        }
    }

    // Use ERC2771 to pass sender without relying on storage
    function _tryExecute(address sender, address target, bytes memory data) internal returns (bool success, bytes memory returndata) {
        (success, returndata) = target.call(abi.encodePacked(data, sender));
    }

    function _encodeMessage(address sender, address target, bytes memory data) internal pure returns (bytes memory message) {
        message = abi.encode(sender, target, data);
    }

    function _decodeMessage(bytes memory message) internal pure returns (address sender, address target, bytes memory data) {
        (sender, target, data) = abi.decode(message, (address, address, bytes));
    }
}
