// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {SelfVerificationRoot} from "@selfxyz/contracts/abstract/SelfVerificationRoot.sol";
import {ISelfVerificationRoot} from "@selfxyz/contracts/interfaces/ISelfVerificationRoot.sol";
import {IVcAndDiscloseCircuitVerifier} from "@selfxyz/contracts/interfaces/IVcAndDiscloseCircuitVerifier.sol";
import {IIdentityVerificationHubV1} from "@selfxyz/contracts/interfaces/IIdentityVerificationHubV1.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Formatter} from "@selfxyz/contracts/libraries/Formatter.sol";
import {CircuitAttributeHandler} from "@selfxyz/contracts/libraries/CircuitAttributeHandler.sol";
import {CircuitConstants} from "@selfxyz/contracts/constants/CircuitConstants.sol";
import {IIdentityRegistryV1} from "@selfxyz/contracts/interfaces/IIdentityRegistryV1.sol";

contract SanctionScreeningCheck is SelfVerificationRoot {
    mapping(address user => bool isWhitelisted) public whitelistedUsers;

    constructor(
        address _identityVerificationHub,
        uint256 _scope,
        uint256 _attestationId,
        bool _olderThanEnabled,
        uint256 _olderThan,
        bool _forbiddenCountriesEnabled,
        uint256[4] memory _forbiddenCountriesListPacked,
        bool[3] memory _ofacEnabled
    )
        SelfVerificationRoot(
            _identityVerificationHub, // Address of our Verification Hub, e.g., "0x3e2487a250e2A7b56c7ef5307Fb591Cc8C83623D"
            _scope, // An application-specific identifier for the integrated contract
            _attestationId, // The id specifying the type of document to verify (e.g., 1 for passports)
            _olderThanEnabled, // Flag to enable age verification
            _olderThan, // The minimum age required for verification
            _forbiddenCountriesEnabled, // Flag to enable forbidden countries verification
            _forbiddenCountriesListPacked, // Packed data representing the list of forbidden countries
            _ofacEnabled // Flag to enable OFAC check
        )
    {}

    function whitelistUser(IVcAndDiscloseCircuitVerifier.VcAndDiscloseProof memory proof) public {
        // Check OFAC sanctioned
        verifySelfProof(proof);
        whitelistedUsers[msg.sender] = true;
    }

    function verifySelfProof(IVcAndDiscloseCircuitVerifier.VcAndDiscloseProof memory proof)
        public
        override
        view
    {
        _verifyScope(proof);
        _verifyAttestationId(proof);
        _identityVerificationHub
            .verifyVcAndDisclose(
            IIdentityVerificationHubV1.VcAndDiscloseHubProof({
                olderThanEnabled: _verificationConfig.olderThanEnabled,
                olderThan: _verificationConfig.olderThan,
                forbiddenCountriesEnabled: _verificationConfig.forbiddenCountriesEnabled,
                forbiddenCountriesListPacked: _verificationConfig.forbiddenCountriesListPacked,
                ofacEnabled: _verificationConfig.ofacEnabled,
                vcAndDiscloseProof: proof
            })
        );
    }

    // Check against merkle tree root on verifier contract
    function _verifyScope(IVcAndDiscloseCircuitVerifier.VcAndDiscloseProof memory proof) internal view {
        if (_scope != proof.pubSignals[CircuitConstants.VC_AND_DISCLOSE_SCOPE_INDEX]) {
            revert InvalidScope();
        }
    }

    // Verify document verified type (passport)
    function _verifyAttestationId(IVcAndDiscloseCircuitVerifier.VcAndDiscloseProof memory proof) internal view {
        if (_attestationId != proof.pubSignals[CircuitConstants.VC_AND_DISCLOSE_ATTESTATION_ID_INDEX]) {
            revert InvalidAttestationId();
        }
    }
}
