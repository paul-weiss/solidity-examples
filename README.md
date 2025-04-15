# Solidity Examples

This repository contains practical examples of Solidity smart contracts based on the [Solidity Documentation v0.8.29](https://docs.soliditylang.org/en/v0.8.29/).

## Project Structure

```
solidity-examples/
├── contracts/
│   ├── basics/           # Basic contract examples
│   ├── advanced/         # Advanced contract patterns
│   ├── security/         # Security-focused examples
│   └── patterns/         # Common design patterns
├── scripts/              # Deployment scripts
└── tests/                # Test files
```

## Examples Included

1. Basic Contracts
   - SimpleStorage: Basic storage and retrieval
   - Counter: Simple counter with increment/decrement
   - Events: Demonstration of events

2. Advanced Contracts
   - Voting: Democratic voting system
   - BlindAuction: Implementation of a blind auction
   - SafeRemotePurchase: Secure purchase contract

3. Security Examples
   - Reentrancy Guards
   - Access Control
   - Safe Math Usage

4. Design Patterns
   - Factory Pattern
   - Proxy Pattern
   - Withdrawal Pattern

## Requirements

- Solidity ^0.8.29
- Choose one of:
  - Hardhat/Node.js setup
  - Foundry setup

## Development Setup

### Option 1: Using Hardhat

1. Install dependencies:
```bash
npm install
```

2. Compile contracts:
```bash
npm run compile
```

3. Run tests:
```bash
npm test
```

### Option 2: Using Foundry

1. Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. Initialize Foundry in the project:
```bash
forge init --no-commit
```

3. Build the project:
```bash
forge build
```

4. Run tests:
```bash
forge test
```

## Local Development with Anvil

Anvil is Foundry's local testnet, similar to Hardhat Network. Here's how to use it:

1. Start Anvil:
```bash
anvil
```
This will start a local testnet on `http://localhost:8545` with these test accounts:
- Default RPC URL: `http://localhost:8545`
- Chain ID: 31337
- 10 test accounts with 10000 ETH each
- Default private key: `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`

2. Deploy contracts using Forge:
```bash
# Deploy a specific contract
forge create --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  src/SimpleStorage.sol:SimpleStorage

# Or deploy with constructor arguments
forge create --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  src/Token.sol:Token \
  --constructor-args "MyToken" "MTK" 1000000000000000000000000 0x...
```

3. Interact with deployed contracts:
```bash
# Read contract state
cast call <CONTRACT_ADDRESS> "retrieve()(uint256)" --rpc-url http://localhost:8545

# Write to contract
cast send <CONTRACT_ADDRESS> "store(uint256)" 123 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --rpc-url http://localhost:8545
```

4. Run tests with gas reports:
```bash
forge test --gas-report
```

5. Debug transactions:
```bash
# Get transaction trace
cast run <TX_HASH> --rpc-url http://localhost:8545
```

### Useful Foundry Commands

```bash
# Compile contracts
forge build

# Run tests
forge test

# Run a specific test
forge test --match-test testFunctionName

# Run tests with verbosity
forge test -vv

# Deploy contract
forge create --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> <CONTRACT_PATH>:<CONTRACT_NAME>

# Verify contract
forge verify-contract <CONTRACT_ADDRESS> <CONTRACT_NAME> <ETHERSCAN_API_KEY>
```

## License

Apache License 2.0

## Contributing

Feel free to submit issues and enhancement requests. 