// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract CrossChainEnabled {
    modifier onlyCrossChain() {
        require(_isCrossChain(), "not-a-crosschain-call");
        _;
    }

    modifier onlyCrossChainSender(address account) {
        require(_isCrossChain(), "not-a-crosschain-call");
        require(account == _crossChainSender(), "wrong-crosschain-sender");
        _;
    }

    function _isCrossChain() internal view virtual returns (bool) {
        return false;
    }

    function _crossChainSender() internal view virtual returns (address) {
        return address(0); // TODO: revert?
    }
}
