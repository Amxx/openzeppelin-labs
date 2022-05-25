// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@prb/math/contracts/PRBMathUD60x18.sol";
import "@prb/math/contracts/PRBMathSD59x18.sol";
import "@openzeppelin/contracts/contracts/token/ERC20/extensions/ERC20TokenizedVault.sol";
import "@openzeppelin/contracts/contracts/utils/math/SafeCast.sol";

contract ERC4626BoundingCurve is ERC20TokenizedVault {
    using SafeCast for int256;
    using SafeCast for uint256;
    using PRBMathSD59x18 for int256;
    using PRBMathUD60x18 for uint256;

    uint256 public immutable BUY_CURVE_PARAM;
    uint256 public immutable SELL_CURVE_PARAM;

    constructor(
        string memory _name,
        string memory _symbol,
        IERC20Metadata _asset,
        uint256 _buyCurveParam,
        uint256 _sellCurveParam
    )
    ERC20(_name, _symbol)
    ERC20TokenizedVault(_asset)
    {
        BUY_CURVE_PARAM  = _buyCurveParam;
        SELL_CURVE_PARAM = _sellCurveParam;
    }

    function previewDeposit(uint256 assets) public view override returns (uint256 shares) {
        uint256 tA = totalAssets();
        return tA == 0
            ? assets
            : (
                (PRBMathUD60x18.SCALE + PRBMathUD60x18.div(assets.fromUint(), tA.fromUint())).pow(BUY_CURVE_PARAM)
                -
                PRBMathUD60x18.SCALE
            )
            .mul(totalSupply().fromUint())
            .toUint();
    }

    function previewMint(uint256 shares) public view override returns (uint256 assets) {
        uint256 tS = totalSupply();
        return tS == 0
            ? shares
            : (
                (PRBMathUD60x18.SCALE + PRBMathUD60x18.div(shares.fromUint(), tS.fromUint())).pow(BUY_CURVE_PARAM.inv())
                -
                PRBMathUD60x18.SCALE
            )
            .mul(totalAssets().fromUint())
            .toUint();
    }

    function previewWithdraw(uint256 assets) public view override returns (uint256 shares) {
        uint256 tA = totalAssets();
        return tA == 0
            ? assets == 0
                ? 0
                : type(uint256).max
            : (
                PRBMathSD59x18.SCALE
                -
                (PRBMathSD59x18.SCALE - PRBMathSD59x18.div(assets.toInt256().fromInt(), tA.toInt256().fromInt())).pow(SELL_CURVE_PARAM.toInt256())
            )
            .mul(totalSupply().toInt256().fromInt())
            .toInt()
            .toUint256();
    }

    function previewRedeem(uint256 shares) public view override returns (uint256 assets) {
        uint256 tS = totalSupply();
        return tS == 0
            ? shares == 0
                ? 0
                : type(uint256).max
            : (
                PRBMathSD59x18.SCALE
                -
                (PRBMathSD59x18.SCALE - PRBMathSD59x18.div(shares.toInt256().fromInt(), tS.toInt256().fromInt())).pow(SELL_CURVE_PARAM.toInt256().inv())
            )
            .mul(totalAssets().toInt256().fromInt())
            .toInt()
            .toUint256();
    }
}
