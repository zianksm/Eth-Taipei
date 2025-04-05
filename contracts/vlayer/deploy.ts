import proverSpec from "../out/WebProofProver.sol/WebProofProver";
import verifierSpec from "../out/WebProofVerifier.sol/WebProofVerifier";
import {
    deployVlayerContracts,
    writeEnvVariables,
    getConfig,
} from "@vlayer/sdk/config";

const config = getConfig();

const { prover, verifier } = await deployVlayerContracts({
    proverSpec,
    verifierSpec,
    verifierArgs: ["0x6966b0E55883d49BFB24539356a2f8A673E02039", 11155420]
});

writeEnvVariables(".env", {
    VITE_PROVER_ADDRESS: prover,
    VITE_VERIFIER_ADDRESS: verifier,
    VITE_CHAIN_NAME: config.chainName,
    VITE_PROVER_URL: config.proverUrl,
    VITE_JSON_RPC_URL: config.jsonRpcUrl,
    VITE_CLIENT_AUTH_MODE: config.clientAuthMode,
    VITE_PRIVATE_KEY: config.privateKey,
    VITE_VLAYER_API_TOKEN: config.token,
    VITE_NOTARY_URL: config.notaryUrl,
    VITE_WS_PROXY_URL: config.wsProxyUrl,
});