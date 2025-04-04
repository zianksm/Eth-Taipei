pragma solidity ^0.8.0;

import {IntentLibrary} from "./../../libraries/Intent.sol";
import {IIntent} from "./../../interfaces/IIntent.sol";
import {IntentLibrary} from "./../../libraries/Intent.sol";
import {FundsCustody} from "./Custody.sol";
import {MathUtils} from "./../../libraries/MathUtils.sol";
import {TokenAction} from "./../TokenAction.sol";

contract IntentModule is TokenAction {
    using IntentLibrary for IIntent.Intents;
    using IntentLibrary for IIntent.IntentSpecification;

    FundsCustody custody;

    mapping(IIntent.IntentId => IIntent.IntentSpecification) public intents;

    modifier onlySelf() {
        // TODO custom errors
        require(msg.sender == address(this));

        _;
    }

    function setCustody(address _custody) external onlySelf {
        custody = FundsCustody(_custody);
    }

    // DOESN'T PERFORM ACTUAL BALANCE CHECKS, INTENT MAY FAIL
    // IT'S ADVISED TO ADD AN INTENT WITHIN OR CLOSE TO MARKET PRICE SINCE NOT DOING SO RISK YOUR ORDER BEING UNFULFILLED
    // SINCE THE INTENT LOOKS AT THE RATIO OF THE IN & OUT AMOUNT AND TRIES TO PARTIALLY FILL YOUR ORDER BASED ON THAT
    function modifyIntents(address inToken_, address outToken_, int256 inAmount, int256 outAmount)
        external
        onlySelf
        returns (uint256 inAmountLeft, uint256 outAmountLeft, IIntent.IntentId id)
    {
        IIntent.IntentSpecification storage spec = intents[IntentLibrary.toId(inToken_, outToken_)];

        if (inAmount < 0) {
            spec.inAmount -= uint256(-inAmount);
            _unlockToSelf(inToken_, uint256(-inAmount));
        } else {
            spec.inAmount += uint256(inAmount);
            _lock(inToken_, uint256(inAmount));
        }

        if (outAmount < 0) {
            spec.outAmount -= uint256(-outAmount);
            _unlockToSelf(inToken_, uint256(-outAmount));
        } else {
            spec.outAmount += uint256(outAmount);
            _lock(inToken_, uint256(outAmount));
        }

        inAmountLeft = spec.inAmount;
        outAmountLeft = spec.outAmount;
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

    function _lock(address token, uint256 amount) internal {
        transferFromToSelf(token, msg.sender, amount);
        custody.lock(token, amount);
    }

    function _unlockTo(address token, address to, uint256 amount) internal {
        _unlockToSelf(token, amount);
        transfer(token, to, amount);
    }

    function _unlockToSelf(address token, uint256 amount) internal {
        custody.unlock(token, amount);
    }
}
