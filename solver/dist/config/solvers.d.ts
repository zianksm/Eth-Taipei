import { z } from "zod";
export declare const SolverConfigSchema: z.ZodObject<{
    enabled: z.ZodBoolean;
}, "strip", z.ZodTypeAny, {
    enabled: boolean;
}, {
    enabled: boolean;
}>;
export type SolverConfig = z.infer<typeof SolverConfigSchema>;
export declare const solversConfig: Record<string, SolverConfig>;
export type SolverName = keyof typeof solversConfig;
//# sourceMappingURL=solvers.d.ts.map