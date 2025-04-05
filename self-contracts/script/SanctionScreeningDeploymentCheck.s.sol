// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/SanctionScreeningCheck.sol";

contract DeploySanctionScreeningCheck is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        string memory blockscoutKey = vm.envString("BLOCKSCOUT_API_KEY");
        string memory verifyApiUrl = vm.envString("BLOCKSCOUT_VERIFY_API_URL");
        
        vm.startBroadcast(deployerPrivateKey);

        // For testnet environment
        address identityVerificationHub = 0x3e2487a250e2A7b56c7ef5307Fb591Cc8C83623D;
        
        // Generate scope from endpoint
        uint256 scope = 7840932962585485917654569696514392518778085737901983854352670045809033663098;
        
        uint256 attestationId = 1; // 1 for passports
        
        // Configuration parameters
        bool olderThanEnabled = false;
        uint256 olderThan = 18;
        bool forbiddenCountriesEnabled = false;
        uint256[4] memory forbiddenCountriesListPacked = [uint256(0), uint256(0), uint256(0), uint256(0)];
        bool[3] memory ofacEnabled = [true, false, false];

        // Deploy SanctionScreeningCheck
        SanctionScreeningCheck sanctionScreeningCheck = new SanctionScreeningCheck(
            identityVerificationHub,
            scope,
            attestationId,
            olderThanEnabled,
            olderThan,
            forbiddenCountriesEnabled,
            forbiddenCountriesListPacked,
            ofacEnabled
        );

        address deployedAddress = address(sanctionScreeningCheck);
        console.log("SanctionScreeningCheck deployed to:", deployedAddress);
        
        vm.stopBroadcast();

        // Verify the contract on Blockscout
        if (bytes(blockscoutKey).length > 0) {
            verify(
                deployedAddress,
                verifyApiUrl,
                abi.encode(
                    identityVerificationHub,
                    scope,
                    attestationId,
                    olderThanEnabled,
                    olderThan,
                    forbiddenCountriesEnabled,
                    forbiddenCountriesListPacked,
                    ofacEnabled
                )
            );
        }
    }

    function verify(address _contract, string memory _verifyApiUrl, bytes memory _args) internal {
        string[] memory cmd = new string[](3);
        cmd[0] = "forge";
        cmd[1] = "verify-contract";
        cmd[2] = string.concat(
            vm.toString(_contract),
            ":",
            "SanctionScreeningCheck",
            " ",
            "--constructor-args",
            vm.toString(_args),
            " ",
            "--verifier-url",
            _verifyApiUrl,
            " ",
            "--compiler-version",
            "v0.8.28"
        );

        vm.ffi(cmd);
    }
}