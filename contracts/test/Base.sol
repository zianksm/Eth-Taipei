pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@hyperlane-xyz/mock/MockMailbox.sol";

import "@hyperlane-xyz/test/TestRecipient.sol";
import "./../src/core/intents/IntentHub.sol";
import "forge-std/console.sol";
import "./../src/module/ApproveExec.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("TEST", "TEST") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract MockMailBoxReceiver is MailboxClient {
    IIntent.OrderMessage internal lastMessage;

    address internal _hub;
    uint32 internal _hubChain;

    // no permit 2 support for now
    constructor(address mailbox, uint32 hubChain) MailboxClient(mailbox) {
        _hubChain = hubChain;
    }

    function setHub(address hub) external {
        _hub = hub;
    }

    function mockSettleAndVerify(bytes32 id) external {
        bytes32 hub = TypeCasts.addressToBytes32(address(_hub));

        mailbox.dispatch(_hubChain, hub, abi.encode(id));
    }

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

    SimpleExecBatchModule SimpleExecBatchModuleImpl = new SimpleExecBatchModule();

    // TODO: replace this with actual proof verifier
    MockMailBoxReceiver internal mockVerifier;

    uint256 internal userPk = 1;
    address internal user = vm.addr(userPk);

    address internal mockFiller = address(34397483);

    function setupBase() public {
        originMailbox = new MockMailbox(origin);
        verifierMailbox = new MockMailbox(verifierDest);

        originMailbox.addRemoteMailbox(verifierDest, verifierMailbox);
        verifierMailbox.addRemoteMailbox(origin, originMailbox);

        // TODO: replace this with actual proof verifier
        mockVerifier = new MockMailBoxReceiver(address(verifierMailbox), origin);
        hub = new IntentHub(address(mockVerifier), verifierDest, address(originMailbox));

        mockVerifier.setHub(address(hub));

        token0 = new MockToken();
        token1 = new MockToken();

        token0.mint(user, type(uint128).max);
        token1.mint(user, type(uint128).max);

        vm.deal(mockFiller, 100000 ether);

        vm.startPrank(user);
    }

    function buildOrder(MockToken token, uint256 amount) internal returns (OnchainCrossChainOrder memory) {
        uint32 deadline = type(uint32).max;
        bytes32 orderType = "";

        bytes memory data = abi.encode(IIntent.OrderData(address(token), amount));

        return OnchainCrossChainOrder(deadline, orderType, data);
    }

    function processInboundMessage() internal {
        try verifierMailbox.processNextInboundMessage() {} catch {}

        try originMailbox.processNextInboundMessage() {} catch {}
    }

    function maxApprove(MockToken token, address to) internal {
        token.approve(to, type(uint256).max);
    }
}
