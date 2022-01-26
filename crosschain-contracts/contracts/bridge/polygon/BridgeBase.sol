// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./IBridge.sol";

// see: "@eth-optimism/contracts/libraries/constants/Lib_DefaultValues.sol";
address constant DEFAULT_SENDER = 0x000000000000000000000000000000000000dEaD;

abstract contract BrigdeBase is IBridge {
    event CallSuccess();
    event CallFailure(bytes returndata);

    address internal _sender = DEFAULT_SENDER;

    function messageSender() public view returns (address) {
        require(_sender != DEFAULT_SENDER, "messageSender is not set");
        return _sender;
    }

    function _forward(address sender, address target, bytes memory data) internal {
        _sender = sender;
        (bool success, bytes memory returndata) = target.call(data);
        _sender = DEFAULT_SENDER;

        if (success) {
            emit CallSuccess();
        } else {
            emit CallFailure(returndata);
        }
    }

    function _encodeMessage(address sender, address target, bytes memory data) internal pure returns (bytes memory message) {
        message = abi.encode(sender, target, data);
    }

    function _decodeMessage(bytes memory message) internal pure returns (address sender, address target, bytes memory data) {
        (sender, target, data) = abi.decode(message, (address, address, bytes));
    }
}
