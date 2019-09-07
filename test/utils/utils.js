const EthCrypto = require("eth-crypto");
const web3Utils = require("web3-utils");

const signWord = async (word, privateKey) => {
  try {
    const message = EthCrypto.hash.keccak256([
      { type: "string", value: word }
    ]);
    const signature = await EthCrypto.sign(privateKey, message);
    return signature;
  } catch (error) {
    console.log(error);
  }
};

module.exports = { signWord };
