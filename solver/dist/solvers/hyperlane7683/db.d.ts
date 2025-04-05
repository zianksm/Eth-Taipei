declare const db: import("@libsql/client").Client;
export declare const getLastIndexedBlocks: () => Promise<Record<string, {
    blockNumber: number;
    processedIds: Array<string>;
}>>;
export declare const saveBlockNumber: (chainName: string, blockNumber: number, processedIds: string) => void;
export default db;
//# sourceMappingURL=db.d.ts.map