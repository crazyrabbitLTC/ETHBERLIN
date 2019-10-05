const {
  BN,
  constants,
  expectEvent,
  shouldFail,
  expectRevert
} = require("openzeppelin-test-helpers");

const MerkleProof = artifacts.require("MerkleProof");

const {MerkleTree} = require("merkletreejs");
const web3Utils = require("web3-utils");
//const keccak256 = web3Utils.keccak256;
const keccak256 = require("keccak256");

const buf2hex = x => "0x" + x.toString("hex");
// const leaves = ["a", "b", "c"].map(x => keccak256(x));
// const tree = new MerkleTree(leaves, keccak256);
// const root = tree.getRoot();
// const hexroot = buf2hex(root);
// const leaf = Buffer(keccak256("d"), "hex");
// const hexleaf = buf2hex(leaf);
// const proof = tree.getProof(leaf);
// const hexproof = tree.getProof(leaf).map(x => buf2hex(x.data));
// const positions = tree
//   .getProof(leaf)
//   .map(x => (x.position === "right" ? 1 : 0));

const leaves = ["a", "b", "c"].map(x => keccak256(x), "hex");
const tree = new MerkleTree(leaves, keccak256);
const root = Buffer(tree.getRoot(), "hex");
const leaf = Buffer(keccak256("c"), "hex");
const proof = tree.getProof(leaf);
const hexproof = tree.getProof(leaf).map(x => buf2hex(x.data));
const positions = tree
  .getProof(leaf)
  .map(x => (x.position === "right" ? 1 : 0));

contract("MerkleProof ", async ([sender, secondAddress, ...otherAccounts]) => {
  beforeEach(async () => {
    merkleProof = await MerkleProof.new();
  });

  it("it can verify a merkle proof", async () => {
    const result = await merkleProof.verify(root, leaf, hexproof, positions);
    console.log("Result: ", result);
    assert.equal(result, true);
  });
});
