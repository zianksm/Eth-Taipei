import type { MultiProvider } from "@hyperlane-xyz/sdk";
import type { IntentCreatedEventObject } from "../../typechain/eco/contracts/IntentSource.js";
export declare const log: import("pino").Logger<never, boolean>;
export declare function withdrawRewards(intent: IntentCreatedEventObject, originChainName: string, multiProvider: MultiProvider, protocolName: string): Promise<void>;
//# sourceMappingURL=utils.d.ts.map