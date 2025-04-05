import { LogFormat } from "@hyperlane-xyz/utils";
import { type Level, type Logger } from "pino";
declare function createLogger(name?: string, logFormat?: LogFormat, logLevel?: Level): Logger<never, boolean>;
declare const log: Logger<never, boolean>;
export { createLogger, log, LogFormat, type Level, type Logger };
//# sourceMappingURL=logger.d.ts.map