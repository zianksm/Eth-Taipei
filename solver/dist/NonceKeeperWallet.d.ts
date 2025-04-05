import type { Deferrable } from "@ethersproject/properties";
import type { Provider, TransactionRequest, TransactionResponse } from "@ethersproject/providers";
import { Wallet } from "@ethersproject/wallet";
import type { Wordlist } from "@ethersproject/wordlists";
export declare class NonceKeeperWallet extends Wallet {
    connect(provider: Provider): NonceKeeperWallet;
    getNextNonce(): Promise<number>;
    sendTransaction(transaction: Deferrable<TransactionRequest>): Promise<TransactionResponse>;
    static fromMnemonic(mnemonic: string, path?: string, wordlist?: Wordlist): NonceKeeperWallet;
}
//# sourceMappingURL=NonceKeeperWallet.d.ts.map