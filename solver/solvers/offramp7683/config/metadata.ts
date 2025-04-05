
import { BaseMetadataSchema } from '../../types.js';

// TODO: Update with actual contract address and chain name before using in production
const metadata = {
  protocolName: 'offramp7683',
  intentSources: [],
  // intentHub: "",
  prover: "0x4bbf0c5225d905540b261058cd16249a2bc4f484",
  verifier: "0x80f47510dc48c10e9ea01b8eb63835e2945c5ae9",
  verifierChainName: "optimismSepolia",
  proverExamplePk: "0xaf055ea55038249f059cf49e216d15ee82e68467182d4f76cd13d7769ee4a113",
  proverJsonRpcNetwork: "https://sepolia.optimism.io",
  proverJsonRpc:"https://test-prover.vlayer.xyz"
};

BaseMetadataSchema.parse(metadata);
export default metadata;
