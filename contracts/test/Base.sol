pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@hyperlane-xyz/mock/MockMailbox.sol";

import "@hyperlane-xyz/test/TestRecipient.sol";
import "./../src/core/intents/IntentHub.sol";

contract BaseTest is Test {
    // origin and destination domains (recommended to be the chainId)
    uint32 origin = 1;
    uint32 verifierDest = 2;

    // both mailboxes will be on the same chain but different addresses
    MockMailbox originMailbox;
    MockMailbox verifierMailbox;

    // contract which can receive messages
    IntentHub hub;

    // TODO: replace this with actual proof verifier
    address mockVerifier = address(420);

    function setupBase() public {
        originMailbox = new MockMailbox(origin);
        verifierMailbox = new MockMailbox(verifierDest);

        originMailbox.addRemoteMailbox(verifierDest, verifierMailbox);

        // TODO: replace this with actual proof verifier

        hub = new IntentHub(mockVerifier, verifierDest, address(originMailbox));
    }
}
