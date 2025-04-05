import type { MultiProvider } from "@hyperlane-xyz/sdk";
import { type Result } from "@hyperlane-xyz/utils";
import type { Hyperlane7683Metadata, IntentData, OpenEventArgs } from "./types.js";
import { BaseFiller } from "../BaseFiller.js";
import { BuildRules, RulesMap } from "../types.js";
export type Hyperlane7683Rule = Hyperlane7683Filler["rules"][number];
declare class Hyperlane7683Filler extends BaseFiller<Hyperlane7683Metadata, OpenEventArgs, IntentData> {
    constructor(multiProvider: MultiProvider, rules?: BuildRules<Hyperlane7683Rule>);
    protected retrieveOriginInfo(parsedArgs: OpenEventArgs): Promise<string[]>;
    protected retrieveTargetInfo(parsedArgs: OpenEventArgs): Promise<string[]>;
    protected prepareIntent(parsedArgs: OpenEventArgs): Promise<Result<IntentData>>;
    protected fill(parsedArgs: OpenEventArgs, data: IntentData, originChainName: string, blockNumber: number): Promise<void>;
    settleOrder(parsedArgs: OpenEventArgs, data: IntentData): Promise<void>;
}
export declare const create: (multiProvider: MultiProvider, customRules?: RulesMap<Hyperlane7683Rule>) => (parsedArgs: OpenEventArgs, originChainName: string, blockNumber: number) => Promise<void>;
export {};
//# sourceMappingURL=filler.d.ts.map