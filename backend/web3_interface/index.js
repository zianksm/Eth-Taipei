require("dotenv").config();

const { ethers, BigNumber } = require("ethers");
const { escrowAbi } = require("./abi");

const getProvider = () => {
  return new ethers.providers.JsonRpcProvider("https://celo.drpc.org");
}

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

const main = async () => {
  const contractAddress = "0xC9741C144fa9A44641222c706ea321b8B6a704E8";

  const provider = getProvider();
  const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const escrowContract = new ethers.Contract(contractAddress, escrowAbi, signer);

  console.log(signer.address);

   // Example values
   const fillDeadline = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now
   const orderDataType = ethers.utils.formatBytes32String("I_AM_AN_IDIOT"); // example type

   // Example OrderData
   const orderData = {
       token: "0x1234567890123456789012345678901234567890",
       amount: ethers.utils.parseEther("1.0"),
       bankType: 0, // BankType.WISE
       bankNumber: BigNumber.from("123456789")
   };

  // Pack all parameters together
  const packedData = ethers.utils.defaultAbiCoder.encode(
      [
          "uint32",
          "bytes32",
          "bytes"
      ],
      [
          fillDeadline,
          orderDataType,
          packOrderData(orderData)
      ]
  );

  console.log("fillDeadline");
  console.log(fillDeadline);
  console.log("orderDataType");
  console.log(orderDataType);
  console.log("packedData");
  console.log(packedData);

  const tx = await escrowContract.open({
    fillDeadline,
    orderDataType,
    orderData: packedData
  });
  
  const receipt = await tx.wait();
  console.log(receipt);
}

main();