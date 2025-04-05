
import z from 'zod';
import { BaseMetadataSchema, BaseIntentData } from '../types.js';
import type { ParsedArgs as BaseParsedArgs } from '../BaseFiller.js';

export const Offramp7683MetadataSchema = BaseMetadataSchema.extend({
  // Add any additional metadata fields here if needed
});

export type Offramp7683Metadata = z.infer<typeof Offramp7683MetadataSchema>;

export interface IntentData extends BaseIntentData {
  // Add your intent data fields here
}

export interface ParsedArgs extends BaseParsedArgs {
  orderId: string;
  senderAddress: string;
  recipients: Array<{
    destinationChainName: string;
    recipientAddress: string;
  }>;
  tokenAddress: string;
  amount: string;
  swiftCode: string;
  accountNumber: string;
  recipient: string;
  minimumAmount: string;
  originChainId: string;
  // Add any additional parsed args fields here
}
