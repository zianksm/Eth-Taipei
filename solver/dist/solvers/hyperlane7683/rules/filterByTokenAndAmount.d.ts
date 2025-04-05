import z from "zod";
import { Hyperlane7683Rule } from "../filler.js";
declare const FilterByTokenAndAmountArgs: z.ZodRecord<z.ZodString, z.ZodRecord<z.ZodString, z.ZodUnion<[z.ZodNull, z.ZodEffects<z.ZodBigInt, bigint, bigint>]>>>;
export declare function filterByTokenAndAmount(args: z.infer<typeof FilterByTokenAndAmountArgs>): Hyperlane7683Rule;
export {};
//# sourceMappingURL=filterByTokenAndAmount.d.ts.map