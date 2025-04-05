import z from "zod";
export declare const addressSchema: z.ZodEffects<z.ZodString, string, string>;
export declare const BaseMetadataSchema: z.ZodObject<{
    protocolName: z.ZodString;
    intentSources: z.ZodArray<z.ZodObject<{
        address: z.ZodEffects<z.ZodString, string, string>;
        chainName: z.ZodEffects<z.ZodString, string, string>;
        pollInterval: z.ZodOptional<z.ZodNumber>;
        confirmationBlocks: z.ZodOptional<z.ZodNumber>;
        initialBlock: z.ZodOptional<z.ZodNumber>;
        processedIds: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
    }, "strip", z.ZodTypeAny, {
        address: string;
        chainName: string;
        pollInterval?: number | undefined;
        confirmationBlocks?: number | undefined;
        initialBlock?: number | undefined;
        processedIds?: string[] | undefined;
    }, {
        address: string;
        chainName: string;
        pollInterval?: number | undefined;
        confirmationBlocks?: number | undefined;
        initialBlock?: number | undefined;
        processedIds?: string[] | undefined;
    }>, "many">;
    customRules: z.ZodOptional<z.ZodObject<{
        rules: z.ZodArray<z.ZodObject<{
            name: z.ZodString;
            args: z.ZodOptional<z.ZodAny>;
        }, "strip", z.ZodTypeAny, {
            name: string;
            args?: any;
        }, {
            name: string;
            args?: any;
        }>, "many">;
        keepBaseRules: z.ZodOptional<z.ZodBoolean>;
    }, "strip", z.ZodTypeAny, {
        rules: {
            name: string;
            args?: any;
        }[];
        keepBaseRules?: boolean | undefined;
    }, {
        rules: {
            name: string;
            args?: any;
        }[];
        keepBaseRules?: boolean | undefined;
    }>>;
}, "strip", z.ZodTypeAny, {
    protocolName: string;
    intentSources: {
        address: string;
        chainName: string;
        pollInterval?: number | undefined;
        confirmationBlocks?: number | undefined;
        initialBlock?: number | undefined;
        processedIds?: string[] | undefined;
    }[];
    customRules?: {
        rules: {
            name: string;
            args?: any;
        }[];
        keepBaseRules?: boolean | undefined;
    } | undefined;
}, {
    protocolName: string;
    intentSources: {
        address: string;
        chainName: string;
        pollInterval?: number | undefined;
        confirmationBlocks?: number | undefined;
        initialBlock?: number | undefined;
        processedIds?: string[] | undefined;
    }[];
    customRules?: {
        rules: {
            name: string;
            args?: any;
        }[];
        keepBaseRules?: boolean | undefined;
    } | undefined;
}>;
export type BaseMetadata = z.infer<typeof BaseMetadataSchema>;
export type RulesMap<TRule> = Record<string, (args?: any) => TRule>;
export type BuildRules<TRule> = {
    base?: Array<TRule>;
    custom?: RulesMap<TRule>;
};
export interface BaseIntentData {
}
//# sourceMappingURL=types.d.ts.map