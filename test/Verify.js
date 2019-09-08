const {
  BN,
  constants,
  expectEvent,
  shouldFail,
  expectRevert
} = require("openzeppelin-test-helpers");
const {signWord} = require("./utils/utils.js");
const should = require("chai").should();

const Verify = artifacts.require("Verify");

contract("Verify ", async ([sender, secondAddress, ...otherAccounts]) => {
  let verify;

  beforeEach(async () => {
    verify = await Verify.new();
  });

  it("it does not accept signatures of improper type", async () => {
    await shouldFail(
      verify.splitSignature([72, 0, 101, 0, 108, 0, 108, 0, 111, 0]),
      "There is an error with the signature length: Verify contract line 29"
    );
  });
});
