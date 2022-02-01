// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibCrossChain {
    struct Bridge {
        function(address) internal view returns (bool) _isCrossChain;
        function(address) internal view returns (address) _crossChainSender;
        function(address, address, bytes memory, uint32) internal returns (bool) _crossChainCall;
        address _endpoint;
    }

    function isCrossChain(Bridge memory self) internal view returns (bool) {
        return self._isCrossChain(self._endpoint);
    }

    function crossChainSender(Bridge memory self) internal view returns (address) {
        return self._crossChainSender(self._endpoint);
    }

    function crossChainCall(Bridge memory self, address target, bytes memory message, uint32 gasLimit) internal returns (bool) {
        return self._crossChainCall(self._endpoint, target, message, gasLimit);
    }
}