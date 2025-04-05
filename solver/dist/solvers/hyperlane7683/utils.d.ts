import type { MultiProvider } from "@hyperlane-xyz/sdk";
import type { ResolvedCrossChainOrder } from "./types.js";
export declare const log: import("pino").Logger<never, boolean>;
export declare function settleOrder(fillInstructions: ResolvedCrossChainOrder["fillInstructions"], originChainId: ResolvedCrossChainOrder["originChainId"], orderId: string, multiProvider: MultiProvider, solverName: string): Promise<void>;
//# sourceMappingURL=utils.d.ts.map