# NFT Task Assignment – Digital Art Collection

## Objective

Design and implement an NFT smart contract using Solidity that manages a collection of digital art tokens. The contract should enable minting, sales, and retrieval of token metadata.

---

## Task Requirements

### ERC-721 Implementation

- Build your contract based on the **ERC-721 standard** using OpenZeppelin libraries.

### Minting Functionality

- Implement a function to allow minting of new NFTs.
- Ensure each NFT has a **unique metadata URI** (e.g., pointing to digital artwork).

### Sale Mechanism

- Implement a **basic sale function** that enables users to purchase NFTs at a fixed price.
- Ensure the contract **logs purchase events** properly.

### Metadata Management

- Store and manage **unique metadata URIs** for each token.

### Access Control & Security

- Restrict administrative functions (such as setting the base URI or managing sales) to **authorized addresses** (e.g., the contract owner).
- Follow **best practices** to secure the contract against common vulnerabilities.

### Testing

- Write tests using **Foundry** to cover the following scenarios:
  - Successful **minting** and **metadata retrieval**.
  - NFT **purchase** and correct **fund handling**.
  - **Edge cases**, such as purchasing when sales are closed.

---

## Submission Guidelines

1. Provide the **Solidity code** for your NFT contract.
2. Include **clear instructions** on how to **deploy and test** the contract.
3. Optionally, add a **brief explanation** of your design decisions and any **potential improvements** for a production-ready version.

---

## Getting Started

### Prerequisites

Ensure you have the following installed:

- [Foundry](https://getfoundry.sh/)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)

### Installation

```sh
forge install
```

### Deployment

1. Configure your **environment variables** (e.g., private key, RPC URL).
2. Deploy the contract:

```sh
forge script script/Deploy.s.sol --broadcast --rpc-url <RPC_URL> --private-key <PRIVATE_KEY>
```

### Running Tests

```sh
forge test
```

---

## License

This project is licensed under the MIT License.

