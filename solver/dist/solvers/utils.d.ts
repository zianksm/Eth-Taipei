import type { Provider } from "@ethersproject/abstract-provider";
import type { BigNumber } from "@ethersproject/bignumber";
import type { ChainMap, ChainMetadata } from "@hyperlane-xyz/sdk";
import { MultiProvider } from "@hyperlane-xyz/sdk";
import { NonceKeeperWallet } from "../NonceKeeperWallet.js";
export declare function getMultiProvider(chainMetadata: ChainMap<ChainMetadata>): Promise<MultiProvider<object>>;
export declare function getSigner(): Promise<NonceKeeperWallet>;
export declare function retrieveTokenInfo({ chainName, multiProvider, tokenAddress, }: {
    chainName: string;
    multiProvider: MultiProvider;
    tokenAddress: string;
}): Promise<{
    decimals: number;
    symbol: string;
}>;
type TransfersInfo = {
    multiProvider: MultiProvider;
    tokens: Array<{
        amount: BigNumber;
        chainName: string;
        tokenAddress: string;
    }>;
};
export declare function retrieveTransfersInfo({ multiProvider, tokens, }: TransfersInfo): Promise<{
    amount: BigNumber;
    chainName: string;
    decimals: number;
    symbol: string;
}[]>;
export declare function retrieveOriginInfo({ multiProvider, tokens, }: TransfersInfo): Promise<string[]>;
export declare function retrieveTargetInfo({ multiProvider, tokens, }: TransfersInfo): Promise<string[]>;
export declare function retrieveTokenBalance(tokenAddress: string, ownerAddress: string, provider: Provider): Promise<BigNumber>;
export {};
//# sourceMappingURL=utils.d.ts.map