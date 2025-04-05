pragma solidity ^0.8.0;

import {IIntent} from "./../interfaces/IIntent.sol";
import {MathUtils} from "./MathUtils.sol";

library IntentLibrary {
    function toId(IIntent.Intents memory intent) internal pure returns (IIntent.IntentId id) {
        id = toId(intent.inToken, intent.outToken);
    }

    function toRatio(IIntent.IntentSpecification memory intent) internal pure returns (uint256 ratio) {
        ratio = MathUtils.calculateRatio(intent.inAmount, intent.outAmount);
    }

    function toId(address _in, address out) internal pure returns (IIntent.IntentId id) {
        id = wrapId(keccak256(abi.encode(_in, out)));
    }

    function wrapId(bytes32 _id) internal pure returns (IIntent.IntentId wrapped) {
        wrapped = IIntent.IntentId.wrap(_id);
    }

    function withIdentifier(address inToken_, address outToken_)
        internal
        pure
        returns (IIntent.Intents memory intent)
    {
        intent.inToken = inToken_;
        intent.outToken = outToken_;
    }
}
