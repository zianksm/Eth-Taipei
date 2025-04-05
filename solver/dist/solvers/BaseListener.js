import { MultiProvider } from "@hyperlane-xyz/sdk";
import { chainMetadata } from "../config/chainMetadata.js";
export class BaseListener {
    contractFactory;
    eventName;
    metadata;
    log;
    constructor(contractFactory, eventName, metadata, log) {
        this.contractFactory = contractFactory;
        this.eventName = eventName;
        this.metadata = metadata;
        this.log = log;
    }
    lastProcessedBlocks = {};
    defaultPollInterval = 3000; // 3 seconds
    defaultMaxBlockRange = 3000;
    pollIntervals = [];
    create() {
        return (handler) => {
            for (const value of Object.values(chainMetadata)) {
                value.rpcUrls = value.rpcUrls.map((rpc) => {
                    rpc.pagination = rpc.pagination ?? {};
                    rpc.pagination.maxBlockRange =
                        rpc.pagination.maxBlockRange ?? this.defaultMaxBlockRange;
                    return rpc;
                });
            }
            const multiProvider = new MultiProvider(chainMetadata);
            this.metadata.contracts.forEach(async ({ address, chainName, pollInterval, confirmationBlocks, initialBlock, processedIds, }) => {
                const provider = multiProvider.getProvider(chainName);
                const contract = this.contractFactory.connect(address, provider);
                const filter = contract.filters[this.eventName]();
                const latest = await provider.getBlockNumber();
                this.lastProcessedBlocks[chainName] = latest;
                if (initialBlock && initialBlock < latest - 1) {
                    this.processPrevBlocks(chainName, contract, filter, initialBlock, latest - 1, handler, processedIds);
                }
                this.pollIntervals.push(setInterval(() => this.pollEvents(chainName, contract, filter, handler, confirmationBlocks), pollInterval ?? this.defaultPollInterval));
                contract.provider.getNetwork().then((network) => {
                    this.log.info({
                        msg: "Listener started",
                        event: this.eventName,
                        protocol: this.metadata.protocolName,
                        chainId: network.chainId,
                        chainName: chainName,
                    });
                });
            });
            // shutdown
            return () => {
                for (let i = 0; i < this.pollIntervals.length; i++) {
                    clearInterval(this.pollIntervals[i]);
                }
                this.pollIntervals = [];
            };
        };
    }
    async pollEvents(chainName, contract, filter, handler, confirmationBlocks) {
        const latestBlock = await contract.provider.getBlockNumber();
        const fromBlock = this.lastProcessedBlocks[chainName] + 1;
        const toBlock = latestBlock - (confirmationBlocks ?? 0);
        if (toBlock <= fromBlock) {
            this.log.debug({
                msg: "No new confirmed blocks yet",
                protocolName: this.metadata.protocolName,
                chainName,
            });
            return;
        }
        const events = await contract.queryFilter(filter, fromBlock, toBlock);
        this.log.debug({
            msg: "Polling",
            protocolName: this.metadata.protocolName,
            chainName,
            fromBlock,
            toBlock,
            eventsFound: events.length,
        });
        for (let i = 0; i < events.length; i++) {
            handler(this.parseEventArgs(events[i].args), chainName, events[i].blockNumber);
        }
        this.lastProcessedBlocks[chainName] = toBlock;
    }
    async processPrevBlocks(chainName, contract, filter, from, to, handler, processedIds) {
        const pastEvents = await contract.queryFilter(filter, from, to);
        for (let event of pastEvents) {
            const parsedArgs = this.parseEventArgs(event.args);
            if (event.blockNumber === from &&
                processedIds?.includes(parsedArgs.orderId)) {
                continue;
            }
            await handler(parsedArgs, chainName, event.blockNumber);
        }
    }
}
//# sourceMappingURL=BaseListener.js.map