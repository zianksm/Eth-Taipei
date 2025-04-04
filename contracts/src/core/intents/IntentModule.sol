pragma solidity ^0.8.0;

import {IntentLibrary} from "./../../libraries/Intent.sol";
import {IIntent} from "./../../interfaces/IIntent.sol";
import {IntentLibrary} from "./../../libraries/Intent.sol";
import {FundsCustody} from "./Custody.sol";
import {MathUtils} from "./../../libraries/MathUtils.sol";

contract IntentModule {
    using IntentLibrary for IIntent.Intents;
    using IntentLibrary for IIntent.IntentSpecification;

    FundsCustody custody;

    mapping(IIntent.IntentId => IIntent.IntentSpecification) public intents;

    // only allow self call
    // TODO : custom errors
    modifier onlySelf() {
        require(msg.sender == address(this));
        _;
    }

    function setCustody(address _custody) external onlySelf {
        custody = FundsCustody(_custody);
    }

    // DOESN'T PERFORM ACTUAL BALANCE CHECKS, INTENT MAY FAIL
    // IT'S ADVISED TO ADD AN INTENT WITHIN OR CLOSE TO MARKET PRICE SINCE NOT DOING SO RISK YOUR ORDER BEING UNFULFILLED
    // SINCE THE INTENT LOOKS AT THE RATIO OF THE IN & OUT AMOUNT AND TRIES TO PARTIALLY FILL YOUR ORDER BASED ON THAT
    function setIntents(address inToken_, address outToken_, uint256 inAmount, uint256 outAmount)
        external
        onlySelf
        returns (IIntent.IntentId id)
    {
        id = IntentLibrary.withIdentifier(inToken_, outToken_).toId();

        intents[id].inAmount += inAmount;
        intents[id].outAmount += outAmount;
    }

    function fill(address inToken, address outToken, uint256 inAmount, uint256 outAmount)
        external
        returns (bool success)
    {
        // ensure that the orders getting filled are atleast on the same ratio
        uint256 fillRatio = MathUtils.calculateRatio(inAmount, outAmount);

        IIntent.IntentSpecification storage spec = intents[IntentLibrary.toId(inToken, outToken)];

        uint256 intentRatio = spec.toRatio();

        // TODO custom errors
        // only allow filling orders if ratio the same
        require(intentRatio >= fillRatio);
    }
}
