import type { TypedListener } from "../../typechain/common.js";
import type { Hyperlane7683, OpenEvent } from "../../typechain/hyperlane7683/contracts/Hyperlane7683.js";
import { BaseListener } from "../BaseListener.js";
import type { OpenEventArgs, Hyperlane7683Metadata } from "./types.js";
export declare class Hyperlane7683Listener extends BaseListener<Hyperlane7683, OpenEvent, OpenEventArgs> {
    constructor(metadata: Hyperlane7683Metadata);
    protected parseEventArgs(args: Parameters<TypedListener<OpenEvent>>): {
        orderId: string;
        senderAddress: string;
        recipients: {
            destinationChainName: string;
            recipientAddress: string;
        }[];
        resolvedOrder: import("../../typechain/hyperlane7683/contracts/Hyperlane7683.js").ResolvedCrossChainOrderStructOutput;
    };
}
export declare const create: () => Promise<(handler: (args: OpenEventArgs, originChainName: string, blockNumber: number) => void) => () => void>;
//# sourceMappingURL=listener.d.ts.map