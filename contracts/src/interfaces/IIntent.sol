pragma solidity ^0.8.0;

interface IIntent {
    function getOrderReserves(bytes32 id) external view returns (IIntent.OrderReserves memory);

    type IntentId is bytes32;

    event Reserved(address indexed filler, bytes32 order);

    struct Call {
        address dest;
        bytes data;
    }

    struct Intents {
        address inToken;
        address outToken;
    }

    struct IntentSpecification {
        uint256 inAmount;
        uint256 outAmount;
    }

    enum BankType {
        WISE
    }

    struct OrderData {
        address token;
        uint256 amount;
        BankType bankType;
        bytes8 swiftBicCode; // bank identifier OCBCSGSGXXX
        uint256 accountNumber; //
        string recipient;
        uint256 minimumAmount;
    }

    struct OrderReserves {
        address token;
        uint256 amount;
        BankType bankType;
        uint256 bankAccountDest;
        bytes8 swiftBicCode; // bank identifier OCBCSGSGXXX
        string recipient;
        OrderReserve inner;
    }

    struct OrderReserve {
        address filler;
        uint256 amount;
        uint256 deposit;
    }
}
