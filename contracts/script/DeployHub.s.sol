pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "./../src/module/ApproveExec.sol";
import "./../src/core/intents/IntentHub.sol";
import "./../test/Base.sol";

contract Deployer is Script {
    uint256 pk = vm.envUint("PRIVATE_KEY");

    address celoMailBox = 0xEf9F292fcEBC3848bF4bB92a96a04F9ECBb78E59;

    function run() external {
        vm.startBroadcast(pk);

        SimpleExecBatchModule module = new SimpleExecBatchModule();
        IntentHub hub = new IntentHub(address(0), 0, celoMailBox);

        console.log("intent hub deployed at                 :", address(hub));
        console.log("module deployed at                     :", address(module));

        vm.stopBroadcast();
    }
}
