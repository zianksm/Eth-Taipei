pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "./../src/core/intents/IntentHub.sol";
import "./../test/Base.sol";

contract Deployer is Script {
    uint256 pk = vm.envUint("PRIVATE_KEY");

    address zircuitMailBox = address(0);
    uint32 zircuitChainId = 48899;
    address hub;

    function run() external {
        vm.startBroadcast(pk);

        MockVerifier mockVerifier = new MockVerifier(zircuitMailBox, zircuitChainId);

        console.log("mock verifier deployed at          :", address(mockVerifier));

        vm.stopBroadcast();
    }
}
