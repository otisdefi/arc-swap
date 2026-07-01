// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title TestToken
/// @notice Basit, mint edilebilir test ERC-20 token. Swap'i denemek icin
///         TokenA ve TokenB olarak iki kez deploy edilir.
contract TestToken is ERC20, Ownable {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        // Deploy eden adrese baslangic arzi basilir (18 decimals varsayilir)
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    /// @notice Test amacli ekstra token basmak icin (sadece owner)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
