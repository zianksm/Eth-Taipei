
import type { MultiProvider } from "@hyperlane-xyz/sdk";
import { BaseFiller } from '../BaseFiller.js';
import { metadata, allowBlockLists } from './config/index.js';
import type { Offramp7683Metadata, IntentData, ParsedArgs } from './types.js';

import proverSpec from "../../../contracts/out/WebProofProver.sol/WebProofProver.json";
import verifierSpec from "../../../contracts/out/WebProofVerifier.sol/WebProofVerifie.jsonr";

import { log } from '../../logger.js';
import { createVlayerClient } from "@vlayer/sdk";
import { Result } from "@hyperlane-xyz/utils";
import { IntentHub__factory } from "../typechain/factories/offramp7683/contracts/IntentHub__factory.js";
import { Verifier__factory } from "../typechain/factories/offramp7683/contracts/Verifier__factory.js";

import { chainIds, chainIdsToName } from "../../config/index.js";

import web_proof from "../../../contracts/testdata/0.1.0-alpha.8/web_proof.json";
import web_proof_invalid_signature from "../../../contracts/testdata/0.1.0-alpha.8/web_proof_invalid_notary_pub_key.json";


import {
  getConfig,
  createContext,
  deployVlayerContracts,
  writeEnvVariables,
} from "@vlayer/sdk/config";
import { ethers } from "ethers";

let config = getConfig();
const { chain, ethClient, account, proverUrl, confirmations } =
  await createContext(config);
const vlayer = createVlayerClient({
  url: proverUrl,
  token: config.token,
});



export class Offramp7683Filler extends BaseFiller<Offramp7683Metadata, ParsedArgs, IntentData> {
  constructor(multiProvider: MultiProvider) {
    super(multiProvider, allowBlockLists, metadata, log);
  }

  protected async retrieveOriginInfo(
    parsedArgs: ParsedArgs,
    chainName: string
  ): Promise<Array<string>> {
    return [`Origin chain: ${chainName}, Sender: ${parsedArgs.senderAddress}`];
  }

  protected async retrieveTargetInfo(
    parsedArgs: ParsedArgs
  ): Promise<Array<string>> {
    return parsedArgs.recipients.map(
      ({ destinationChainName, recipientAddress }) =>
        `Destination chain: ${destinationChainName}, Recipient: ${recipientAddress}`
    );
  }

  protected async fill(
    parsedArgs: ParsedArgs,
    data: IntentData,
    originChainName: string,
    blockNumber: number
  ): Promise<void> {

    const url = "https://wise.com/en/track/783e11c9ec7846d799716d1a159d2a3b?utm_medium=rmt&utm_source=android&utm_content=activity-page"
    const match = url.match(/^https:\/\/wise\.com\/en\/track\/([^?]+)/);

    if (match) {
      const trackingId = match[1];
      console.log("Tracking ID:", trackingId);

      const signer = this.multiProvider.getSigner(parsedArgs.originChainId);


      console.log("Proving...");

      const hash = await vlayer.prove({
        address: "0x87242d82e64fd3f92c13721ee50d2ba264306ba9",
        functionName: "main",
        proverAbi: proverSpec.abi,
        args: [
          {
            webProofJson: JSON.stringify(web_proof),
          },
          trackingId,
          await signer.getAddress(),
        ],
        chainId: chain.id,

      });

      const result = await vlayer.waitForProvingResult({ hash });

      const [proof, transferId, recipient, amount] = result as any;

      const verifier = Verifier__factory.connect(metadata.verifier, signer);

      const tx = await verifier.settleVerified(proof, transferId, recipient, amount, parsedArgs.orderId)

      await tx.wait()

      console.log("Has Proof");
    } else {
      console.log("No match found");
    }
  }

  protected async prepareIntent(
    parsedArgs: ParsedArgs
  ): Promise<Result<IntentData>> {
    try {
      await super.prepareIntent(parsedArgs);

      const signer = this.multiProvider.getSigner(parsedArgs.originChainId);

      const intentHubContractInstance = IntentHub__factory.connect(metadata.intentHub, signer)

      const tx = await intentHubContractInstance.reserve(parsedArgs.orderId, {
        value: ethers.utils.parseEther("0.000000000001")
      })
      await tx.wait();

      return { success: true, data: {} };
    } catch (error: any) {
      return {
        error: error.message ?? "Failed to prepare Offramp7683 Intent.",
        success: false,
      };
    }
  }

  protected async settle(
    parsedArgs: ParsedArgs,
    data: IntentData,
    originChainName: string,
    blockNumber: number
  ): Promise<void> {
    // TODO: Implement settlement logic if needed
  }
}

export const create = (multiProvider: MultiProvider) =>
  new Offramp7683Filler(multiProvider).create();
