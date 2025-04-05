const { createPublicClient, http } = require('viem');
const { sepolia } = require('viem/chains');
const { ethers } = require('ethers');
const express = require('express');
const escrowAbi = require('./abi.js');
const erc20Abi = require('./erc20Abi.js');
const app = express();
const port = 3002;

// Configure Sepolia client
const client = createPublicClient({
  chain: sepolia,
  transport: http('https://eth-sepolia.public.blastapi.io'),
});

const celoProvider = new ethers.providers.JsonRpcProvider("https://celo.drpc.org");

app.use(express.json());

// Endpoint for ENS lookup
app.get('/ens/:address', async (req, res) => {
  const { address } = req.params;
  try {
    const name = await client.getEnsName({ address });
    res.json({ ensName: name || '' });
  } catch (error) {
    console.error('Error resolving ENS:', error);
    res.status(500).json({ ensName: '', error: error.message });
  }
});

app.post('/give-allowance', async (req, res) => {
  const { key, token, amount } = req.body;
  const signer = new ethers.Wallet(key, celoProvider);
  const tokenContract = new ethers.Contract(token, erc20Abi, signer);
  const tx = await tokenContract.approve(signer.address, amount);
  console.log({tx});
  const receipt = await tx.wait();
  if (receipt.status === 1) {
    res.json({ success: true });
  } else {
    res.json({ success: false });
  }
});

app.post('/open-order', async (req, res) => {
  // Helper function to pack OrderData
  function packOrderData(orderData) {
    // Create the OrderData struct encoding
    const abiCoder = new ethers.utils.AbiCoder();
    const packedOrderData = abiCoder.encode(
        [
            "tuple(address token, uint256 amount, uint8 bankType, uint256 bankNumber)"
        ],
        [{
            token: orderData.token,
            amount: orderData.amount,
            bankType: orderData.bankType,  // BankType.WISE would be 0
            bankNumber: orderData.bankNumber
        }]
    );
    return packedOrderData;
  }

  const { key, fillDeadline, orderDataType, orderData } = req.body;

  const signer = new ethers.Wallet(key, celoProvider);
  const escrowContract = new ethers.Contract("0xC9741C144fa9A44641222c706ea321b8B6a704E8", escrowAbi, signer);
  const tx = await escrowContract.open({
    fillDeadline,
    orderDataType,
    orderData: packOrderData(orderData)
  });

  const receipt = await tx.wait();

  if (receipt.status === 1) {
    res.json({ success: true });
  } else {
    res.json({ success: false });
  }
});

app.listen(port, () => {
  console.log(`VIEM ENS resolver listening at http://localhost:${port}`);
});