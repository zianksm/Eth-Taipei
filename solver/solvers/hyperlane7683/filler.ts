import type { BigNumber } from "@ethersproject/bignumber";
import { AddressZero, MaxUint256, Zero } from "@ethersproject/constants";
import type { MultiProvider } from "@hyperlane-xyz/sdk";
import {
  addressToBytes32,
  bytes32ToAddress,
  type Result,
} from "@hyperlane-xyz/utils";

import { Erc20__factory } from "../../typechain/factories/contracts/Erc20__factory.js";
import { Hyperlane7683__factory } from "../../typechain/factories/hyperlane7683/contracts/Hyperlane7683__factory.js";
import type {
  Hyperlane7683Metadata,
  IntentData,
  OpenEventArgs,
} from "./types.js";
import { log, settleOrder } from "./utils.js";

import { chainIdsToName } from "../../config/index.js";
import { BaseFiller } from "../BaseFiller.js";
import { BuildRules, RulesMap } from "../types.js";
import {
  retrieveOriginInfo,
  retrieveTargetInfo,
  retrieveTokenBalance,
} from "../utils.js";
import { allowBlockLists, metadata } from "./config/index.js";
import { saveBlockNumber } from "./db.js";

export type Hyperlane7683Rule = Hyperlane7683Filler["rules"][number];

class Hyperlane7683Filler extends BaseFiller<
  Hyperlane7683Metadata,
  OpenEventArgs,
  IntentData
> {
  constructor(
    multiProvider: MultiProvider,
    rules?: BuildRules<Hyperlane7683Rule>,
  ) {
    super(multiProvider, allowBlockLists, metadata, log, rules);
  }

  protected async retrieveOriginInfo(parsedArgs: OpenEventArgs) {
    const originTokens = parsedArgs.resolvedOrder.minReceived.map(
      ({ amount, chainId, token }) => {
        const tokenAddress = bytes32ToAddress(token);
        const chainName = chainIdsToName[chainId.toString()];
        return { amount, chainName, tokenAddress };
      },
    );

    return retrieveOriginInfo({
      multiProvider: this.multiProvider,
      tokens: originTokens,
    });
  }

  protected async retrieveTargetInfo(parsedArgs: OpenEventArgs) {
    const targetTokens = parsedArgs.resolvedOrder.maxSpent.map(
      ({ amount, chainId, token }) => {
        const tokenAddress = bytes32ToAddress(token);
        const chainName = chainIdsToName[chainId.toString()];
        return { amount, chainName, tokenAddress };
      },
    );

    return retrieveTargetInfo({
      multiProvider: this.multiProvider,
      tokens: targetTokens,
    });
  }

  protected async prepareIntent(
    parsedArgs: OpenEventArgs,
  ): Promise<Result<IntentData>> {
    const { fillInstructions, maxSpent } = parsedArgs.resolvedOrder;

    try {
      await super.prepareIntent(parsedArgs);

      return { data: { fillInstructions, maxSpent }, success: true };
    } catch (error: any) {
      return {
        error: error.message ?? "Failed to prepare Hyperlane7683 Intent.",
        success: false,
      };
    }
  }

  protected async fill(
    parsedArgs: OpenEventArgs,
    data: IntentData,
    originChainName: string,
    blockNumber: number,
  ) {
    this.log.info({
      msg: "Filling Intent",
      intent: `${this.metadata.protocolName}-${parsedArgs.orderId}`,
    });

    await Promise.all(
      data.maxSpent.map(
        async ({ amount, chainId, recipient, token: tokenAddress }) => {
          tokenAddress = bytes32ToAddress(tokenAddress);
          recipient = bytes32ToAddress(recipient);
          const _chainId = chainId.toString();

          const filler = this.multiProvider.getSigner(_chainId);

          if (tokenAddress === AddressZero) {
            // native token
            return;
          }

          const token = Erc20__factory.connect(tokenAddress, filler);

          const fillerAddress = await filler.getAddress();
          const allowance = await token.allowance(fillerAddress, recipient);

          if (allowance.lt(amount)) {
            const tx = await Erc20__factory.connect(
              tokenAddress,
              filler,
            ).approve(recipient, MaxUint256);

            const receipt = await tx.wait();
            const baseUrl =
              this.multiProvider.getChainMetadata(_chainId).blockExplorers?.[0]
                .url;

            this.log.debug({
              msg: "Approval",
              protocolName: this.metadata.protocolName,
              amount: MaxUint256.toString(),
              tokenAddress,
              recipient,
              chainId: _chainId,
              tx: baseUrl
                ? `${baseUrl}/tx/${receipt.transactionHash}`
                : `${receipt.transactionHash}`,
            });
          } else {
            this.log.debug({
              msg: "Approval not required",
              protocolName: this.metadata.protocolName,
              amount: amount.toString(),
              allowance: allowance.toString(),
              tokenAddress,
              recipient,
              chainId: _chainId,
            });
          }
        },
      ),
    );

    await Promise.all(
      data.fillInstructions.map(
        async (
          { destinationChainId, destinationSettler, originData },
          index,
        ) => {
          destinationSettler = bytes32ToAddress(destinationSettler);
          const _chainId = destinationChainId.toString();

          const filler = this.multiProvider.getSigner(_chainId);
          const fillerAddress = await filler.getAddress();
          const destination = Hyperlane7683__factory.connect(
            destinationSettler,
            filler,
          );

          const value =
            bytes32ToAddress(data.maxSpent[index].token) === AddressZero
              ? data.maxSpent[index].amount
              : undefined;

          // Depending on the implementation we may call `destination.fill` directly or call some other
          // contract that will produce the funds needed to execute this leg and then in turn call
          // `destination.fill`
          const tx = await destination.fill(
            parsedArgs.orderId,
            originData,
            addressToBytes32(fillerAddress),
            { value },
          );

          const receipt = await tx.wait();
          const baseUrl =
            this.multiProvider.getChainMetadata(_chainId).blockExplorers?.[0]
              .url;

          const txInfo = baseUrl
            ? `${baseUrl}/tx/${receipt.transactionHash}`
            : receipt.transactionHash;

          log.info({
            msg: "Filled Intent",
            intent: `${this.metadata.protocolName}-${parsedArgs.orderId}`,
            txDetails: txInfo,
            txHash: receipt.transactionHash,
          });
        },
      ),
    );

    await saveBlockNumber(originChainName, blockNumber, parsedArgs.orderId);
  }

  settleOrder(parsedArgs: OpenEventArgs, data: IntentData) {
    return settleOrder(
      data.fillInstructions,
      parsedArgs.resolvedOrder.originChainId,
      parsedArgs.orderId,
      this.multiProvider,
      this.metadata.protocolName,
    );
  }
}

