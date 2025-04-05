
import { BaseMetadataSchema } from '../../types.js';

// TODO: Update with actual contract address and chain name before using in production
const metadata = {
  protocolName: 'offramp7683',
  intentHub: "",
  prover: "0x87242d82e64fd3f92c13721ee50d2ba264306ba9",
  verifier: "0xfbf158b367596278ed58dce1a3169c69ca3cbb50",
  verifierChainName:"optimismSepolia"
};

BaseMetadataSchema.parse(metadata);
export default metadata;
