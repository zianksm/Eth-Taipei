import z from "zod";
import { chainNames } from "../../config/index.js";
import { addressSchema } from "../../config/types.js";
import { BaseMetadataSchema } from "../types.js";
export const EcoMetadataSchema = BaseMetadataSchema.extend({
    adapters: z.record(z.string().refine((name) => chainNames.includes(name), {
        message: "Invalid chainName",
    }), addressSchema),
});
//# sourceMappingURL=types.js.map