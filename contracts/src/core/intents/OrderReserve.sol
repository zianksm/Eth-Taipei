pragma solidity ^0.8.0;

import {IntentLibrary} from "./../../libraries/Intent.sol";
import {TokenAction} from "./../TokenAction.sol";
import "intents-framework/Base7683.sol";
import {IIntent} from "./../../interfaces/IIntent.sol";

// needed to lock user funds for the intent, because if not then there's a possibility the intent fails and create a DOS situation
// where intent keeps failing, so user funds needs to be locked here
abstract contract ReserveHandler is Base7683 {
    struct OrderReserves {
        uint256 amount;
        uint256 reserved;
        mapping(address => OrderReserve) inner;
    }

    struct OrderReserve {
        uint256 amount;
        uint256 deposit;
    }

    mapping(bytes32 => OrderReserves) public orderReserves;

    // this is unsecure, ideally it's dyanmically calculated but for simplicity sake
    // you just need to deposit this amount everytime you want to fill and reserve an order,
    uint256 public constant UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT = 0.0001 ether;

    function reserve(OnchainCrossChainOrder memory order, address who, uint256 amount) external payable {
        bytes32 id = _getOrderId(order);
        _reserve(id, who, amount);
    }

    function _reserve(bytes32 id, address who, uint256 amount) internal returns (uint256 amountNeedToFill) {
        amountNeedToFill = _handleReserveAmountResolution(id, amount);

        _incrementFillerReserve(id, who, amountNeedToFill);
    }

    function _incrementFillerReserve(bytes32 id, address who, uint256 amount) internal {
        OrderReserve storage reserve = orderReserves[id].inner[who];
        reserve.amount += amount;

        require(msg.value == UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT);
        reserve.deposit += UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT;
    }

    function _handleReserveAmountResolution(bytes32 id, uint256 amount) internal returns (uint256 fillAmount) {
        uint256 maxReserve = orderReserves[id].amount;
        uint256 afterReserve = amount + maxReserve;

        if (maxReserve < afterReserve) {
            fillAmount = orderReserves[id].amount - orderReserves[id].reserved;
        } else {
            fillAmount = amount;
        }
    }
}
