// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {WebProofProver} from "./WebProofProver.sol";

import {Proof} from "vlayer-0.1.0/Proof.sol";
import {Verifier} from "vlayer-0.1.0/Verifier.sol";

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract WebProofVerifier is Verifier, ERC721 {
    using Strings for string;

    address public prover;

    mapping(uint256 => string) public tokenIdToMetadataUri;

    constructor(address _prover) ERC721("TwitterNFT", "TNFT") {
        prover = _prover;
    }

    function verify(Proof calldata, string memory transferId, string memory recipient, int256 amount)
        public
        onlyVerified(prover, WebProofProver.main.selector)
    {
        // Verifier function signature must match the prover function signature
        uint256 tokenId = uint256(keccak256(abi.encodePacked(transferId)));
        require(_ownerOf(tokenId) == address(0), "User has already minted a TwitterNFT");
        require(recipient.equal("MAJIN TEKNOLOGI DESAIN PT"), "Invalid recipient");
        require(amount >= 95000000, "Invalid amount");

        _safeMint(msg.sender, tokenId);
        tokenIdToMetadataUri[tokenId] = string.concat("https://faucet.vlayer.xyz/api/xBadgeMeta?handle=", transferId);
    }

    function verify1(Proof calldata, string memory username, address account)
        public
        onlyVerified(prover, WebProofProver.main1.selector)
    {
        uint256 tokenId = uint256(keccak256(abi.encodePacked(username)));
        require(_ownerOf(tokenId) == address(0), "User has already minted a TwitterNFT");

        _safeMint(account, tokenId);
        tokenIdToMetadataUri[tokenId] = string.concat("https://faucet.vlayer.xyz/api/xBadgeMeta?handle=", username);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenIdToMetadataUri[tokenId];
    }
}