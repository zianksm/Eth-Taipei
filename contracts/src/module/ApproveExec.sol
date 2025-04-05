pragma solidity ^0.8.0;

import {IERC20} from "openzeppelin-contracts/interfaces/IERC20.sol";
import {IIntent} from "./../interfaces/IIntent.sol";

contract SimpleExecBatchModule {
    // will just arbitrarily execute everything
    function execBatch(IIntent.Call[] memory calls) public {
        for (uint256 i = 0; i < calls.length; i++) {
            IIntent.Call memory call = calls[i];

            (bool success,) = call.dest.call(call.data);

            require(success, "failed delegation call");
        }
    }
}
