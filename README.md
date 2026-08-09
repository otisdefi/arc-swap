# Otis-Arc-Swap

A simple, constant-product (x·y=k) token swap and liquidity demo built natively on **Arc Testnet**. Includes a live AMM swap interface, liquidity add/remove, onchain activity history, and a light/dark theme — all in a single static page, no build step required.

**Live demo:** https://arc-swap-otisdefi.netlify.app

## Features

- **Direct Web3 Connection:** Connects directly via `window.ethereum` for a fast, native wallet experience (MetaMask, Rabby, etc.) — no WalletConnect relays.
- **Constant-Product AMM:** Swaps between two ERC-20 test tokens using the same x·y=k pricing formula as Uniswap V2, with a 0.30% pool fee.
- **Liquidity Management:** Add or remove liquidity directly from the UI, with live pool-share and payout previews before you confirm.
- **Onchain Activity History:** Scans recent Swap / LiquidityAdded / LiquidityRemoved events for your connected wallet — no backend or indexer required.
- **Light / Dark Theme:** Toggleable theme that respects your system preference and persists across visits.
- **Live Pool Curve:** Visualizes the pool's current position on the x·y=k curve, with a real-time preview of where your trade will land.

## Getting Started

### Prerequisites

- A Web3 wallet (e.g., MetaMask, Rabby) installed in your browser
- Arc Testnet added to your wallet, with some test USDC for gas

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/otisdefi/arc-swap.git
   ```

2. Open `arc-swap-ui.html` directly in your browser — no build step, no dependencies to install.

   Or just visit the [live demo](https://arc-swap-otisdefi.netlify.app).

## Network Requirements

To use the app, ensure your wallet is configured with the following network:

- **Arc Testnet**
  - Chain ID: `5042002`
  - RPC URL: `https://5042002.rpc.thirdweb.com`
  - Gas token: USDC
  - Explorer: https://testnet.arcscan.app

## Contracts (Arc Testnet, chain 5042002)

| Contract | Address |
|---|---|
| SimpleSwap | `0x56Ee3AD055121CD74d28fCc05B1e0dB4257936C7` |
| TokenA (TKA) | `0xf82C2704053b4db27Dbb213Ff271A819cA1E2910` |
| TokenB (TKB) | `0xEA92710a0Ab738dEFaadbb307af9641A5cE2C493` |

## Disclaimer

This contract is for educational/demonstration purposes only and has not undergone an independent security audit. It should not be used on mainnet or with assets of real value.

## Built With

- [ethers.js](https://docs.ethers.org/v5/) (v5, via CDN)
- Vanilla HTML / CSS / JavaScript — no build step, no framework
- [Solidity](https://soliditylang.org/) (contracts)

## License

MIT License

---

Developed by [otisdefi](https://github.com/otisdefi)
