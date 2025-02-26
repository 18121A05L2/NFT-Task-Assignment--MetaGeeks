-include .env

.PHONY: install

install:
	@forge install openzeppelin/openzeppelin-contracts

test:
	@forge test