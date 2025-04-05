import z from "zod";
import { addressSchema } from "../../config/types.js";
import type { IntentCreatedEventObject } from "../../typechain/eco/contracts/IntentSource.js";
export declare const EcoMetadataSchema: z.ZodObject<z.objectUtil.extendShape<{
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
}, {
    adapters: z.ZodRecord<z.ZodEffects<z.ZodString, string, string>, z.ZodEffects<z.ZodString, string, string>>;
}>, "strip", z.ZodTypeAny, {
    protocolName: string;
    intentSources: {
        address: string;
        chainName: string;
        pollInterval?: number | undefined;
        confirmationBlocks?: number | undefined;
        initialBlock?: number | undefined;
        processedIds?: string[] | undefined;
    }[];
    adapters: Record<string, string>;
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
    adapters: Record<string, string>;
    customRules?: {
        rules: {
            name: string;
            args?: any;
        }[];
        keepBaseRules?: boolean | undefined;
    } | undefined;
}>;
export type EcoMetadata = z.infer<typeof EcoMetadataSchema>;
export type IntentData = {
    adapterAddress: z.infer<typeof addressSchema>;
};
export type ParsedArgs = IntentCreatedEventObject & {
    orderId: string;
    senderAddress: IntentCreatedEventObject["_creator"];
    recipients: Array<{
        destinationChainName: string;
        recipientAddress: string;
    }>;
};
//# sourceMappingURL=types.d.ts.map