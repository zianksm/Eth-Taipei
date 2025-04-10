import { AllowBlockListsSchema } from "./types.js";
// Example config
// [
//   {
//       senderAddress: "*",
//       destinationDomain: ["1"],
//       recipientAddress: "*"
//   },
//   {
//       senderAddress: ["0xca7f632e91B592178D83A70B404f398c0a51581F"],
//       destinationDomain: ["42220", "43114"],
//       recipientAddress: "*"
//   },
//   {
//       senderAddress: "*",
//       destinationDomain: ["42161", "420"],
//       recipientAddress: ["0xca7f632e91B592178D83A70B404f398c0a51581F"]
//   }
// ]
const allowBlockLists = {
    allowList: [],
    blockList: [],
};
AllowBlockListsSchema.parse(allowBlockLists);
export default allowBlockLists;
//# sourceMappingURL=allowBlockLists.js.map