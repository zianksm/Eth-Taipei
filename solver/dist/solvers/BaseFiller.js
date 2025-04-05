import { isAllowedIntent, } from "../config/index.js";
export class BaseFiller {
    multiProvider;
    allowBlockLists;
    metadata;
    log;
    rules = [];
    constructor(multiProvider, allowBlockLists, metadata, log, rulesConfig) {
        this.multiProvider = multiProvider;
        this.allowBlockLists = allowBlockLists;
        this.metadata = metadata;
        this.log = log;
        if (rulesConfig)
            this.rules = this.buildRules(rulesConfig);
    }
    create() {
        return async (parsedArgs, originChainName, blockNumber) => {
            try {
                const origin = await this.retrieveOriginInfo(parsedArgs, originChainName);
                const target = await this.retrieveTargetInfo(parsedArgs);
                this.log.info({
                    msg: "Intent Indexed",
                    intent: `${this.metadata.protocolName}-${parsedArgs.orderId}`,
                    origin: origin.join(", "),
                    target: target.join(", "),
                });
            }
            catch (error) {
                this.log.error({
                    msg: "Failed retrieving origin and target info",
                    intent: `${this.metadata.protocolName}-${parsedArgs.orderId}`,
                    error: JSON.stringify(error),
                });
            }
            const intent = await this.prepareIntent(parsedArgs);
            if (!intent.success) {
                this.log.error(`Failed evaluating filling Intent: ${intent.error}`);
                return;
            }
            const { data } = intent;
            try {
                await this.fill(parsedArgs, data, originChainName, blockNumber);
                await this.settleOrder(parsedArgs, data, originChainName);
            }
            catch (error) {
                this.log.error({
                    msg: `Failed processing intent`,
                    intent: `${this.metadata.protocolName}-${parsedArgs.orderId}`,
                    error: JSON.stringify(error),
                });
            }
        };
    }
    async prepareIntent(parsedArgs) {
        this.log.info({
            msg: "Evaluating filling Intent",
            intent: `${this.metadata.protocolName}-${parsedArgs.orderId}`,
        });
        const { senderAddress, recipients } = parsedArgs;
        if (!this.isAllowedIntent({ senderAddress, recipients })) {
            throw new Error("Not allowed intent");
        }
        const result = await this.evaluateRules(parsedArgs);
        if (!result.success) {
            throw new Error(result.error);
        }
        return { error: "Not implemented", success: false };
    }
    async evaluateRules(parsedArgs) {
        let result = { success: true, data: "No rules" };
        for (const rule of this.rules) {
            result = await rule(parsedArgs, this);
            if (!result.success) {
                break;
            }
        }
        return result;
    }
    async settleOrder(parsedArgs, data, originChainName) {
        return;
    }
    isAllowedIntent({ senderAddress, recipients, }) {
        return recipients.every(({ destinationChainName, recipientAddress }) => isAllowedIntent(this.allowBlockLists, {
            senderAddress,
            destinationDomain: destinationChainName,
            recipientAddress,
        }));
    }
    buildRules({ base = [], custom, }) {
        const customRules = [];
        if (this.metadata.customRules?.rules.length) {
            if (!custom) {
                throw new Error("Custom rules are specified in metadata, but no corresponding rule functions were provided.");
            }
            for (let i = 0; i < this.metadata.customRules.rules.length; i++) {
                const rule = this.metadata.customRules.rules[i];
                const ruleFn = custom[rule.name];
                if (!ruleFn) {
                    throw new Error(`Custom rule "${rule.name}" is specified in metadata but is not provided in the custom rules configuration.`);
                }
                customRules.push(ruleFn(rule.args));
            }
        }
        const keepBaseRules = this.metadata.customRules?.keepBaseRules ?? true;
        return keepBaseRules ? [...base, ...customRules] : customRules;
    }
}
//# sourceMappingURL=BaseFiller.js.map