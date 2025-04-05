import type { TypedListener } from "../../typechain/common.js";
import type { IntentCreatedEvent, IntentSource } from "../../typechain/eco/contracts/IntentSource.js";
import { BaseListener } from "../BaseListener.js";
import type { ParsedArgs } from "./types.js";
export declare class EcoListener extends BaseListener<IntentSource, IntentCreatedEvent, ParsedArgs> {
    constructor();
    protected parseEventArgs([_hash, _creator, _destinationChain, _targets, _data, _rewardTokens, _rewardAmounts, _expiryTime, nonce, _prover,]: Parameters<TypedListener<IntentCreatedEvent>>): {
        orderId: string;
        senderAddress: string;
        recipients: {
            destinationChainName: string;
            recipientAddress: string;
        }[];
        _hash: string;
        _creator: string;
        _destinationChain: import("ethers").BigNumber;
        _targets: string[];
        _data: string[];
        _rewardTokens: string[];
        _rewardAmounts: import("ethers").BigNumber[];
        _expiryTime: import("ethers").BigNumber;
        nonce: string;
        _prover: string;
    };
}
export declare const create: () => (handler: (args: ParsedArgs, originChainName: string, blockNumber: number) => void) => () => void;
//# sourceMappingURL=listener.d.ts.map