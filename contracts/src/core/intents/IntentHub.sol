pragma solidity ^0.8.0;

import "@hyperlane-xyz/client/MailboxClient.sol";
import {FundsCustody} from "./Escrow.sol";

contract IntentHub is FundsCustody, MailboxClient {
    constructor(address permit2, address verifier, address mailbox)
        FundsCustody(permit2, verifier)
        MailboxClient(mailbox)
    {}

    function _localDomain() internal view override returns (uint32) {
        return localDomain;
    }
}
