pragma solidity ^0.8.0;

import {IntentLibrary} from "./../../libraries/Intent.sol";
import "intents-framework/Base7683.sol";
import {IIntent} from "./../../interfaces/IIntent.sol";
import {ReserveHandler} from "./OrderReserve.sol";

// needed to lock user funds for the intent, because if not then there's a possibility the intent fails and create a DOS situation
// where intent keeps failing, so user funds needs to be locked here
abstract contract FundsCustody is ReserveHandler {
    using SafeERC20 for IERC20;

    constructor(address permit2) Base7683(permit2) {}

    function _fillOrder(bytes32 _orderId, bytes calldata _originData, bytes calldata _fillerData) internal override {
        // TODO custom errors
        revert("nothing to fill");

        // we do nothing since this is an off-ramp first
    }

    // TODO only callable by funds lock contract after verifying zk proof
    // TODO & assumption : doesn't support partial settlement
    function _settleOrders(
        bytes32[] calldata _orderIds,
        bytes[] memory _ordersOriginData,
        bytes[] memory _ordersFillerData
    ) internal override {
        // TODO custom errors
        revert("custom settlement");
    }

    function _open(OnchainCrossChainOrder calldata _order)
        internal
        returns (bytes32 id, IIntent.OrderData memory orderData)
    {
        (ResolvedCrossChainOrder memory resolvedOrder, bytes32 orderId, uint256 nonce) = _resolveOrder(_order);

        id = orderId;

        openOrders[orderId] = abi.encode(_order.orderDataType, _order.orderData);
        orderStatus[orderId] = OPENED;

        nonce = newNonce(msg.sender);

        _useNonce(msg.sender, nonce);

        orderData = abi.decode(_order.orderData, (IIntent.OrderData));
        _createOrder(id, orderData);

        // since we're doing an off/on ramp, no tokens is actually transffered to other chains, so we must opt-out
        // from the standard accounting and transfer the token here, it'll be released after the zk proof is actually verified
        transferFromUserToSelf(orderData.token, orderData.amount);
        emit Open(orderId, resolvedOrder);
    }

    function _getOrderId(OnchainCrossChainOrder memory _order) internal pure override returns (bytes32) {
        return keccak256(abi.encode(_order));
    }

    function _getOrderId(GaslessCrossChainOrder memory _order) internal pure override returns (bytes32) {
        // TODO custom errors
        revert("not supported");
    }

    function _resolveOrder(GaslessCrossChainOrder memory _order, bytes calldata _originFillerData)
        internal
        view
        override
        returns (ResolvedCrossChainOrder memory _resolvedOrder, bytes32 _orderId, uint256 _nonce)
    {
        // TODO custom errors
        revert("not supported");
    }

    function _refundOrders(GaslessCrossChainOrder[] memory _orders, bytes32[] memory _orderIds) internal override {
        // TODO custom errors
        revert("not supported");
    }

    function _refundOrders(OnchainCrossChainOrder[] memory _orders, bytes32[] memory _orderIds) internal override {
        // TODO custom errors
        revert("not supported");
    }

    function _resolveOrder(OnchainCrossChainOrder memory _order)
        internal
        view
        override
        returns (ResolvedCrossChainOrder memory _resolvedOrder, bytes32 _orderId, uint256 _nonce)
    {
        _resolvedOrder.fillDeadline = _order.fillDeadline;
        _resolvedOrder.openDeadline = type(uint32).max;
        _resolvedOrder.orderId = _getOrderId(_order);

        _orderId = _resolvedOrder.orderId;

        uint8 chainId;

        assembly {
            chainId := chainid()
        }

        _resolvedOrder.originChainId = chainId;
    }
}
