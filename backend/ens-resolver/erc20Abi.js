const erc20Abi = [
  {
    "type": "function",
    "name": "approve",
    "inputs": [{"name": "spender", "type": "address"}, {"name": "value", "type": "uint256"}],
    "outputs": [{"name": "success", "type": "bool"}],
    "stateMutability": "nonpayable"
  }
]

module.exports = erc20Abi;

