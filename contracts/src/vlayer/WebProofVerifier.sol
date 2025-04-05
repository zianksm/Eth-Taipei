// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {WebProofProver} from "./WebProofProver.sol";

import {Proof} from "vlayer-0.1.0/Proof.sol";
import {Verifier} from "vlayer-0.1.0/Verifier.sol";

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IIntent} from "./../interfaces/IIntent.sol";
import {MailboxClient} from "@hyperlane-xyz/client/MailboxClient.sol";

contract WebProofVerifier is Verifier, MailboxClient {
    IIntent.OrderData internal lastMessage;

    address internal _hub;
    uint32 internal _hubChain;

    address public prover;

    constructor(address _prover, address mailbox, uint32 hubChain) MailboxClient(mailbox) {
        prover = _prover;
        _hubChain = hubChain;
    }

    // we can technically makes this works with multiple different hub address
    // but skip it for now
    function setHub(address hub) external {
        _hub = hub;
    }

    function setHubChain(uint32 chain) external {
        _hubChain = chain;
    }

    function verify(Proof calldata, string memory transferId, string memory recipient, int256 amount)
        public
        onlyVerified(prover, WebProofProver.main.selector)
    {
        // Verifier function signature must match the prover function signature
        uint256 tokenId = uint256(keccak256(abi.encodePacked(transferId)));
        // require(recipient.equal("MAJIN TEKNOLOGI DESAIN PT"), "Invalid recipient");
        require(amount >= 95000000, "Invalid amount");
    }

    // function very
}
