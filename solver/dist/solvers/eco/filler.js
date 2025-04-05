import { Zero } from "@ethersproject/constants";
import { chainIds, chainIdsToName } from "../../config/index.js";
import { Erc20__factory } from "../../typechain/factories/contracts/Erc20__factory.js";
import { EcoAdapter__factory } from "../../typechain/factories/eco/contracts/EcoAdapter__factory.js";
import { BaseFiller } from "../BaseFiller.js";
import { retrieveOriginInfo, retrieveTargetInfo, retrieveTokenBalance, } from "../utils.js";
import { allowBlockLists, metadata } from "./config/index.js";
import { log, withdrawRewards } from "./utils.js";
export class EcoFiller extends BaseFiller {
    constructor(multiProvider, rules) {
        super(multiProvider, allowBlockLists, metadata, log, rules);
    }
    retrieveOriginInfo(parsedArgs, chainName) {
        const originTokens = parsedArgs._rewardTokens.map((tokenAddress, index) => {
            const amount = parsedArgs._rewardAmounts[index];
            return { amount, chainName, tokenAddress };
        });
        return retrieveOriginInfo({
            multiProvider: this.multiProvider,
            tokens: originTokens,
        });
    }
    retrieveTargetInfo(parsedArgs) {
        const chainId = parsedArgs._destinationChain.toString();
        const chainName = chainIdsToName[chainId];
        const erc20Interface = Erc20__factory.createInterface();
        const targetTokens = parsedArgs._targets.map((tokenAddress, index) => {
            const [, amount] = erc20Interface.decodeFunctionData("transfer", parsedArgs._data[index]);
            return { amount, chainName, tokenAddress };
        });
        return retrieveTargetInfo({
            multiProvider: this.multiProvider,
            tokens: targetTokens,
        });
    }
    async prepareIntent(parsedArgs) {
        const chainName = this.multiProvider.getChainName(parsedArgs._destinationChain.toString());
        const adapterAddress = this.metadata.adapters[chainName];
        if (!adapterAddress) {
            return {
                error: "No adapter found for destination chain",
                success: false,
            };
        }
        try {
            await super.prepareIntent(parsedArgs);
            return { data: { adapterAddress }, success: true };
        }
        catch (error) {
            return {
                error: error.message ?? "Failed to prepare Eco Intent.",
                success: false,
            };
        }
    }
    async fill(parsedArgs, data, originChainName) {
        this.log.info({
            msg: "Filling Intent",
            intent: `${this.metadata.protocolName}-${parsedArgs._hash}`,
        });
        this.log.debug({
            msg: "Approving tokens",
            protocolName: this.metadata.protocolName,
            intentHash: parsedArgs._hash,
            adapterAddress: data.adapterAddress,
        });
        const erc20Interface = Erc20__factory.createInterface();
        const requiredAmountsByTarget = parsedArgs._targets.reduce((acc, target, index) => {
            const [, amount] = erc20Interface.decodeFunctionData("transfer", parsedArgs._data[index]);
            acc[target] ||= Zero;
            acc[target] = acc[target].add(amount);
            return acc;
        }, {});
        const destinationChainId = parsedArgs._destinationChain.toString();
        const signer = this.multiProvider.getSigner(destinationChainId);
        await Promise.all(Object.entries(requiredAmountsByTarget).map(async ([target, requiredAmount]) => {
            const erc20 = Erc20__factory.connect(target, signer);
            const tx = await erc20.approve(data.adapterAddress, requiredAmount);
            await tx.wait();
        }));
        const ecoAdapter = EcoAdapter__factory.connect(data.adapterAddress, signer);
        const claimantAddress = await this.multiProvider.getSignerAddress(originChainName);
        const { _targets, _data, _expiryTime, nonce, _hash, _prover } = parsedArgs;
        const value = await ecoAdapter.fetchFee(chainIds[originChainName], [_hash], [claimantAddress], _prover);
        const tx = await ecoAdapter.fulfillHyperInstant(chainIds[originChainName], _targets, _data, _expiryTime, nonce, claimantAddress, _hash, _prover, { value });
        const receipt = await tx.wait();
        this.log.info({
            msg: "Filled Intent",
            intent: `${this.metadata.protocolName}-${parsedArgs._hash}`,
            txDetails: receipt.transactionHash,
            txHash: receipt.transactionHash,
        });
    }
    settleOrder(parsedArgs, data, originChainName) {
        return withdrawRewards(parsedArgs, originChainName, this.multiProvider, this.metadata.protocolName);
    }
}
const enoughBalanceOnDestination = async (parsedArgs, context) => {
    const erc20Interface = Erc20__factory.createInterface();
    const requiredAmountsByTarget = parsedArgs._targets.reduce((acc, target, index) => {
        const [, amount] = erc20Interface.decodeFunctionData("transfer", parsedArgs._data[index]);
        acc[target] ||= Zero;
        acc[target] = acc[target].add(amount);
        return acc;
    }, {});
    const chainId = parsedArgs._destinationChain.toString();
    const fillerAddress = await context.multiProvider.getSignerAddress(chainId);
    const provider = context.multiProvider.getProvider(chainId);
    for (const tokenAddress in requiredAmountsByTarget) {
        const balance = await retrieveTokenBalance(tokenAddress, fillerAddress, provider);
        if (balance.lt(requiredAmountsByTarget[tokenAddress])) {
            return {
                error: `Insufficient balance on destination chain ${chainId} for token ${tokenAddress}`,
                success: false,
            };
        }
    }
    return { data: "Enough tokens to fulfill the intent", success: true };
};
export const create = (multiProvider, customRules) => {
    return new EcoFiller(multiProvider, {
        base: [enoughBalanceOnDestination],
        custom: customRules,
    }).create();
};
//# sourceMappingURL=filler.js.map