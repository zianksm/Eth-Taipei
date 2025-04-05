pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@hyperlane-xyz/mock/MockMailbox.sol";

import "@hyperlane-xyz/test/TestRecipient.sol";
import "./../src/core/intents/IntentHub.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("TEST", "TEST") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract MockMailBoxReceiver {
    IIntent.OrderMessage internal lastMessage;

    function getLastMessage() external view returns (IIntent.OrderMessage memory) {
        return lastMessage;
    }

    function handle(uint32 _origin, bytes32 _sender, bytes calldata _message) external payable {
        lastMessage = abi.decode(_message, (IIntent.OrderMessage));
    }
}

contract BaseTest is Test {
    // origin and destination domains (recommended to be the chainId)
    uint32 origin = 1;
    uint32 verifierDest = 2;

    // both mailboxes will be on the same chain but different addresses
    MockMailbox originMailbox;
    MockMailbox verifierMailbox;

    // contract which can receive messages
    IntentHub hub;

    MockToken token0;
    MockToken token1;

    // TODO: replace this with actual proof verifier
    MockMailBoxReceiver internal mockVerifier = new MockMailBoxReceiver();

    address internal user = address(40304);

    address internal mockFiller = address(34397483);

    function setupBase() public {
        originMailbox = new MockMailbox(origin);
        verifierMailbox = new MockMailbox(verifierDest);

        originMailbox.addRemoteMailbox(verifierDest, verifierMailbox);

        // TODO: replace this with actual proof verifier
        hub = new IntentHub(address(mockVerifier), verifierDest, address(originMailbox));

        token0 = new MockToken();
        token1 = new MockToken();

        token0.mint(user, type(uint128).max);
        token1.mint(user, type(uint128).max);

        vm.startPrank(user);
    }

    function buildOrder(MockToken token, uint256 amount) internal returns (OnchainCrossChainOrder memory) {
        uint32 deadline = type(uint32).max;
        bytes32 orderType = "";

        bytes memory data = abi.encode(IIntent.OrderData(address(token), amount));

        return OnchainCrossChainOrder(deadline, orderType, data);
    }

    function processInboundMessage() internal {
        verifierMailbox.processNextInboundMessage();
    }

    function maxApprove(MockToken token, address to) internal {
        token.approve(to, type(uint256).max);
    }
}
