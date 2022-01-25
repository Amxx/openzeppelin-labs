# CCC: CROSS CHAIN CONTRACTS

## CrossDomainEnabled, an abstract contract to support crosschain operations

| Blockchain | Side | Receiving          | Sending            | Contract                                                                 |
|------------|------|--------------------|--------------------|--------------------------------------------------------------------------|
| AMB        | Both | :heavy_check_mark: | :heavy_check_mark: | [CrossChainEnabledAMB](contracts/CrossChainEnabledAMB.sol)               |
| Arbitrum   | L1   | :heavy_check_mark: | :x:                | [CrossChainEnabledArbitrumL1](contracts/CrossChainEnabledArbitrumL1.sol) |
| Arbitrum   | L2   | :heavy_check_mark: | :heavy_check_mark: | [CrossChainEnabledArbitrumL2](contracts/CrossChainEnabledArbitrumL2.sol) |
| Optimism   | Both | :heavy_check_mark: | :heavy_check_mark: | [CrossChainEnabledOptimism](contracts/CrossChainEnabledOptimism.sol)     |
| Polygon    | Both | :heavy_check_mark: | :heavy_check_mark: | [CrossChainEnabledPolygon](contracts/CrossChainEnabledPolygon.sol)       |
| Polygon    | L1   | :interrobang:      | :heavy_check_mark: | [CrossChainEnabledPolygonL1](contracts/deprecated/CrossChainEnabledPolygonL1.sol) (deprecated)  |
| Polygon    | L2   | :heavy_check_mark: | :heavy_check_mark: | [CrossChainEnabledPolygonL2](contracts/deprecated/CrossChainEnabledPolygonL2.sol) (deprecated)  |