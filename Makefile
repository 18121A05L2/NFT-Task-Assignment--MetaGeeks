-include .env

.PHONY: install deploy

install:
	@forge install openzeppelin/openzeppelin-contracts

test:
	@forge test

deploy:
	@forge script script/GenesisNfts.s.sol --rpc-url $(SEPOLIA_RPC_URL) --account Real_account_private_key  --broadcast --verify --etherscan-api-key $(ETHER_SCAN_API)