const enoughBalanceOnDestination: Hyperlane7683Rule = async (
  parsedArgs,
  context,
) => {
  const amountByTokenByChain = parsedArgs.resolvedOrder.maxSpent.reduce<{
    [chainId: number]: { [token: string]: BigNumber };
  }>((acc, { token, ...output }) => {
    token = bytes32ToAddress(token);
    const chainId = output.chainId.toNumber();

    acc[chainId] ||= { [token]: Zero };
    acc[chainId][token] ||= Zero;

    acc[chainId][token] = acc[chainId][token].add(output.amount);

    return acc;
  }, {});

  for (const chainId in amountByTokenByChain) {
    const chainTokens = amountByTokenByChain[chainId];
    const fillerAddress = await context.multiProvider.getSignerAddress(chainId);
    const provider = context.multiProvider.getProvider(chainId);

    for (const tokenAddress in chainTokens) {
      const amount = chainTokens[tokenAddress];
      const balance = await retrieveTokenBalance(
        tokenAddress,
        fillerAddress,
        provider,
      );

      if (balance.lt(amount)) {
        return {
          error: `Insufficient balance on destination chain ${chainId}, for ${tokenAddress}`,
          success: false,
        };
      }
    }
  }

  return { data: "Enough tokens to fulfill the intent", success: true };
};

export const create = (
  multiProvider: MultiProvider,
  customRules?: RulesMap<Hyperlane7683Rule>,
) => {
  return new Hyperlane7683Filler(multiProvider, {
    base: [enoughBalanceOnDestination],
    custom: customRules,
  }).create();
};
