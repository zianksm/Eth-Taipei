import { chainIdsToName } from "../../config/index.js";
import { Hyperlane7683__factory } from "../../typechain/factories/hyperlane7683/contracts/Hyperlane7683__factory.js";
import { BaseListener } from "../BaseListener.js";
import { metadata } from "./config/index.js";
import { log } from "./utils.js";
import { getLastIndexedBlocks } from "./db.js";
export class Hyperlane7683Listener extends BaseListener {
    constructor(metadata) {
        const { intentSources, protocolName } = metadata;
        const hyperlane7683Metadata = { contracts: intentSources, protocolName };
        super(Hyperlane7683__factory, "Open", hyperlane7683Metadata, log);
    }
    parseEventArgs(args) {
        const [orderId, resolvedOrder] = args;
        return {
            orderId,
            senderAddress: resolvedOrder.user,
            recipients: resolvedOrder.maxSpent.map(({ chainId, recipient }) => ({
                destinationChainName: chainIdsToName[chainId.toString()],
                recipientAddress: recipient,
            })),
            resolvedOrder,
        };
    }
}
export const create = async () => {
    const { intentSources } = metadata;
    const blocksByChain = await getLastIndexedBlocks();
    metadata.intentSources = intentSources.map((intentSource) => {
        const chainBlockNumber = blocksByChain[intentSource.chainName]?.blockNumber;
        if (chainBlockNumber &&
            chainBlockNumber >= (intentSource.initialBlock ?? 0)) {
            return {
                ...intentSource,
                initialBlock: blocksByChain[intentSource.chainName].blockNumber,
                processedIds: blocksByChain[intentSource.chainName].processedIds,
            };
        }
        return intentSource;
    });
    return new Hyperlane7683Listener(metadata).create();
};
//# sourceMappingURL=listener.js.map