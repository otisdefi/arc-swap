// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title SimpleSwap
/// @notice Iki sabit token arasinda constant-product (x*y=k) formulu ile
///         calisan minimal bir AMM. Egitim/test amaclidir, production icin
///         denetlenmemistir (audit edilmemistir).
contract SimpleSwap is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    // Likidite saglayicilarinin paylarini tutan basit bir "LP token" defteri
    // (ayri bir ERC20 deploy etmeden, kontrat icinde mapping ile takip ediyoruz)
    mapping(address => uint256) public liquidityBalance;
    uint256 public totalLiquidity;

    uint256 public constant FEE_BPS = 30; // %0.3 islem ucreti (Uniswap V2 ile ayni)
    uint256 public constant BPS_DENOMINATOR = 10_000;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event Swap(address indexed user, address tokenIn, uint256 amountIn, uint256 amountOut);

    constructor(address _tokenA, address _tokenB) {
        require(_tokenA != address(0) && _tokenB != address(0), "zero address");
        require(_tokenA != _tokenB, "identical tokens");
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /// @notice Havuza ilk likiditeyi veya ek likidite ekler.
    /// @dev Ilk eklemede oran serbesttir; sonraki eklemelerde mevcut orana
    ///      yakin miktarlar vermek beklenir (aksi halde slipaj/kayip olusur).
    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant returns (uint256 liquidity) {
        require(amountA > 0 && amountB > 0, "amounts must be > 0");

        tokenA.safeTransferFrom(msg.sender, address(this), amountA);
        tokenB.safeTransferFrom(msg.sender, address(this), amountB);

        if (totalLiquidity == 0) {
            // Ilk likidite: basit geometrik ortalama
            liquidity = _sqrt(amountA * amountB);
        } else {
            uint256 liqA = (amountA * totalLiquidity) / reserveA;
            uint256 liqB = (amountB * totalLiquidity) / reserveB;
            liquidity = liqA < liqB ? liqA : liqB;
        }
        require(liquidity > 0, "insufficient liquidity minted");

        liquidityBalance[msg.sender] += liquidity;
        totalLiquidity += liquidity;
        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice Likidite payini geri alip orantili token miktarlarini ceker.
    function removeLiquidity(uint256 liquidity) external nonReentrant returns (uint256 amountA, uint256 amountB) {
        require(liquidity > 0 && liquidity <= liquidityBalance[msg.sender], "invalid liquidity amount");

        amountA = (liquidity * reserveA) / totalLiquidity;
        amountB = (liquidity * reserveB) / totalLiquidity;
        require(amountA > 0 && amountB > 0, "insufficient reserves");

        liquidityBalance[msg.sender] -= liquidity;
        totalLiquidity -= liquidity;
        reserveA -= amountA;
        reserveB -= amountB;

        tokenA.safeTransfer(msg.sender, amountA);
        tokenB.safeTransfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice TokenA verip TokenB alir.
    function swapAForB(uint256 amountIn, uint256 minAmountOut) external nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "amountIn must be > 0");
        amountOut = getAmountOut(amountIn, reserveA, reserveB);
        require(amountOut >= minAmountOut, "slippage too high");

        tokenA.safeTransferFrom(msg.sender, address(this), amountIn);
        reserveA += amountIn;
        reserveB -= amountOut;
        tokenB.safeTransfer(msg.sender, amountOut);

        emit Swap(msg.sender, address(tokenA), amountIn, amountOut);
    }

    /// @notice TokenB verip TokenA alir.
    function swapBForA(uint256 amountIn, uint256 minAmountOut) external nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "amountIn must be > 0");
        amountOut = getAmountOut(amountIn, reserveB, reserveA);
        require(amountOut >= minAmountOut, "slippage too high");

        tokenB.safeTransferFrom(msg.sender, address(this), amountIn);
        reserveB += amountIn;
        reserveA -= amountOut;
        tokenA.safeTransfer(msg.sender, amountOut);

        emit Swap(msg.sender, address(tokenB), amountIn, amountOut);
    }

    /// @notice Verilen giris miktari icin (ucret dahil) cikis miktarini hesaplar.
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        require(reserveIn > 0 && reserveOut > 0, "insufficient liquidity");
        uint256 amountInWithFee = amountIn * (BPS_DENOMINATOR - FEE_BPS);
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * BPS_DENOMINATOR) + amountInWithFee;
        return numerator / denominator;
    }

    /// @dev Babylonian method ile karekok hesaplama (ilk likidite icin).
    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
