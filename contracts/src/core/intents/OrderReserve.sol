pragma solidity ^0.8.0;

import {IntentLibrary} from "./../../libraries/Intent.sol";
import {TokenAction} from "./../TokenAction.sol";
import "intents-framework/Base7683.sol";
import {IIntent} from "./../../interfaces/IIntent.sol";

// needed to lock user funds for the intent, because if not then there's a possibility the intent fails and create a DOS situation
// where intent keeps failing, so user funds needs to be locked here
abstract contract ReserveHandler is Base7683, TokenAction {
    address verifier;

    modifier onlyVerifier() {
        // TODO custom errors
        require(verifier == msg.sender);

        _;
    }

    struct OrderReserves {
        address token;
        uint256 amount;
        OrderReserve inner;
    }

    struct OrderReserve {
        address filler;
        uint256 amount;
        uint256 deposit;
    }

    mapping(bytes32 => OrderReserves) public orderReserves;

    // this is unsecure, ideally it's dyanmically calculated but for simplicity sake
    // you just need to deposit this amount everytime you want to fill and reserve an order,
    uint256 public constant UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT = 0.0001 ether;

    function reserve(OnchainCrossChainOrder memory order, address who) external payable {
        bytes32 id = _getOrderId(order);
        _reserve(id, who);
    }

    /// @dev can only be called by verifier contract after verifying the proof
    function _settle(bytes32 id) internal onlyVerifier {
        address filler = orderReserves[id].inner.filler;
        
        payable(filler).transfer(UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT);
    }

    function _createOrder(bytes32 id, address token, uint256 amount) internal {
        OrderReserves storage reserves = orderReserves[id];
        reserves.amount += amount;
    }

    function _ensureNotReserved(bytes32 id) internal {
        // TODO  custom errors
        require(orderReserves[id].inner.filler == address(0));
    }

    function _reserve(bytes32 id, address who) internal returns (uint256 amountNeedToFill) {
        amountNeedToFill = _handleReserveAmountResolution(id);

        _incrementFillerReserve(id, who, amountNeedToFill);
    }

    function _incrementFillerReserve(bytes32 id, address who, uint256 amount) internal {
        OrderReserve storage reserveInfo = orderReserves[id].inner;
        reserveInfo.amount += amount;
        reserveInfo.filler = who;

        require(msg.value == UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT);
        reserveInfo.deposit += UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT;
    }

    function _handleReserveAmountResolution(bytes32 id) internal returns (uint256 fillAmount) {
        fillAmount = orderReserves[id].amount;
    }
}
