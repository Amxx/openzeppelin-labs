# CCC: CROSS CHAIN CONTRACTS

## LibCrossChain, libraries to abstract crosschain operations

| Blockchain | Side | Receiving          | Sending            | Contract                                                                         |
|------------|------|--------------------|--------------------|----------------------------------------------------------------------------------|
| AMB        | Both | :heavy_check_mark: | :heavy_check_mark: | [LibCrossChainAMB](contracts/libs/LibCrossChainAMB.sol)                          |
| Arbitrum   | L1   | :heavy_check_mark: | :interrobang:      | [LibCrossChainArbitrumL1](contracts/libs/LibCrossChainArbitrumL1.sol)            |
| Arbitrum   | L2   | :heavy_check_mark: | :heavy_check_mark: | [LibCrossChainArbitrumL2](contracts/libs/LibCrossChainArbitrumL2.sol)            |
| Optimism   | Both | :heavy_check_mark: | :heavy_check_mark: | [LibCrossChainOptimism](contracts/libs/LibCrossChainOptimism.sol)                |
| Polygon    | Both | :heavy_check_mark: | :heavy_check_mark: | [LibCrossChainPolygon](contracts/libs/LibCrossChainPolygon.sol)                  |

## CrossDomainEnabled, abstract contracts to support crosschain operations

| Blockchain | Side | Receiving          | Sending            | Contract                                                                         |
|------------|------|--------------------|--------------------|----------------------------------------------------------------------------------|
| AMB        | Both | :heavy_check_mark: | :heavy_check_mark: | [CrossChainEnabledAMB](contracts/modules/CrossChainEnabledAMB.sol)               |
| Arbitrum   | L1   | :heavy_check_mark: | :interrobang:      | [CrossChainEnabledArbitrumL1](contracts/modules/CrossChainEnabledArbitrumL1.sol) |
| Arbitrum   | L2   | :heavy_check_mark: | :heavy_check_mark: | [CrossChainEnabledArbitrumL2](contracts/modules/CrossChainEnabledArbitrumL2.sol) |
| Optimism   | Both | :heavy_check_mark: | :heavy_check_mark: | [CrossChainEnabledOptimism](contracts/modules/CrossChainEnabledOptimism.sol)     |
| Polygon    | Both | :heavy_check_mark: | :heavy_check_mark: | [CrossChainEnabledPolygon](contracts/modules/CrossChainEnabledPolygon.sol)       |
