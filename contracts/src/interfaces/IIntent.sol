pragma solidity ^0.8.0;

interface IIntent {
    type IntentId is bytes32;

    struct Intents {
        address inToken;
        address outToken;
    }

    struct IntentSpecification {
        uint256 inAmount;
        uint256 outAmount;
    }


    struct OrderData {
        address token;
        uint256 amount;
    }

    struct OrderMessage {
        bytes32 id;
        uint256 amount;
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
}
