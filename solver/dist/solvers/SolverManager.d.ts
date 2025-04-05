import type { MultiProvider } from "@hyperlane-xyz/sdk";
import { Logger } from "pino";
export declare class SolverManager {
    private readonly multiProvider;
    private readonly log;
    private activeListeners;
    constructor(multiProvider: MultiProvider, log: Logger);
    initializeSolvers(): Promise<void>;
    private initializeSolver;
    shutdown(): void;
}
//# sourceMappingURL=SolverManager.d.ts.map