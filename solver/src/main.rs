use IIntent::getOrderReservesCall;
use IOriginSettler::Open;
use alloy::dyn_abi::SolType;
use alloy::eips::BlockNumberOrTag;
use alloy::primitives::{Bytes, TxKind, address};
use alloy::providers::{Provider, ProviderBuilder, WsConnect};
use alloy::rpc::types::{Filter, TransactionInput, TransactionRequest};
use alloy::sol;
use alloy::sol_types::{SolCall, SolEvent};
use eyre::Result;
use futures_util::stream::StreamExt;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

sol! {// SPDX-License-Identifier: UNLICENSED

    /// @title GaslessCrossChainOrder CrossChainOrder type
    /// @notice Standard order struct to be signed by users, disseminated to fillers, and submitted to origin settler
    /// contracts by fillers
    struct GaslessCrossChainOrder {
        /// @dev The contract address that the order is meant to be settled by.
        /// Fillers send this order to this contract address on the origin chain
        address originSettler;
        /// @dev The address of the user who is initiating the swap,
        /// whose input tokens will be taken and escrowed
        address user;
        /// @dev Nonce to be used as replay protection for the order
        uint256 nonce;
        /// @dev The chainId of the origin chain
        uint256 originChainId;
        /// @dev The timestamp by which the order must be opened
        uint32 openDeadline;
        /// @dev The timestamp by which the order must be filled on the destination chain
        uint32 fillDeadline;
        /// @dev Type identifier for the order data. This is an EIP-712 typehash.
        bytes32 orderDataType;
        /// @dev Arbitrary implementation-specific data
        /// Can be used to define tokens, amounts, destination chains, fees, settlement parameters,
        /// or any other order-type specific information
        bytes orderData;
    }

    /// @title OnchainCrossChainOrder CrossChainOrder type
    /// @notice Standard order struct for user-opened orders, where the user is the one submitting the order creation
    /// transaction
    struct OnchainCrossChainOrder {
        /// @dev The timestamp by which the order must be filled on the destination chain
        uint32 fillDeadline;
        /// @dev Type identifier for the order data. This is an EIP-712 typehash.
        bytes32 orderDataType;
        /// @dev Arbitrary implementation-specific data
        /// Can be used to define tokens, amounts, destination chains, fees, settlement parameters,
        /// or any other order-type specific information
        bytes orderData;
    }

    /// @title ResolvedCrossChainOrder type
    /// @notice An implementation-generic representation of an order intended for filler consumption
    /// @dev Defines all requirements for filling an order by unbundling the implementation-specific orderData.
    /// @dev Intended to improve integration generalization by allowing fillers to compute the exact input and output
    /// information of any order
    struct ResolvedCrossChainOrder {
        /// @dev The address of the user who is initiating the transfer
        address user;
        /// @dev The chainId of the origin chain
        uint256 originChainId;
        /// @dev The timestamp by which the order must be opened
        uint32 openDeadline;
        /// @dev The timestamp by which the order must be filled on the destination chain(s)
        uint32 fillDeadline;
        /// @dev The unique identifier for this order within this settlement system
        bytes32 orderId;
        /// @dev The max outputs that the filler will send. It's possible the actual amount depends on the state of the
        /// destination
        ///      chain (destination dutch auction, for instance), so these outputs should be considered a cap on filler
        /// liabilities.
        Output[] maxSpent;
        /// @dev The minimum outputs that must be given to the filler as part of order settlement. Similar to maxSpent, it's
        /// possible
        ///      that special order types may not be able to guarantee the exact amount at open time, so this should be
        /// considered
        ///      a floor on filler receipts. Setting the `recipient` of an `Output` to address(0) indicates that the filler
        /// is not
        ///      known when creating this order.
        Output[] minReceived;
        /// @dev Each instruction in this array is parameterizes a single leg of the fill. This provides the filler with the
        /// information
        ///      necessary to perform the fill on the destination(s).
        FillInstruction[] fillInstructions;
    }

    /// @notice Tokens that must be received for a valid order fulfillment
    struct Output {
        /// @dev The address of the ERC20 token on the destination chain
        /// @dev address(0) used as a sentinel for the native token
        bytes32 token;
        /// @dev The amount of the token to be sent
        uint256 amount;
        /// @dev The address to receive the output tokens
        bytes32 recipient;
        /// @dev The destination chain for this output
        uint256 chainId;
    }

    /// @title FillInstruction type
    /// @notice Instructions to parameterize each leg of the fill
    /// @dev Provides all the origin-generated information required to produce a valid fill leg
    struct FillInstruction {
        /// @dev The chain that this instruction is intended to be filled on
        uint256 destinationChainId;
        /// @dev The contract address that the instruction is intended to be filled on
        bytes32 destinationSettler;
        /// @dev The data generated on the origin chain needed by the destinationSettler to process the fill
        bytes originData;
    }

    /// @title IOriginSettler
    /// @notice Standard interface for settlement contracts on the origin chain
    interface IOriginSettler {
        /// @notice Signals that an order has been opened
        /// @param orderId a unique order identifier within this settlement system
        /// @param resolvedOrder resolved order that would be returned by resolve if called instead of Open
        event Open(bytes32 indexed orderId, ResolvedCrossChainOrder resolvedOrder);

        /// @notice Opens a gasless cross-chain order on behalf of a user.
        /// @dev To be called by the filler.
        /// @dev This method must emit the Open event
        /// @param order The GaslessCrossChainOrder definition
        /// @param signature The user's signature over the order
        /// @param originFillerData Any filler-defined data required by the settler
        function openFor(
            GaslessCrossChainOrder calldata order,
            bytes calldata signature,
            bytes calldata originFillerData
        )
            external;

        /// @notice Opens a cross-chain order
        /// @dev To be called by the user
        /// @dev This method must emit the Open event
        /// @param order The OnchainCrossChainOrder definition
        function open(OnchainCrossChainOrder calldata order) external payable;

        /// @notice Resolves a specific GaslessCrossChainOrder into a generic ResolvedCrossChainOrder
        /// @dev Intended to improve standardized integration of various order types and settlement contracts
        /// @param order The GaslessCrossChainOrder definition
        /// @param originFillerData Any filler-defined data required by the settler
        /// @return ResolvedCrossChainOrder hydrated order data including the inputs and outputs of the order
        function resolveFor(
            GaslessCrossChainOrder calldata order,
            bytes calldata originFillerData
        )
            external
            view
            returns (ResolvedCrossChainOrder memory);

        /// @notice Resolves a specific OnchainCrossChainOrder into a generic ResolvedCrossChainOrder
        /// @dev Intended to improve standardized integration of various order types and settlement contracts
        /// @param order The OnchainCrossChainOrder definition
        /// @return ResolvedCrossChainOrder hydrated order data including the inputs and outputs of the order
        function resolve(OnchainCrossChainOrder calldata order) external view returns (ResolvedCrossChainOrder memory);
    }

    /// @title IDestinationSettler
    /// @notice Standard interface for settlement contracts on the destination chain
    interface IDestinationSettler {
        /// @notice Fills a single leg of a particular order on the destination chain
        /// @param orderId Unique order identifier for this order
        /// @param originData Data emitted on the origin to parameterize the fill
        /// @param fillerData Data provided by the filler to inform the fill or express their preferences
        function fill(bytes32 orderId, bytes calldata originData, bytes calldata fillerData) external payable;
    }

    interface IIntent {
        function getOrderReserves(bytes32 id) external view returns (IIntent.OrderReserves memory);

        type IntentId is bytes32;

        struct Call {
            address dest;
            bytes data;
        }

        struct Intents {
            address inToken;
            address outToken;
        }

        struct IntentSpecification {
            uint256 inAmount;
            uint256 outAmount;
        }

        enum BankType {
            WISE
        }

        struct OrderData {
            address token;
            uint256 amount;
            BankType bankType;
            uint256 bankNumber;
        }

        struct OrderMessage {
            bytes32 id;
            uint256 amount;
        }

        struct OrderReserves {
            address token;
            uint256 amount;
            BankType bankType;
            uint256 bankAccountDest;
            OrderReserve inner;
        }

        struct OrderReserve {
            address filler;
            uint256 amount;
            uint256 deposit;
        }
    }

}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct WiseTransferRequest {
    #[serde(rename = "sourceAccount")]
    source_account: i64, // account ID is typically a number

    #[serde(rename = "targetAccount")]
    target_account: i64,

    #[serde(rename = "quoteUuid")]
    quote_uuid: String,

    #[serde(rename = "customerTransactionId")]
    customer_transaction_id: String,

    details: TransferDetails,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct TransferDetails {
    reference: String,

    #[serde(rename = "transferPurpose")]
    transfer_purpose: String,

    #[serde(rename = "transferPurposeSubTransferPurpose")]
    transfer_purpose_sub_transfer_purpose: String,

    #[serde(rename = "sourceOfFunds")]
    source_of_funds: String,
}

impl WiseTransferRequest {
    pub fn new(
        source_account: i64,
        target_account: i64,
        quote_uuid: String,
        customer_transaction_id: String,
        details: TransferDetails,
    ) -> Self {
        Self {
            source_account,
            target_account,
            quote_uuid,
            customer_transaction_id,
            details,
        }
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let celo_testnet_wss: WsConnect = WsConnect::new("wss://alfajores-forno.celo-testnet.org/ws");
    let provider = ProviderBuilder::new().on_ws(celo_testnet_wss).await?;

    let request = reqwest::Client::new();
    let wise_request_builder: reqwest::RequestBuilder =
        request.post("https://api.sandbox.wise.com/v1/transfers");

    // Listen to events via filter logs
    let contract_to_filter = address!("0x0000000000000000000000000000000000000000");
    let filter = Filter::new()
        .address(contract_to_filter)
        .event(Open::SIGNATURE)
        .from_block(BlockNumberOrTag::Latest);

    // Get logs instead of subscribing since we're using HTTP provider
    let sub = provider.subscribe_logs(&filter).await?;
    let mut stream = sub.into_stream();

    while let Some(log) = stream.next().await {
        println!("log: {:?}", log);

        let decoded = log.log_decode::<Open>()?.inner.data;
        let order_id = decoded.orderId;

        let get_order_reserves_call = getOrderReservesCall { id: order_id };
        let tx = TransactionRequest {
            from: None,
            to: Some(TxKind::Call(contract_to_filter)),
            gas_price: None,
            max_fee_per_gas: None,
            max_priority_fee_per_gas: None,
            max_fee_per_blob_gas: None,
            gas: None,
            value: None,
            input: TransactionInput {
                input: Some(Bytes::from(get_order_reserves_call.abi_encode())),
                data: None,
            },
            nonce: None,
            chain_id: None,
            access_list: None,
            transaction_type: None,
            blob_versioned_hashes: None,
            sidecar: None,
            authorization_list: None,
        };

        let reserves = provider.call(tx).await?;
        let order_reserves = IIntent::OrderReserves::abi_decode(&reserves, true)?;

        println!("reserves: {:?}", reserves);

        let wise_transfer_request = WiseTransferRequest::new(
            0,
            order_reserves.bankAccountDest.to::<i64>(),
            Uuid::new_v4().to_string(),
            Uuid::new_v4().to_string(),
            TransferDetails {
                reference: "".to_string(),
                transfer_purpose: "".to_string(),
                transfer_purpose_sub_transfer_purpose: "".to_string(),
                source_of_funds: "".to_string(),
            },
        );

        let wise_request = wise_request_builder
            .try_clone()
            .unwrap()
            .json(&wise_transfer_request)
            .send()
            .await?;

        println!("wise_request: {:?}", wise_request);

        // // Call the Wise API here, after we have confirmed
        // serde_json::value::to_value(value)
    }

    Ok(())
}
