pragma solidity ^0.8.0;

import {IntentLibrary} from "./../../libraries/Intent.sol";
import "intents-framework/Base7683.sol";
import {IIntent} from "./../../interfaces/IIntent.sol";
import {ReserveHandler} from "./OrderReserve.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

// needed to lock user funds for the intent, because if not then there's a possibility the intent fails and create a DOS situation
// where intent keeps failing, so user funds needs to be locked here
abstract contract FundsCustody is ReserveHandler {
    using SafeERC20 for IERC20;

    constructor(address permit2, address verifier) ReserveHandler(verifier) Base7683(permit2) {}

    function _verify(bytes memory proof) internal returns (bool) {
        return true;
    }

    function _fillOrder(bytes32 _orderId, bytes calldata _originData, bytes calldata _fillerData) internal override {
        // we do nothing since this is an off-ramp first
    }

    function open(OnchainCrossChainOrder calldata _order) external payable override {
        bytes32 id = _open(_order);
        IIntent.OrderData memory orderData = abi.decode(_order.orderData, (IIntent.OrderData));
        _createOrder(id, orderData.token, orderData.amount);

        // since we're doing an off/on ramp, no tokens is actually transffered to other chains, so we must opt-out
        // from the standard accounting and transfer the token here, it'll be released after the zk proof is actually verified
        transferFromUserToSelf(orderData.token, orderData.amount);
    }

    // TODO only callable by funds lock contract after verifying zk proof
    // TODO & assumption : doesn't support partial settlement
    function _settleOrders(
        bytes32[] calldata _orderIds,
        bytes[] memory _ordersOriginData,
        bytes[] memory _ordersFillerData
    ) internal override {
        for (uint256 i = 0; i < _orderIds.length; i++) {
            _settle(_orderIds[i]);
        }
    }

    function _open(OnchainCrossChainOrder calldata _order) internal returns (bytes32 id) {
        (ResolvedCrossChainOrder memory resolvedOrder, bytes32 orderId, uint256 nonce) = _resolveOrder(_order);

        id = orderId;

        openOrders[orderId] = abi.encode(_order.orderDataType, _order.orderData);
        orderStatus[orderId] = OPENED;
        _useNonce(msg.sender, nonce);

        uint256 totalValue;
        for (uint256 i = 0; i < resolvedOrder.minReceived.length; i++) {
            address token = TypeCasts.bytes32ToAddress(resolvedOrder.minReceived[i].token);
            if (token == address(0)) {
                totalValue += resolvedOrder.minReceived[i].amount;
            } else {
                IERC20(token).safeTransferFrom(msg.sender, address(this), resolvedOrder.minReceived[i].amount);
            }
        }

        if (msg.value != totalValue) revert InvalidNativeAmount();

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

    function _refundOrders(OnchainCrossChainOrder[] memory _orders, bytes32[] memory _orderIds) internal override{
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
