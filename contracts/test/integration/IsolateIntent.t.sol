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

    function testReserveOrderMocked() external {
        // bridge 100 usdc
        uint256 amount = 100 ether;
        OnchainCrossChainOrder memory order = buildOrder(token0, amount);

        maxApprove(token0, address(hub));
        hub.open(order);
        processInboundMessage();

        IIntent.OrderMessage memory lastMessage = mockVerifier.getLastMessage();

        vm.startPrank(mockFiller);
        uint256 ethBalanceBeforeReserve = mockFiller.balance;

        hub.reserve{value: hub.UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT()}(lastMessage.id);

        uint256 ethBalanceAfterReserve = mockFiller.balance;

        assertEq(ethBalanceBeforeReserve - ethBalanceAfterReserve, hub.UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT());

        IIntent.OrderReserves memory orderBook = hub.getOrderReserves(lastMessage.id);

        assertEq(orderBook.inner.filler, mockFiller);
        assertEq(orderBook.inner.amount, amount);
    }

    function testSettleOrderMocked() external {
        // bridge 100 usdc
        uint256 amount = 100 ether;
        OnchainCrossChainOrder memory order = buildOrder(token0, amount);

        maxApprove(token0, address(hub));
        hub.open(order);
        processInboundMessage();

        IIntent.OrderMessage memory lastMessage = mockVerifier.getLastMessage();

        vm.startPrank(mockFiller);
        hub.reserve{value: hub.UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT()}(lastMessage.id);

        // do some shit, send actual paypal or smth

        // settle the orders

        uint256 ethBalanceBeforeSettle = mockFiller.balance;

        mockVerifier.mockSettleAndVerify(lastMessage.id);
        processInboundMessage();

        uint256 ethBalanceAfterSettle = mockFiller.balance;

        // verify deposit back
        assertEq(ethBalanceAfterSettle - ethBalanceBeforeSettle, hub.UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT());

        // verify orderbook is actually deleted
        IIntent.OrderReserves memory orderBook = hub.getOrderReserves(lastMessage.id);
        assertEq(orderBook.inner.filler, address(0));
        assertEq(orderBook.inner.amount, 0);
    }
}
