# VaultCore: Enterprise Bitcoin Collateralization Platform

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Clarity](https://img.shields.io/badge/clarity-v2-orange.svg)
![Stacks](https://img.shields.io/badge/stacks-blockchain-purple.svg)

## Overview

VaultCore is an advanced DeFi protocol that enables Bitcoin holders to unlock liquidity through over-collateralized lending positions while maintaining BTC exposure. Built on the Stacks blockchain using Clarity smart contracts, VaultCore transforms idle Bitcoin holdings into productive capital by allowing users to mint USD-pegged stablecoins against their Bitcoin collateral.

## 🚀 Key Features

- **Over-Collateralized Lending**: 150% minimum collateral ratio ensures protocol stability
- **Automated Risk Management**: Liquidation at 120% threshold with 10% penalty
- **Dynamic Interest Rates**: Compound interest accrual per block (~10% APR)
- **Oracle Integration**: Real-time BTC/USD pricing with 24-hour validity windows
- **Emergency Controls**: Protocol pause functionality for security
- **Transparent Analytics**: Comprehensive protocol statistics and fee tracking

## 📋 Protocol Parameters

| Parameter | Value | Description |
|-----------|--------|-------------|
| Minimum Collateral Ratio | 150% | Required collateralization for new positions |
| Liquidation Threshold | 120% | Automatic liquidation trigger |
| Liquidation Penalty | 10% | Penalty applied during liquidation |
| Minimum Loan Amount | 100 USD | Smallest debt position allowed |
| Interest Rate | ~10% APR | Compound interest per block |
| Price Validity | 24 hours | Oracle price expiration window |

## 🏗️ Architecture

### Core Components

1. **Position Management**: Create, modify, and close collateralized debt positions
2. **Interest Accrual**: Automated compound interest calculation system
3. **Price Oracle**: External BTC/USD price feed integration
4. **Liquidation Engine**: Automated position liquidation for risk management
5. **Administrative Controls**: Protocol governance and emergency functions

### Smart Contract Structure

```text
vault-core/
├── contracts/
│   └── vault-core.clar          # Main protocol contract
├── tests/
│   └── vault-core.test.ts       # Comprehensive test suite
├── settings/
│   ├── Devnet.toml             # Development configuration
│   ├── Testnet.toml            # Testnet configuration
│   └── Mainnet.toml            # Mainnet configuration
├── Clarinet.toml               # Project configuration
└── package.json                # Dependencies and scripts
```

## 🔧 Installation & Setup

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v1.0+
- [Node.js](https://nodejs.org/) v16+
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Installation

```bash
# Clone the repository
git clone https://github.com/desmond-obi/vault-core.git
cd vault-core

# Install dependencies
npm install

# Run contract checks
clarinet check

# Execute test suite
npm test
```

## 📖 Usage

### Creating a Position

```clarity
;; Create a new collateralized debt position
;; Parameters: BTC amount (satoshis), USD amount to mint
(contract-call? .vault-core create-position u100000000 u150000000)
```

### Managing Collateral

```clarity
;; Add additional BTC collateral
(contract-call? .vault-core add-collateral u50000000)

;; Withdraw excess collateral (maintaining safe ratio)
(contract-call? .vault-core withdraw-collateral u25000000)
```

### Debt Management

```clarity
;; Repay outstanding debt
(contract-call? .vault-core repay-debt u75000000)

;; Check position status
(contract-call? .vault-core get-position tx-sender)
```

### Position Monitoring

```clarity
;; Get current collateralization ratio
(contract-call? .vault-core get-collateralization-ratio tx-sender)

;; View protocol statistics
(contract-call? .vault-core get-protocol-stats)
```

## 🔐 Security Features

### Risk Management

- **Minimum Collateral Ratio**: 150% ensures adequate backing for all positions
- **Liquidation Threshold**: Automatic liquidation at 120% prevents protocol insolvency
- **Interest Accrual**: Continuous debt growth maintains protocol sustainability
- **Price Validation**: Oracle feeds expire after 24 hours to prevent stale pricing

### Administrative Controls

- **Protocol Pause**: Emergency stop for all user operations
- **Owner Management**: Secure ownership transfer mechanisms
- **Oracle Updates**: Authorized price feed management

### Error Handling

Comprehensive error constants provide clear feedback:

```clarity
ERR-NOT-AUTHORIZED          ;; Unauthorized access attempt
ERR-INSUFFICIENT-COLLATERAL ;; Inadequate collateral provided
ERR-POSITION-NOT-FOUND      ;; No existing position found
ERR-UNDERCOLLATERALIZED     ;; Position below safety threshold
ERR-PROTOCOL-PAUSED         ;; Protocol in emergency pause
```

## 🧪 Testing

The protocol includes a comprehensive test suite covering:

- Position creation and management
- Interest accrual calculations
- Liquidation scenarios
- Oracle price updates
- Administrative functions
- Edge cases and error conditions

```bash
# Run all tests
npm test

# Run contract checks
clarinet check

# Generate test coverage report
npm run test:coverage
```

## 📊 Protocol Economics

### Interest Model

VaultCore implements a compound interest model with continuous accrual:

- **Base Rate**: 0.0005% per block
- **Annual Rate**: ~10% APR
- **Compounding**: Every Stacks block (~10 minutes)

### Liquidation Mechanics

When a position falls below 120% collateralization:

1. **Detection**: Automated monitoring identifies undercollateralized positions
2. **Execution**: Liquidators burn debt tokens to claim collateral
3. **Penalty**: 10% of collateral awarded as liquidation bonus
4. **Settlement**: Remaining collateral returned to position owner

### Fee Structure

- **Stability Fee**: Accumulated interest on outstanding debt
- **Liquidation Penalty**: 10% of liquidated collateral
- **No Origination Fees**: Zero-cost position creation

## 🤝 Contributing

We welcome contributions from the community! Please follow these guidelines:

1. **Fork the Repository**: Create your own fork of the project
2. **Create Feature Branch**: `git checkout -b feature/amazing-feature`
3. **Write Tests**: Ensure comprehensive test coverage
4. **Follow Coding Standards**: Use consistent Clarity formatting
5. **Submit Pull Request**: Provide detailed description of changes

### Development Workflow

```bash
# Setup development environment
npm install

# Run tests continuously during development
npm run test:watch

# Lint and format code
npm run lint
npm run format

# Check contract syntax
clarinet check
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
