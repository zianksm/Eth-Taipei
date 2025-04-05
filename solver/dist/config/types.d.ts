import z from "zod";
export declare const addressSchema: z.ZodEffects<z.ZodString, string, string>;
export declare const addressValueSchema: z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>;
export declare const domainSchema: z.ZodEffects<z.ZodString, string, string>;
export declare const domainValueSchema: z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>;
export declare const AllowBlockListItemSchema: z.ZodObject<{
    senderAddress: z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>;
    destinationDomain: z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>;
    recipientAddress: z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>;
}, "strip", z.ZodTypeAny, {
    senderAddress: string | string[];
    destinationDomain: string | string[];
    recipientAddress: string | string[];
}, {
    senderAddress?: string | string[] | undefined;
    destinationDomain?: string | string[] | undefined;
    recipientAddress?: string | string[] | undefined;
}>;
export declare const AllowBlockListsSchema: z.ZodObject<{
    allowList: z.ZodDefault<z.ZodArray<z.ZodObject<{
        senderAddress: z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>;
        destinationDomain: z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>;
        recipientAddress: z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>;
    }, "strip", z.ZodTypeAny, {
        senderAddress: string | string[];
        destinationDomain: string | string[];
        recipientAddress: string | string[];
    }, {
        senderAddress?: string | string[] | undefined;
        destinationDomain?: string | string[] | undefined;
        recipientAddress?: string | string[] | undefined;
    }>, "many">>;
    blockList: z.ZodDefault<z.ZodArray<z.ZodObject<{
        senderAddress: z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>;
        destinationDomain: z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>;
        recipientAddress: z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>;
    }, "strip", z.ZodTypeAny, {
        senderAddress: string | string[];
        destinationDomain: string | string[];
        recipientAddress: string | string[];
    }, {
        senderAddress?: string | string[] | undefined;
        destinationDomain?: string | string[] | undefined;
        recipientAddress?: string | string[] | undefined;
    }>, "many">>;
}, "strip", z.ZodTypeAny, {
    allowList: {
        senderAddress: string | string[];
        destinationDomain: string | string[];
        recipientAddress: string | string[];
    }[];
    blockList: {
        senderAddress: string | string[];
        destinationDomain: string | string[];
        recipientAddress: string | string[];
    }[];
}, {
    allowList?: {
        senderAddress?: string | string[] | undefined;
        destinationDomain?: string | string[] | undefined;
        recipientAddress?: string | string[] | undefined;
    }[] | undefined;
    blockList?: {
        senderAddress?: string | string[] | undefined;
        destinationDomain?: string | string[] | undefined;
        recipientAddress?: string | string[] | undefined;
    }[] | undefined;
}>;
export type AllowBlockListItem = z.infer<typeof AllowBlockListItemSchema>;
export type AllowBlockLists = z.infer<typeof AllowBlockListsSchema>;
export declare const ConfigSchema: z.ZodRecord<z.ZodString, z.ZodUnion<[z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>, z.ZodUnion<[z.ZodEffects<z.ZodString, string, string>, z.ZodDefault<z.ZodArray<z.ZodEffects<z.ZodString, string, string>, "many">>, z.ZodLiteral<"*">]>]>>;
//# sourceMappingURL=types.d.ts.map