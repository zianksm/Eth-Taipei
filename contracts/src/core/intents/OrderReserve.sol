pragma solidity ^0.8.0;

import {IntentLibrary} from "./../../libraries/Intent.sol";
import {TokenAction} from "./../TokenAction.sol";
import "intents-framework/Base7683.sol";
import {IIntent} from "./../../interfaces/IIntent.sol";

// needed to lock user funds for the intent, because if not then there's a possibility the intent fails and create a DOS situation
// where intent keeps failing, so user funds needs to be locked here
abstract contract ReserveHandler is Base7683, TokenAction, IIntent {
    mapping(bytes32 => IIntent.OrderReserves) internal orderReserves;

    mapping(address => uint256) public nonce;

    function newNonce(address who) internal returns (uint256) {
        return ++nonce[who];
    }

    function getOrderReserves(bytes32 id) external view returns (IIntent.OrderReserves memory) {
        return orderReserves[id];
    }

    // this is unsecure, ideally it's dyanmically calculated but for simplicity sake
    // you just need to deposit this amount everytime you want to fill and reserve an order,
    uint256 public constant UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT = 0.0001 ether;

    function reserve(bytes32 id) external payable {
        _ensureNotReserved(id);
        _reserve(id, msg.sender);

        emit Reserved(msg.sender, id);
    }

    /// @dev can only be called by verifier contract after verifying the proof
    function _settle(bytes32 id) internal {
        IIntent.OrderReserves storage order = orderReserves[id];

        address filler = order.inner.filler;

        payable(filler).transfer(UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT);
        transfer(order.token, filler, order.amount);

        delete orderReserves[id];

        bytes[] memory __placeholder;
        bytes32[] memory orderIds = new bytes32[](1);

        orderIds[0] = id;

        emit Settle(orderIds, __placeholder);
    }

    function _createOrder(bytes32 id, address token, uint256 amount, IIntent.BankType bankType, uint256 bankAccount)
        internal
    {
        IIntent.OrderReserves storage reserves = orderReserves[id];
        reserves.amount += amount;
        reserves.token = token;
        reserves.bankType = bankType;
        reserves.bankAccountDest = bankAccount;
    }

    function _ensureNotReserved(bytes32 id) internal {
        // TODO  custom errors
        require(orderReserves[id].inner.filler == address(0), "order is reserved");
    }

    function _reserve(bytes32 id, address who) internal returns (uint256 amountNeedToFill) {
        amountNeedToFill = _handleReserveAmountResolution(id);

        _incrementFillerReserve(id, who, amountNeedToFill);
    }

    function _incrementFillerReserve(bytes32 id, address who, uint256 amount) internal {
        IIntent.OrderReserve storage reserveInfo = orderReserves[id].inner;
        reserveInfo.amount += amount;
        reserveInfo.filler = who;

        require(msg.value == UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT, "no deposit found");
        reserveInfo.deposit += UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT;
    }

    function _handleReserveAmountResolution(bytes32 id) internal returns (uint256 fillAmount) {
        fillAmount = orderReserves[id].amount;
    }
}
