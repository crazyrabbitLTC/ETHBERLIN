const web3Utils = require("web3-utils");
const keccak256 = web3Utils.keccak256;
const buf2hex = x => "0x" + x.toString("hex");

const leaves = [
  "0x00000a86986e8ba3557992df02883e4a646e8f25 50000000000000000000",
  "0x00009c99bffc538de01866f74cfec4819dc467f3 75000000000000000000",
  "0x00035a5f2c595c3bb53aae4528038dd7a85641c3 50000000000000000000",
  "0x1e27c325ba246f581a6dcaa912a8e80163454c75 10000000000000000000"
].map(x => keccak256(x));
const tree = new MerkleTree(leaves, keccak256);
const root = tree.getRoot();
const hexroot = buf2hex(root);
const leaf = keccak256(
  "0x1e27c325ba246f581a6dcaa912a8e80163454c75 10000000000000000000"
);
const hexleaf = buf2hex(leaf);
const proof = tree.getProof(leaf);
const hexproof = tree.getProof(leaf).map(x => buf2hex(x.data));
const positions = tree
  .getProof(leaf)
  .map(x => (x.position === "right" ? 1 : 0));

console.log(hexroot);
console.log(hexleaf);
console.log(hexproof);
console.log(positions);

const verified = await contract.verify.call(
  hexroot,
  hexleaf,
  hexproof,
  positions
);
assert.equal(verified, true);

assert.equal(tree.verify(proof, leaf, root), true);
