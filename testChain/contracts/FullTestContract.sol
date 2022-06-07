// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

contract FullTestContract {
    event ValueBool(string descr, bool value);
    event ValueAddress(string descr, address value);
    event ValueUint256(string descr, uint256 value);
    event ValueBytes32(string descr, bytes32 value);
    event ValueString(string descr, string value);
    event ValueBytes(string descr, bytes value);
    event Error();

    fallback() external payable {
        emit ValueAddress("msg.sender (fallback)", msg.sender);
        emit ValueUint256("msg.value (fallback)", msg.value);
        emit ValueBytes("msg.data (fallback)", msg.data);
    }

    function testBalance(address account) external {
        emit ValueUint256("account.balance", account.balance);
    }

    function testBalanceOfThis() external {
        emit ValueUint256("address(this).balance", address(this).balance);
    }

    function testBlockNumber() external {
        emit ValueUint256("block.number", block.number);
    }

    function testBlockTimestamp() external {
        emit ValueUint256("block.timestamp", block.timestamp);
    }

    function testChainId() external {
        emit ValueUint256("block.chainid", block.chainid);
    }

    function testCode(address account) external {
        emit ValueBytes("account.code", account.code);
    }
    function testCodeOfThis() external {
        emit ValueBytes("address(this).code", address(this).code);
    }

    function testEcrecover(bytes32 data, bytes32 r, bytes32 s, uint8 v) external {
        emit ValueAddress("ecrecover", ecrecover(data, v, r, s));
    }

    function testHash(bytes calldata data) external {
        emit ValueBytes32("keccak256", keccak256(data));
    }

    function testRevertWithoutMessage() external {
        revert();
        emit Error();
    }

    function testRevertWithMessage(string calldata message) external {
        revert(message);
        emit Error();
    }

    function testAddressIsContract(address account) external {
        emit ValueBool("isContract", Address.isContract(account));
    }

    function testAddressSendValue(address payable account, uint256 value) external payable {
        Address.sendValue(account, value);
    }

    function testAddressFunctionCallWithValue(address target, bytes calldata data, uint256 value) external payable {
        emit ValueBytes("functionCallWithValue", Address.functionCallWithValue(target, data, value));
    }

    function testAddressFunctionStaticCall(address target, bytes calldata data) external payable {
        emit ValueBytes("functionStaticCall", Address.functionStaticCall(target, data));
    }

    function testAddressFunctionDelegateCall(address target, bytes calldata data) external payable {
        emit ValueBytes("functionDelegateCall", Address.functionDelegateCall(target, data));
    }

    function testStorageSlotWrite(bytes32 slot, bytes32 value) external {
        StorageSlot.getBytes32Slot(slot).value = value;
    }

    function testStorageSlotRead(bytes32 slot) external {
        emit ValueBytes32("getBytes32Slot", StorageSlot.getBytes32Slot(slot).value);
    }

    function testCreate(address implementation) external {
        emit ValueAddress("createClone", Clones.clone(implementation));
    }

    function testCreate2(address implementation, bytes32 salt) external {
        emit ValueAddress("createClone", Clones.cloneDeterministic(implementation, salt));
    }

    function testMathAdd(uint256 x, uint256 y) external { emit ValueUint256("+", x + y); }
    function testMathSub(uint256 x, uint256 y) external { emit ValueUint256("-", x - y); }
    function testMathMul(uint256 x, uint256 y) external { emit ValueUint256("*", x * y); }
    function testMathDiv(uint256 x, uint256 y) external { emit ValueUint256("/", x / y); }
    function testMathMod(uint256 x, uint256 y) external { emit ValueUint256("%", x % y); }
    function testMathAnd(uint256 x, uint256 y) external { emit ValueUint256("&", x & y); }
    function testMathOr (uint256 x, uint256 y) external { emit ValueUint256("|", x | y); }
    function testMathXor(uint256 x, uint256 y) external { emit ValueUint256("^", x ^ y); }
    function testMathNot(uint256 x           ) external { emit ValueUint256("~", ~x);    }
}