import { type MultiProvider } from "@hyperlane-xyz/sdk";
import { type Result } from "@hyperlane-xyz/utils";
import { BaseFiller } from "../BaseFiller.js";
import { BuildRules, RulesMap } from "../types.js";
import type { EcoMetadata, IntentData, ParsedArgs } from "./types.js";
export type EcoRule = EcoFiller["rules"][number];
export declare class EcoFiller extends BaseFiller<EcoMetadata, ParsedArgs, IntentData> {
    constructor(multiProvider: MultiProvider, rules?: BuildRules<EcoRule>);
    protected retrieveOriginInfo(parsedArgs: ParsedArgs, chainName: string): Promise<string[]>;
    protected retrieveTargetInfo(parsedArgs: ParsedArgs): Promise<string[]>;
    protected prepareIntent(parsedArgs: ParsedArgs): Promise<Result<IntentData>>;
    protected fill(parsedArgs: ParsedArgs, data: IntentData, originChainName: string): Promise<void>;
    settleOrder(parsedArgs: ParsedArgs, data: IntentData, originChainName: string): Promise<void>;
}
export declare const create: (multiProvider: MultiProvider, customRules?: RulesMap<EcoRule>) => (parsedArgs: ParsedArgs, originChainName: string, blockNumber: number) => Promise<void>;
//# sourceMappingURL=filler.d.ts.map