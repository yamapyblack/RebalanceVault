# RebalanceVault

## Overview

Rebalance Vault is an automatic rebalancing bot for UniswapV3.

The rebalance changes the range of UniswapV3 liquidity if it is out of range. The vault has a very simple rebalancing strategy/

This Vault has a very simple strategy. It takes the current price as the center of the range for the upper and lower `rebalanceRangeTickBPS`. It is possible to change this BPS.

Vault also mint NFTs with TokenID: 1. This NFT is a LP token, and only the NFT holder can redeem it. It is a good idea to keep your LP tokens safe in a hardware wallet or similar.

## Install

### direnv

Recommend **direnv**

Mac OS
```
brew install direnv
```

Other OS
```
git clone https://github.com/direnv/direnv
cd direnv
sudo make install
```

Copy to **.envrc** and setup

```
cp .envrc.sample .envrc
direnv allow
```

Passed path to node_modules, you don't need to use "npx"

### npm

To run hardhat script

```
npm install
```

### foundry

To install Foundry for Testing (assuming a Linux or macOS system)

```
curl -L https://foundry.paradigm.xyz | bash
```

This will download foundryup. To start Foundry, run

```
foundryup
```

To install dependencies

```
forge install
```

## Usage

Testing

```
forge test -vv --fork-url ${ARB_URL} --fork-block-number ${ARB_BLOCK}
```
