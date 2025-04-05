const escrowAbi = [
  {
    "type": "function",
    "name": "FILLED",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "OPENED",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "PERMIT2",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "contract IPermit2"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "RESOLVED_CROSS_CHAIN_ORDER_TYPEHASH",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "UNKNOWN",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "UNSAFE_HARDCODE_MINIMUM_RESERVE_DEPOSIT",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "fill",
    "inputs": [
      {
        "name": "_orderId",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "_originData",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "_fillerData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "filledOrders",
    "inputs": [
      {
        "name": "orderId",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [
      {
        "name": "originData",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "fillerData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "invalidateNonces",
    "inputs": [
      {
        "name": "_nonce",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "isValidNonce",
    "inputs": [
      {
        "name": "_from",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "_nonce",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "open",
    "inputs": [
      {
        "name": "_order",
        "type": "tuple",
        "internalType": "struct OnchainCrossChainOrder",
        "components": [
          {
            "name": "fillDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "orderDataType",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "orderData",
            "type": "bytes",
            "internalType": "bytes"
          }
        ]
      }
    ],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "openFor",
    "inputs": [
      {
        "name": "_order",
        "type": "tuple",
        "internalType": "struct GaslessCrossChainOrder",
        "components": [
          {
            "name": "originSettler",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "user",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "nonce",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "originChainId",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "openDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "fillDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "orderDataType",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "orderData",
            "type": "bytes",
            "internalType": "bytes"
          }
        ]
      },
      {
        "name": "_signature",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "_originFillerData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "openOrders",
    "inputs": [
      {
        "name": "orderId",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [
      {
        "name": "orderData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "orderReserves",
    "inputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [
      {
        "name": "amount",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "reserved",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "orderStatus",
    "inputs": [
      {
        "name": "orderId",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [
      {
        "name": "status",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "refund",
    "inputs": [
      {
        "name": "_orders",
        "type": "tuple[]",
        "internalType": "struct OnchainCrossChainOrder[]",
        "components": [
          {
            "name": "fillDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "orderDataType",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "orderData",
            "type": "bytes",
            "internalType": "bytes"
          }
        ]
      }
    ],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "refund",
    "inputs": [
      {
        "name": "_orders",
        "type": "tuple[]",
        "internalType": "struct GaslessCrossChainOrder[]",
        "components": [
          {
            "name": "originSettler",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "user",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "nonce",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "originChainId",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "openDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "fillDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "orderDataType",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "orderData",
            "type": "bytes",
            "internalType": "bytes"
          }
        ]
      }
    ],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "reserve",
    "inputs": [
      {
        "name": "order",
        "type": "tuple",
        "internalType": "struct OnchainCrossChainOrder",
        "components": [
          {
            "name": "fillDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "orderDataType",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "orderData",
            "type": "bytes",
            "internalType": "bytes"
          }
        ]
      },
      {
        "name": "who",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "resolve",
    "inputs": [
      {
        "name": "_order",
        "type": "tuple",
        "internalType": "struct OnchainCrossChainOrder",
        "components": [
          {
            "name": "fillDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "orderDataType",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "orderData",
            "type": "bytes",
            "internalType": "bytes"
          }
        ]
      }
    ],
    "outputs": [
      {
        "name": "_resolvedOrder",
        "type": "tuple",
        "internalType": "struct ResolvedCrossChainOrder",
        "components": [
          {
            "name": "user",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "originChainId",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "openDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "fillDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "orderId",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "maxSpent",
            "type": "tuple[]",
            "internalType": "struct Output[]",
            "components": [
              {
                "name": "token",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "amount",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "recipient",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "chainId",
                "type": "uint256",
                "internalType": "uint256"
              }
            ]
          },
          {
            "name": "minReceived",
            "type": "tuple[]",
            "internalType": "struct Output[]",
            "components": [
              {
                "name": "token",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "amount",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "recipient",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "chainId",
                "type": "uint256",
                "internalType": "uint256"
              }
            ]
          },
          {
            "name": "fillInstructions",
            "type": "tuple[]",
            "internalType": "struct FillInstruction[]",
            "components": [
              {
                "name": "destinationChainId",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "destinationSettler",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "originData",
                "type": "bytes",
                "internalType": "bytes"
              }
            ]
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "resolveFor",
    "inputs": [
      {
        "name": "_order",
        "type": "tuple",
        "internalType": "struct GaslessCrossChainOrder",
        "components": [
          {
            "name": "originSettler",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "user",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "nonce",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "originChainId",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "openDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "fillDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "orderDataType",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "orderData",
            "type": "bytes",
            "internalType": "bytes"
          }
        ]
      },
      {
        "name": "_originFillerData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [
      {
        "name": "_resolvedOrder",
        "type": "tuple",
        "internalType": "struct ResolvedCrossChainOrder",
        "components": [
          {
            "name": "user",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "originChainId",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "openDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "fillDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "orderId",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "maxSpent",
            "type": "tuple[]",
            "internalType": "struct Output[]",
            "components": [
              {
                "name": "token",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "amount",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "recipient",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "chainId",
                "type": "uint256",
                "internalType": "uint256"
              }
            ]
          },
          {
            "name": "minReceived",
            "type": "tuple[]",
            "internalType": "struct Output[]",
            "components": [
              {
                "name": "token",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "amount",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "recipient",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "chainId",
                "type": "uint256",
                "internalType": "uint256"
              }
            ]
          },
          {
            "name": "fillInstructions",
            "type": "tuple[]",
            "internalType": "struct FillInstruction[]",
            "components": [
              {
                "name": "destinationChainId",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "destinationSettler",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "originData",
                "type": "bytes",
                "internalType": "bytes"
              }
            ]
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "settle",
    "inputs": [
      {
        "name": "_orderIds",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      }
    ],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "usedNonces",
    "inputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "witnessHash",
    "inputs": [
      {
        "name": "_resolvedOrder",
        "type": "tuple",
        "internalType": "struct ResolvedCrossChainOrder",
        "components": [
          {
            "name": "user",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "originChainId",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "openDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "fillDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "orderId",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "maxSpent",
            "type": "tuple[]",
            "internalType": "struct Output[]",
            "components": [
              {
                "name": "token",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "amount",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "recipient",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "chainId",
                "type": "uint256",
                "internalType": "uint256"
              }
            ]
          },
          {
            "name": "minReceived",
            "type": "tuple[]",
            "internalType": "struct Output[]",
            "components": [
              {
                "name": "token",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "amount",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "recipient",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "chainId",
                "type": "uint256",
                "internalType": "uint256"
              }
            ]
          },
          {
            "name": "fillInstructions",
            "type": "tuple[]",
            "internalType": "struct FillInstruction[]",
            "components": [
              {
                "name": "destinationChainId",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "destinationSettler",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "originData",
                "type": "bytes",
                "internalType": "bytes"
              }
            ]
          }
        ]
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "pure"
  },
  {
    "type": "function",
    "name": "witnessTypeString",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "string",
        "internalType": "string"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "event",
    "name": "Filled",
    "inputs": [
      {
        "name": "orderId",
        "type": "bytes32",
        "indexed": false,
        "internalType": "bytes32"
      },
      {
        "name": "originData",
        "type": "bytes",
        "indexed": false,
        "internalType": "bytes"
      },
      {
        "name": "fillerData",
        "type": "bytes",
        "indexed": false,
        "internalType": "bytes"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "NonceInvalidation",
    "inputs": [
      {
        "name": "owner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "nonce",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Open",
    "inputs": [
      {
        "name": "orderId",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "resolvedOrder",
        "type": "tuple",
        "indexed": false,
        "internalType": "struct ResolvedCrossChainOrder",
        "components": [
          {
            "name": "user",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "originChainId",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "openDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "fillDeadline",
            "type": "uint32",
            "internalType": "uint32"
          },
          {
            "name": "orderId",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "maxSpent",
            "type": "tuple[]",
            "internalType": "struct Output[]",
            "components": [
              {
                "name": "token",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "amount",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "recipient",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "chainId",
                "type": "uint256",
                "internalType": "uint256"
              }
            ]
          },
          {
            "name": "minReceived",
            "type": "tuple[]",
            "internalType": "struct Output[]",
            "components": [
              {
                "name": "token",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "amount",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "recipient",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "chainId",
                "type": "uint256",
                "internalType": "uint256"
              }
            ]
          },
          {
            "name": "fillInstructions",
            "type": "tuple[]",
            "internalType": "struct FillInstruction[]",
            "components": [
              {
                "name": "destinationChainId",
                "type": "uint256",
                "internalType": "uint256"
              },
              {
                "name": "destinationSettler",
                "type": "bytes32",
                "internalType": "bytes32"
              },
              {
                "name": "originData",
                "type": "bytes",
                "internalType": "bytes"
              }
            ]
          }
        ]
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Refund",
    "inputs": [
      {
        "name": "orderIds",
        "type": "bytes32[]",
        "indexed": false,
        "internalType": "bytes32[]"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Settle",
    "inputs": [
      {
        "name": "orderIds",
        "type": "bytes32[]",
        "indexed": false,
        "internalType": "bytes32[]"
      },
      {
        "name": "ordersFillerData",
        "type": "bytes[]",
        "indexed": false,
        "internalType": "bytes[]"
      }
    ],
    "anonymous": false
  },
  {
    "type": "error",
    "name": "InvalidGaslessOrderOrigin",
    "inputs": []
  },
  {
    "type": "error",
    "name": "InvalidGaslessOrderSettler",
    "inputs": []
  },
  {
    "type": "error",
    "name": "InvalidNativeAmount",
    "inputs": []
  },
  {
    "type": "error",
    "name": "InvalidNonce",
    "inputs": []
  },
  {
    "type": "error",
    "name": "InvalidOrderOrigin",
    "inputs": []
  },
  {
    "type": "error",
    "name": "InvalidOrderStatus",
    "inputs": []
  },
  {
    "type": "error",
    "name": "OrderFillNotExpired",
    "inputs": []
  },
  {
    "type": "error",
    "name": "OrderOpenExpired",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SafeERC20FailedOperation",
    "inputs": [
      {
        "name": "token",
        "type": "address",
        "internalType": "address"
      }
    ]
  }
]

module.exports = { escrowAbi };