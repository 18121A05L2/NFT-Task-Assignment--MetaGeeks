// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title GenesisNFTs
 * @author LakshmiSanikommu
 * @notice This is a Task project for MetaGeeks
 */
contract GenesisNFTs is ERC721 {
    error GenesisNFTs_SaleClosed();
    error GenesisNFTs_MinimumSalePriceNotMet();
    error GenesisNFTs_FundsTransferFailed();
    error GenesisNFTs_FreeMintClosed();
    error GenesisNFTs_SellOrderNotPlaced();
    error GenesisNFTs_SalePriceNotMet();
    error GenesisNFTs_NotAvailableForSale();

    bool public isSaleOpen = true;
    uint256 public salePrice = 0.1 ether;
    uint256 public totalSupply = 0;
    string public constant IPFS_DOMAIN = "https://azure-fantastic-gecko-907.mypinata.cloud/ipfs/";
    address public owner;
    uint256 public feePercent = 5;

    /**
     * @notice These token URIs needs to be store in IPFS
     */
    mapping(uint256 tokeId => string tokenURI) public tokenURIs;
    mapping(uint256 tokenId => NFTSale nftSaleInfo) public nftSaleInfo;

    struct NFTSale {
        uint256 price;
        bool isOpenForSale;
    }

    modifier onlyOwner() {
        msg.sender == owner;
        _;
    }

    constructor() ERC721("GenesisNFTs", "GNFT") {}

    /**
     * @notice For free mint this function is to mint upto 1000 NFTS , after that Owner need to mint
     * and make them avaialble for the sale
     * @param account NFT receiver account
     * @param tokenId unique NFT number
     * @param tokenURI IPFS link pointing to digital artwork
     */
    function mint(address account, uint256 tokenId, string memory tokenURI) internal {
        if (totalSupply > 1000 || msg.sender != owner) {
            // TODO : need to finalize this logic
            revert GenesisNFTs_FreeMintClosed();
        }
        _mint(account, tokenId);
        tokenURIs[tokenId] = tokenURI;
        unchecked {
            totalSupply++;
        }
    }

    /**
     * @notice This function is to buy NFT by anyone who can capable of sending the sale price in ether
     * when sale is opened by the owner
     * @param account NFT receiver account address
     * @notice if buyer sends more than the quote price , that is for exchange and they can use it for their ecosystem development
     * @notice exchange fee is 5% for the ecosystem developers
     */
    function buy(address account, uint256 tokenId) external payable {
        address currentOwner = ownerOf(tokenId);
        if (msg.value <= nftSaleInfo[tokenId].price) revert GenesisNFTs_SalePriceNotMet();
        if (nftSaleInfo[tokenId].isOpenForSale == false) revert GenesisNFTs_NotAvailableForSale();
        _transfer(address(this), account, tokenId);
        uint256 fee = nftSaleInfo[tokenId].price * feePercent / 100;
        uint256 finalAmount = nftSaleInfo[tokenId].price - fee;
        (bool success,) = currentOwner.call{value: finalAmount}(""); // TODO : need to check why payable is not required here
        if (!success) revert GenesisNFTs_FundsTransferFailed();
    }
    /**
     * @notice This function is to put NFTs on sale and provide approval to the contract to transfer to the buyer
     * @param price Token price that you are going to to sell for
     */

    function sell(uint256 tokenId, uint256 price) external {
        if (ownerOf(tokenId) != msg.sender) revert ERC721InvalidOwner(msg.sender);
        if (price < salePrice) revert GenesisNFTs_MinimumSalePriceNotMet();
        if (isSaleOpen) revert GenesisNFTs_SaleClosed();
        approve(address(this), tokenId);
        nftSaleInfo[tokenId] = NFTSale({price: price, isOpenForSale: true});
    }

    /**
     * @notice This function is to remove NFT from sale
     * @param tokenId unique NFT number
     */
    function cancelSellOrder(uint256 tokenId) external {
        if (ownerOf(tokenId) != msg.sender) revert ERC721InvalidOwner(msg.sender);
        if (nftSaleInfo[tokenId].isOpenForSale == false) revert GenesisNFTs_SellOrderNotPlaced();
        nftSaleInfo[tokenId] = NFTSale({price: 0, isOpenForSale: false});
    }

    function _baseURI() internal pure override returns (string memory) {
        return IPFS_DOMAIN;
    }

    function modifySaleStatus(bool status) external onlyOwner {
        isSaleOpen = status;
    }

    function withdrawFunds() external onlyOwner {
        (bool success,) = payable(owner).call{value: address(this).balance}("");
        if (!success) {
            revert GenesisNFTs_FundsTransferFailed();
        }
    }

    function changeExchangeFees(uint256 fee) external onlyOwner {
        feePercent = fee;
    }
}

// Functions - Checks , Effects and Interactions
