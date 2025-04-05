const { createPublicClient, http } = require('viem');
const { sepolia } = require('viem/chains');
const express = require('express');
const app = express();
const port = 3000;

// Configure Sepolia client
const client = createPublicClient({
  chain: sepolia,
  transport: http('https://eth-sepolia.public.blastapi.io'),
});

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

app.listen(port, () => {
  console.log(`VIEM ENS resolver listening at http://localhost:${port}`);
});