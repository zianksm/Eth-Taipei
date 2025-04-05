pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "./../src/core/intents/IntentHub.sol";
import "./../test/Base.sol";

contract Deployer is Script {
    uint256 pk = vm.envUint("PRIVATE_KEY");

    /// @dev change this to the correct address
    address verifier = 0x901A620C7Bb09E925F36342f510BDef5c3c541A5;
    /// @dev change this to the correct verifier chain id
    uint32 dest = 48900;
    /// @dev change this to the correct hub address
    address hub = 0xEC1f8C8BDAeeD43194842E136EDd00C0985B2E8b;

    function run() external {
        if (verifier == address(0)) revert("verifier address not set");
        if (dest == 0) revert("dest not set");

        vm.startBroadcast(pk);

        IntentHub(hub).setVerifier(verifier);
        IntentHub(hub).setVerifierChainId(dest);

        vm.stopBroadcast();
    }
}
