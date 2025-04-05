import type { Provider } from "@ethersproject/providers";
import type { Contract, EventFilter, Signer } from "ethers";
import type { Logger } from "../logger.js";
import type { TypedEvent, TypedListener } from "../typechain/common.js";
import type { ParsedArgs } from "./BaseFiller.js";
export declare abstract class BaseListener<TContract extends Contract, TEvent extends TypedEvent, TParsedArgs extends ParsedArgs> {
    private readonly contractFactory;
    private readonly eventName;
    private readonly metadata;
    private readonly log;
    protected constructor(contractFactory: {
        connect(address: string, signerOrProvider: Signer | Provider): TContract;
    }, eventName: Extract<keyof TContract["filters"], string>, metadata: {
        contracts: Array<{
            address: string;
            chainName: string;
            pollInterval?: number;
            confirmationBlocks?: number;
            initialBlock?: number;
            processedIds?: string[];
        }>;
        protocolName: string;
    }, log: Logger);
    private lastProcessedBlocks;
    private defaultPollInterval;
    private defaultMaxBlockRange;
    private pollIntervals;
    create(): (handler: (args: TParsedArgs, originChainName: string, blockNumber: number) => void) => () => void;
    protected pollEvents(chainName: string, contract: TContract, filter: EventFilter, handler: (args: TParsedArgs, originChainName: string, blockNumber: number) => void, confirmationBlocks?: number): Promise<void>;
    protected processPrevBlocks(chainName: string, contract: TContract, filter: EventFilter, from: number, to: number, handler: (args: TParsedArgs, originChainName: string, blockNumber: number) => void, processedIds?: string[]): Promise<void>;
    protected abstract parseEventArgs(args: Parameters<TypedListener<TEvent>>): TParsedArgs;
}
//# sourceMappingURL=BaseListener.d.ts.map