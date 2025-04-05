import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { z } from "zod";
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
export const SolverConfigSchema = z.object({
    enabled: z.boolean(),
});
// Read and parse the JSON file
const solversConfigPath = path.join(__dirname, "solvers.json");
export const solversConfig = JSON.parse(fs.readFileSync(solversConfigPath, "utf-8"));
// Validate config
Object.entries(solversConfig).forEach(([name, config]) => {
    SolverConfigSchema.parse(config);
});
//# sourceMappingURL=solvers.js.map