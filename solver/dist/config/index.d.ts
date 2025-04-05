import z from "zod";
import { ConfigSchema } from "./types.js";
declare const LOG_FORMAT: string | undefined;
declare const LOG_LEVEL: string | undefined;
declare const MNEMONIC: string | undefined;
declare const PRIVATE_KEY: string | undefined;
export { LOG_FORMAT, LOG_LEVEL, MNEMONIC, PRIVATE_KEY };
type GenericAllowBlockListItem = z.infer<typeof ConfigSchema>;
export type GenericAllowBlockLists = {
    allowList: GenericAllowBlockListItem[];
    blockList: GenericAllowBlockListItem[];
};
type Item = {
    [Key in keyof GenericAllowBlockListItem]: string;
};
export declare function isAllowedIntent(allowBlockLists: GenericAllowBlockLists, transaction: Item): boolean;
declare const chainIds: {
    [key: string]: number;
}, chainNames: string[], chainIdsToName: {
    [key: string]: string;
};
export { chainIds, chainIdsToName, chainNames };
//# sourceMappingURL=index.d.ts.map