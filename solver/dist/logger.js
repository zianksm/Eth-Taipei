import { LogFormat } from "@hyperlane-xyz/utils";
import chalk from "chalk";
import { pino } from "pino";
import pretty from "pino-pretty";
import uniqolor from "uniqolor";
import { LOG_FORMAT, LOG_LEVEL } from "./config/index.js";
const prettyConfig = {
    ignore: "hostname,pid,level",
    messageFormat: (log, msgKey) => {
        const message = `${log[msgKey]}`;
        if (log.name) {
            return chalk.hex(uniqolor(log.name).color)(message);
        }
        return message;
    },
};
function createLogger(name, logFormat, logLevel) {
    logFormat = logFormat || LOG_FORMAT || LogFormat.Pretty;
    logLevel = logLevel || LOG_LEVEL || "info";
    const baseConfig = { level: logLevel, name };
    if (logFormat === LogFormat.JSON) {
        return pino({
            ...baseConfig,
            // transport: {
            //   target: "pino-socket",
            //   options: {
            //     address: "127.0.0.1",
            //     port: 514,
            //     mode: "udp",
            //   },
            // },
        });
    }
    return pino(baseConfig, pretty(prettyConfig));
}
const log = createLogger();
export { createLogger, log, LogFormat };
//# sourceMappingURL=logger.js.map