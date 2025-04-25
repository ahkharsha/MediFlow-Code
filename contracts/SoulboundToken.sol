// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SoulboundToken is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;
    mapping(uint256 => bool) public soulbound;

    event TokenIssued(address indexed recipient, uint256 tokenId, string tokenURI);

    constructor() ERC721("HealthIdentityToken", "HID") {
        tokenCounter = 1;
    }

    function issueSBT(address recipient, string memory tokenURI) external onlyOwner {
        uint256 newTokenId = tokenCounter;
        _safeMint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        soulbound[newTokenId] = true;
        tokenCounter++;

        emit TokenIssued(recipient, newTokenId, tokenURI);
    }

    // Prevents transfers if the token is soulbound
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override {
        require(from == address(0) || !soulbound[tokenId], "Soulbound: token cannot be transferred");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // Override approval functions to block transfers
    function approve(address to, uint256 tokenId) public override {
        require(false, "Soulbound: Approvals disabled");
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(false, "Soulbound: Approvals disabled");
    }

    // Optional: allow revocation by DAO or Admin
    function burnSBT(uint256 tokenId) external onlyOwner {
        require(soulbound[tokenId], "Not a soulbound token");
        _burn(tokenId);
        delete soulbound[tokenId];
    }
}
