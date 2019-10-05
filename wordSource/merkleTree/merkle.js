const {MerkleTree} = require("merkletreejs");
const web3Utils = require("web3-utils");
const keccak256 = web3Utils.keccak256;

const leaves = ["a", "b", "c"].map(x => keccak256(x));
const tree = new MerkleTree(leaves, keccak256);
const root = tree.getRoot().toString("hex");
const leaf = keccak256("a");
console.log(leaf);
const proof = tree.getProof(leaf);
console.log(tree.verify(proof, leaf, root)); // true

const badLeaves = ["a", "x", "c"].map(x => keccak256(x));
const badTree = new MerkleTree(badLeaves, keccak256);
const badLeaf = keccak256("x");
const badProof = tree.getProof(badLeaf);
console.log(tree.verify(badProof, leaf, root)); // false

//sizeOf(tree);
// console.log("Proof: ", proof);
// console.log("leaf: ", leaf);
// console.log("root: ", root);
//console.log(`Size of tree: ${sizeOf(tree)}`);
