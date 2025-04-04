pragma solidity ^0.8.0;

import {IntentLibrary} from "./../../libraries/Intent.sol";
import {TokenAction} from "./../TokenAction.sol";

// needed to lock user funds for the intent, because if not then there's a possibility the intent fails and create a DOS situation
// where intent keeps failing, so user funds needs to be locked here
contract FundsCustody is TokenAction {
    // user => token => locked balance
    // this is used for locking user funds, if a user makes an intent, the funds will go here
    mapping(address => mapping(address => uint256)) public locked;

    // user => token => locked balance
    // this is used for holding user free balances, after the intent is executed, this is where user funds will go to
    mapping(address => mapping(address => uint256)) public free;

    function withdrawLocked(address token, uint256 amount) external {
        // TODO custom errors
        require(locked[msg.sender][token] >= amount);

        locked[msg.sender][token] -= amount;

        transfer(token, msg.sender, amount);
    }

    function withdrawFree(address token, uint256 amount) external {
        // TODO custom errors
        require(free[msg.sender][token] >= amount);

        free[msg.sender][token] -= amount;

        transfer(token, msg.sender, amount);
    }
}
