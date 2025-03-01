// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {console} from "forge-std/Test.sol";

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

    bool public isSaleOpen = false;
    uint256 public salePrice = 0.1 ether;
    uint256 public totalSupply = 0;
    string public constant IPFS_DOMAIN = "https://azure-fantastic-gecko-907.mypinata.cloud/ipfs/";
    address public immutable owner;
    uint256 public feePercent = 5;

    /**
     * @notice These token URIs needs to be store in IPFS
     */
    mapping(uint256 tokeId => string tokenURI) public tokenURIs;
    mapping(uint256 tokenId => NFTSale nftSaleInfo) public nftSaleInfo;

    struct NFTSale {
        uint256 price;
        bool isOpenForSale;
        address owner;
    }

    modifier onlyOwner() {
        msg.sender == owner;
        _;
    }

    constructor() ERC721("GenesisNFTs", "GNFT") {
        owner = msg.sender;
    }

    /**
     * @notice For free mint this function is to mint upto 1000 NFTS , after that Owner need to mint
     * and make them avaialble for the sale
     * @param account NFT receiver account
     */
    function mint(address account) external {
        if (totalSupply > 1000 && msg.sender != owner) {
            // TODO : need to finalize this logic
            revert GenesisNFTs_FreeMintClosed();
        }
        _mint(account, totalSupply);
        unchecked {
            totalSupply++;
        }
    }

    /**
     * @notice This function is to buy NFT by anyone who can capable of sending the sale price in ether
     * when sale is opened by the owner
     * @param to NFT receiver account address
     * @notice if buyer sends more than the quote price , that is for exchange and they can use it for their ecosystem development
     * @notice exchange fee is 5% for the ecosystem developers
     */
    function buy(address to, uint256 tokenId, address nftOwner) external payable {
        if (nftSaleInfo[tokenId].isOpenForSale == false) revert GenesisNFTs_NotAvailableForSale();
        if (msg.value < nftSaleInfo[tokenId].price) revert GenesisNFTs_SalePriceNotMet();
        if (ownerOf(tokenId) != address(this)) revert ERC721InvalidOwner(msg.sender);
        approveToBuyer(to, tokenId);
        transferFrom(address(this), to, tokenId);
        (uint256 finalAmount,) = calculateFees(tokenId);
        (bool success,) = nftOwner.call{value: finalAmount}(""); // TODO : need to check why payable is not required here
        if (!success) revert GenesisNFTs_FundsTransferFailed();
    }
    /**
     * @notice This function is to put NFTs on sale and provide approval to the contract to transfer to the buyer
     * @param price Token price that you are going to to sell for
     * @notice spender need to send his nft to the cotract when selling
     */

    function sell(uint256 tokenId, uint256 price) external {
        if (ownerOf(tokenId) != msg.sender) revert ERC721InvalidOwner(msg.sender);
        if (price < salePrice) revert GenesisNFTs_MinimumSalePriceNotMet();
        if (!isSaleOpen) revert GenesisNFTs_SaleClosed();
        transferFrom(msg.sender, address(this), tokenId);
        nftSaleInfo[tokenId] = NFTSale({price: price, isOpenForSale: true, owner: msg.sender});
    }

    /**
     * @notice This function is to remove NFT from sale
     * when user executes this we are sending the NFT back to the user
     * @param tokenId unique NFT number
     */
    function cancelSellOrder(uint256 tokenId) external {
        if (nftSaleInfo[tokenId].isOpenForSale == false) revert GenesisNFTs_SellOrderNotPlaced();
        if (ownerOf(tokenId) != address(this)) revert ERC721InvalidOwner(msg.sender);
        approveToBuyer(msg.sender, tokenId);
        transferFrom(address(this), msg.sender, tokenId);
        nftSaleInfo[tokenId] = NFTSale({price: 0, isOpenForSale: false, owner: address(0)});
    }

    function approveToBuyer(address to, uint256 tokenId) internal {
        _approve(to, tokenId, address(this));
    }

    function calculateFees(uint256 tokenId) public view returns (uint256 finalAmount, uint256 fee) {
        fee = nftSaleInfo[tokenId].price * feePercent / 100;
        finalAmount = nftSaleInfo[tokenId].price - fee;
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
