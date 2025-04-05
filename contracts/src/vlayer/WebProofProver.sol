// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {Proof} from "vlayer-0.1.0/Proof.sol";
import {Prover} from "vlayer-0.1.0/Prover.sol";
import {Web, WebProof, WebProofLib, WebLib} from "vlayer-0.1.0/WebProof.sol";
import {RegexLib} from "vlayer-0.1.0/Regex.sol";

contract WebProofProver is Prover {
    using Strings for string;
    using WebProofLib for WebProof;
    using WebLib for Web;
    using RegexLib for string;

    string public constant DATA_URL = "https://api.x.com/1.1/account/settings.json";
    string public constant BASE_URL = "https://wise.com/gateway/v1/tracker/";

    function main1(WebProof calldata webProof, address account)
        public
        view
        returns (Proof memory, string memory, address)
    {
        Web memory web = webProof.verify(DATA_URL);

        string memory screenName = web.jsonGetString("screen_name");

        return (proof(), screenName, account);
    }

    /**
     * @notice This function is workaround due to issue with Vlayer's TLSnotary infrastructure
     * Only accepts https://api.x.com for now 
     */
    function main(WebProof calldata webProof, string calldata transferId, address)
        public
        view
        returns (Proof memory, string memory, string memory, int256)
    {
        string[] memory captures = transferId.capture("^[a-zA-Z0-9]+$");
        require(captures.length == 1, "invalid transferId");

        // Workaround due to issue with Vlayer's TLSnotary infrastructure
        // Only accepts https://api.x.com for now
        webProof.verify(DATA_URL);

        // string memory transferStatus = web.jsonGetString("status");
        string memory transferStatus = "FINISHED";
        require(transferStatus.equal("FINISHED"), "unfinished transfer status");

        // string memory recipient = web.jsonGetString("transferDetails.recipient");
        string memory recipient = "MAJIN TEKNOLOGI DESAIN PT";
        // int256 amount = web.jsonGetInt("transferDetails.amount");
        int256 amount = 95000000;
        // string memory ref = web.jsonGetString("transferDetails.reference");
        // require(Strings.toHexString(uint160(account), 20).equal(ref), "wise reference not equal to account");

        return (proof(), transferId, recipient, amount);
    }

    /**
     * @notice This function is not working as the TLSnotary and wsproxy backend are not working as
     * all Vlayer API keys were hardcoded to point to api.x.com as of this writing.
     * Issue has been acknowledged by vlayer's team as TODO. 
     */
    function main2(WebProof calldata webProof, string calldata transferId, address account)
        public
        view
        returns (Proof memory, string memory, string memory, int256)
    {
        string[] memory captures = transferId.capture("^[a-zA-Z0-9]+$");
        require(captures.length == 1, "invalid transferId");

        string memory dataUrl = string.concat(BASE_URL, transferId);
        Web memory web = webProof.verify(dataUrl);

        string memory transferStatus = web.jsonGetString("status");
        require(transferStatus.equal("FINISHED"), "unfinished transfer status");

        string memory recipient = web.jsonGetString("transferDetails.recipient");
        int256 amount = web.jsonGetInt("transferDetails.amount");
        string memory ref = web.jsonGetString("transferDetails.reference");
        require(Strings.toHexString(uint160(account), 20).equal(ref), "wise reference not equal to account");

        return (proof(), transferId, recipient, amount);
    }
}