import { solversConfig } from "../config/solvers.js";
import * as solvers from "./index.js";
export class SolverManager {
    multiProvider;
    log;
    activeListeners = [];
    constructor(multiProvider, log) {
        this.multiProvider = multiProvider;
        this.log = log;
    }
    async initializeSolvers() {
        for (const [solverName, config] of Object.entries(solversConfig)) {
            if (!config.enabled) {
                this.log.info(`Solver ${solverName} is disabled, skipping...`);
                continue;
            }
            try {
                await this.initializeSolver(solverName);
            }
            catch (error) {
                this.log.error(`Failed to initialize solver ${solverName}: ${error.message}`);
                throw error;
            }
        }
    }
    async initializeSolver(name) {
        const solver = solvers[name];
        if (!solver) {
            throw new Error(`Solver ${name} not found`);
        }
        this.log.info(`Initializing solver: ${name}`);
        const listener = await solver.listener.create();
        const filler = solver.filler.create(this.multiProvider, solver.rules);
        this.activeListeners.push(listener(filler));
    }
    shutdown() {
        this.log.info("Shutting down solvers...");
        // Cleanup logic for active listeners if needed
        this.activeListeners.forEach((stopListener) => stopListener());
        this.activeListeners = [];
    }
}
//# sourceMappingURL=SolverManager.js.map