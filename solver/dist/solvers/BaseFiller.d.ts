import type { MultiProvider } from "@hyperlane-xyz/sdk";
import type { Result } from "@hyperlane-xyz/utils";
import { type GenericAllowBlockLists } from "../config/index.js";
import type { Logger } from "../logger.js";
import type { BaseMetadata, BuildRules } from "./types.js";
export type ParsedArgs = {
    orderId: string;
    senderAddress: string;
    recipients: Array<{
        destinationChainName: string;
        recipientAddress: string;
    }>;
};
export type BaseRule<TMetadata extends BaseMetadata, TParsedArgs extends ParsedArgs, TIntentData extends unknown> = (parsedArgs: TParsedArgs, context: BaseFiller<TMetadata, TParsedArgs, TIntentData>) => Promise<Result<string>>;
export declare abstract class BaseFiller<TMetadata extends BaseMetadata, TParsedArgs extends ParsedArgs, TIntentData extends unknown> {
    readonly multiProvider: MultiProvider;
    readonly allowBlockLists: GenericAllowBlockLists;
    readonly metadata: TMetadata;
    readonly log: Logger;
    rules: Array<BaseRule<TMetadata, TParsedArgs, TIntentData>>;
    protected constructor(multiProvider: MultiProvider, allowBlockLists: GenericAllowBlockLists, metadata: TMetadata, log: Logger, rulesConfig?: BuildRules<BaseRule<TMetadata, TParsedArgs, TIntentData>>);
    create(): (parsedArgs: TParsedArgs, originChainName: string, blockNumber: number) => Promise<void>;
    protected abstract retrieveOriginInfo(parsedArgs: TParsedArgs, chainName: string): Promise<Array<string>>;
    protected abstract retrieveTargetInfo(parsedArgs: TParsedArgs): Promise<Array<string>>;
    protected prepareIntent(parsedArgs: TParsedArgs): Promise<Result<TIntentData>>;
    protected evaluateRules(parsedArgs: TParsedArgs): Promise<Result<string>>;
    protected abstract fill(parsedArgs: TParsedArgs, data: TIntentData, originChainName: string, blockNumber: number): Promise<void>;
    protected settleOrder(parsedArgs: TParsedArgs, data: TIntentData, originChainName: string): Promise<void>;
    protected isAllowedIntent({ senderAddress, recipients, }: {
        senderAddress: string;
        recipients: Array<{
            destinationChainName: string;
            recipientAddress: string;
        }>;
    }): boolean;
    private buildRules;
}
//# sourceMappingURL=BaseFiller.d.ts.map