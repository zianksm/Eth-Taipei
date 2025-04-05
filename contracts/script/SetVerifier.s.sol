pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "./../src/core/intents/IntentHub.sol";
import "./../test/Base.sol";

contract Deployer is Script {
    uint256 pk = vm.envUint("PRIVATE_KEY");

    /// @dev change this to the correct address
    address verifier = address(0);
    /// @dev change this to the correct verifier chain id
    uint32 dest = 0;
    /// @dev change this to the correct hub address
    address hub = address(0);

    function run() external {
        if (verifier == address(0)) revert("verifier address not set");
        if (dest == 0) revert("dest not set");

        vm.startBroadcast(pk);

        IntentHub(hub).setVerifier(verifier);
        IntentHub(hub).setVerifierChainId(dest);

        vm.stopBroadcast();
    }
}
