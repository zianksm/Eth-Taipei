pragma solidity ^0.8.0;

import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

abstract contract TokenAction {
    using SafeERC20 for IERC20;

    function transfer(address token, address to, uint256 amount) internal {
        IERC20(token).safeTransfer(to, amount);
    }

    function transferFrom(address token, address from, address to, uint256 amount) internal {
        IERC20(token).safeTransferFrom(from, to, amount);
    }

    function transferFromToSelf(address token, address from, uint256 amount) internal {
        transferFrom(token, from, address(this), amount);
    }
}
