pragma solidity ^0.8.0;

interface IIntent {
    type IntentId is bytes32;

    /// @dev by default all intents have partial fill
    struct Intents {
        address inToken;
        address outToken;
    }

    struct IntentSpecification {
        uint256 inAmount;
        uint256 outAmount;
    }

    struct FillerData{
        bytes proof;
    }
}
