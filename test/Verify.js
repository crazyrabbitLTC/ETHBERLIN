const {
  BN,
  constants,
  expectEvent,
  shouldFail,
  expectRevert
} = require("openzeppelin-test-helpers");
const {
  signWord,
  leaves,
  badLeaves,
  tree,
  badTree,
  root,
  leaf,
  badLeaf,
  proof,
  badProof,
  positions,
  badPositions,
  validWord,
  invalidWord
} = require("./utils/utils.js");
const should = require("chai").should();

const Verify = artifacts.require("Verify");

contract("Verify ", async ([sender, secondAddress, ...otherAccounts]) => {
  let verify;

  beforeEach(async () => {
    verify = await Verify.new();
  });

  it("it can verify a word with a Merkle proof", async () => {
    const result = await verify.isValidData(
      validWord,
      root,
      leaf,
      proof,
      positions
    );
    assert.equal(result, true);
  });

  it("it rejects and invalid word", async () => {
    const result = await verify.isValidData(
      invalidWord,
      root,
      leaf,
      proof,
      positions
    );
    assert.equal(result, false);
  });
});
