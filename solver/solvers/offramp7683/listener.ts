
import { BaseListener } from '../BaseListener.js';
import { metadata } from './config/index.js';
import type { ParsedArgs } from './types.js';
import { log } from '../../logger.js';
import { IntentHub__factory } from "../typechain/factories/offramp7683/contracts/IntentHub__factory.js";
import { TypedListener } from '../typechain/common.js';
import { OpenEvent } from '../typechain/offramp7683/contracts/IntentHub.js';
import * as ethers from "ethers";


export class Offramp7683Listener extends BaseListener<any, any, ParsedArgs> {
  constructor() {
    super(
      // TODO: Replace null with the appropriate contract factory (e.g., IntentHub__factory)
      // You'll need to:
      // 1. Add your contract ABI to: solvers/offramp7683/contracts/
      // 2. Run 'yarn contracts:typegen' to generate the factory
      // 3. Import and use the generated factory here
      IntentHub__factory,
      'Open',
      { contracts: [], protocolName: metadata.protocolName },
      log
    );
  }

  protected override parseEventArgs(args: Parameters<TypedListener<OpenEvent>>): ParsedArgs {
    const [orderId, resolvedOrder] = args;

    const [user, _originChainId, openDeadline, fillDeadline, , maxSpent, minReceived, fillInstructions] = resolvedOrder;

    const [instruction] = fillInstructions[0];

    const [tokenAddress, amount, swiftCode, accountNumber, recipient, minimumAmount] = ethers.utils.defaultAbiCoder.decode(["address", "uint256", "bytes8", "uint256", "string", "uint256"], instruction._hex)


    return {
      orderId,
      senderAddress: resolvedOrder.user,
      recipients: [],
      accountNumber,
      amount,
      minimumAmount,
      recipient,
      swiftCode,
      tokenAddress,
      originChainId: _originChainId.toString()
    };
  }
}

export const create = () => {
  new Offramp7683Listener().create()

};
