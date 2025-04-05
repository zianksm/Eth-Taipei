pragma solidity ^0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

contract ApproveExecModule {
    struct Call {
        bytes data;
        address dest;
    }

    // just a helper function
    function buildApprove(address token, address to, uint256 amount) external virtual returns (Call memory call) {
        call.data = abi.encodeWithSelector(IERC20.approve.selector, abi.encode(to, amount));
        call.dest = token;
    }

    // will just arbitrarily execute everything
    function execute(Call[] memory calls) public {
        for (uint256 i = 0; i < calls.length; i++) {
            Call memory call = calls[i];

            call.dest.call(call.data);
        }
    }
}
