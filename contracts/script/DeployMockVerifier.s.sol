pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "./../src/core/intents/IntentHub.sol";
import "./../test/Base.sol";

contract Deployer is Script {
    uint256 pk = vm.envUint("PRIVATE_KEY");

    address zircuitMailBox = 0xc2FbB9411186AB3b1a6AFCCA702D1a80B48b197c;
    uint32 zircuitChainId = 48900;
    address hub = 0xEC1f8C8BDAeeD43194842E136EDd00C0985B2E8b;

    function run() external {
        vm.startBroadcast(pk);

        MockVerifier mockVerifier = new MockVerifier(zircuitMailBox, zircuitChainId);

        console.log("mock verifier deployed at          :", address(mockVerifier));

        vm.stopBroadcast();
    }
}
