pragma solidity ^0.8.0;

import "@hyperlane-xyz/client/MailboxClient.sol";
import {FundsCustody} from "./Escrow.sol";
import "intents-framework/Base7683.sol";
import {IIntent} from "./../../interfaces/IIntent.sol";

contract IntentHub is FundsCustody, MailboxClient {
    address verifier;
    uint32 verifierChainId;

    modifier onlyVerifier(address caller) {
        // TODO custom errors
        require(caller == msg.sender);

        _;
    }

    constructor(address permit2, address _verifier, uint32 _verifierChainId, address mailbox)
        FundsCustody(permit2)
        MailboxClient(mailbox)
    {
        verifier = _verifier;
        verifierChainId = _verifierChainId;
    }

    function _localDomain() internal view override returns (uint32) {
        return localDomain;
    }

    function _handleSettle(bytes32 id) internal {
        _settle(id);
    }

    function open(OnchainCrossChainOrder calldata _order) external payable override {
        bytes32 id = _open(_order);
    }

    function _relayNewOrderToVerifier(bytes32 id, uint256 amount) internal {
        bytes32 recipientAddress = TypeCasts.addressToBytes32(verifier);

        mailbox.dispatch(verifierChainId, recipientAddress, abi.encode(IIntent.OrderMessage(id, amount)));
    }

    function handle(uint32 _origin, bytes32 _sender, bytes calldata _message)
        external
        payable
        onlyMailbox
        onlyVerifier(TypeCasts.bytes32ToAddress(_sender))
    {
        // we don't need the amount here since the verifier should successfully verify the amount + proof before even calling this
        bytes32 id = abi.decode(_message, (bytes32));
        _settle(id);
    }
}
