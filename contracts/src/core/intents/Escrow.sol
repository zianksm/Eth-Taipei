pragma solidity ^0.8.0;

import {IntentLibrary} from "./../../libraries/Intent.sol";
import {TokenAction} from "./../TokenAction.sol";
import "intents-framework/Base7683.sol";
import {IIntent} from "./../../interfaces/IIntent.sol";
import {ReserveHandler} from "./OrderReserve.sol";

// needed to lock user funds for the intent, because if not then there's a possibility the intent fails and create a DOS situation
// where intent keeps failing, so user funds needs to be locked here
abstract contract FundsCustody is TokenAction, ReserveHandler {
    constructor(address permit2) Base7683(permit2) {}

    function _verify(bytes memory proof) internal returns (bool) {
        return true;
    }

    function _fillOrder(bytes32 _orderId, bytes calldata _originData, bytes calldata _fillerData) internal override {
        IIntent.FillerData memory fillerData = abi.decode(_fillerData, (IIntent.FillerData));
        _verify(fillerData.proof);
        // send tokens
    }

    // function ope

    function _getOrderId(OnchainCrossChainOrder memory _order) internal pure override returns (bytes32) {
        return keccak256(abi.encode(_order));
    }

    function _resolveOrder(GaslessCrossChainOrder memory _order, bytes calldata _originFillerData)
        internal
        view
        override
        returns (ResolvedCrossChainOrder memory _resolvedOrder, bytes32 _orderId, uint256 _nonce)
    {}

    function _resolveOrder(OnchainCrossChainOrder memory _order)
        internal
        view
        override
        returns (ResolvedCrossChainOrder memory _resolvedOrder, bytes32 _orderId, uint256 _nonce)
    {}

    function _settleOrders(
        bytes32[] calldata _orderIds,
        bytes[] memory _ordersOriginData,
        bytes[] memory _ordersFillerData
    ) internal override {}
}
