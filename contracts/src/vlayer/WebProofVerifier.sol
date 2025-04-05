// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {WebProofProver} from "./WebProofProver.sol";

import {Proof} from "vlayer-0.1.0/Proof.sol";
import {Verifier} from "vlayer-0.1.0/Verifier.sol";

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IIntent} from "./../interfaces/IIntent.sol";
import {MailboxClient} from "@hyperlane-xyz/client/MailboxClient.sol";

import {TypeCasts} from "@hyperlane-xyz/libs/TypeCasts.sol";

contract WebProofVerifier is Verifier, MailboxClient {
    mapping(bytes32 => IIntent.OrderData) public orders;

    // acts as like a nonce to the proof, prevent a proof to be used multiple times for different ids
    mapping(bytes32 => bool) public usedTransferIds;

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
    {}

    function calculatePercentage(uint256 value, uint256 percentage) internal pure returns (uint256) {
        // percentage is expressed with 18 decimals
        // e.g., 10% would be 10 * 10^18 / 100 = 10^17

        // We divide by 100 * 10^18 to get the correct percentage
        uint256 oneHundredPercent = 100 * 10 ** 18;

        // Calculate value * percentage / 100
        // Using SafeMath pattern to prevent overflow
        return (value * percentage) / oneHundredPercent;
    }

    function settleVerified(
        Proof calldata proof,
        string memory transferId,
        string memory recipient,
        int256 amount,
        bytes32 id
    ) external {
        verify(proof, transferId, recipient, amount);

        usedTransferIds[keccak256(bytes(transferId))] = true;

        IIntent.OrderData storage orderData = orders[id];

        require(keccak256(bytes(recipient)) == keccak256(bytes(orderData.recipient)), "different recipient");
        require(uint256(amount) >= orderData.minimumAmount);

        mailbox.dispatch(_hubChain, TypeCasts.addressToBytes32(_hub), abi.encode(id));
    }

    function handle(uint32 _origin, bytes32 _sender, bytes calldata _message) external payable {
        (bytes32 id, IIntent.OrderData memory orderData) = abi.decode(_message, (bytes32, IIntent.OrderData));
        orders[id] = orderData;
    }
}
