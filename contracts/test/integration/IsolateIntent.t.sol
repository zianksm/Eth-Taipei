pragma solidity ^0.8.0;

import "./../Base.sol";
import "./../../src/interfaces/IIntent.sol";

contract IntentHubTest is BaseTest {
    function setUp() external {
        setupBase();
    }

    function testOpenOrderMocked() external {
        // bridge 100 usdc
        uint256 amount = 100 ether;
        OnchainCrossChainOrder memory order = buildOrder(token0, amount);

        maxApprove(token0, address(hub));
        hub.open(order);
        processInboundMessage();

        IIntent.OrderMessage memory lastMessage = mockVerifier.getLastMessage();

        IIntent.OrderReserves memory orderBook = hub.getOrderReserves(lastMessage.id);

        assertEq(orderBook.amount, amount);
        assertEq(orderBook.token, address(token0));
    }

    function testOpenOrderERC7702Mocked() external {}

    function testSettleOrderMocked() external {}
}
