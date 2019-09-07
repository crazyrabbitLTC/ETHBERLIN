const {
  BN,
  constants,
  expectEvent,
  shouldFail
} = require("openzeppelin-test-helpers");
const should = require("chai").should();

const WordDao = artifacts.require("WordDao");
const WordStorage = artifacts.require("WordStorage");
const WordToken = artifacts.require("WordToken");

contract("Word Token", async ([_, owner, ...otherAccounts]) => {
  let wordToken;

  beforeEach(async function() {
    wordToken = await WordToken.new(10);
  });

  it("Should have the  WordToken Name", async () => {
    (await wordToken.name()).should.equal("WordToken");
  });
});

// contract("counter", async ([_, owner, ...otherAccounts]) => {
//   let counter;
//   const value = new BN(9999);
//   const add = new BN(1);

//   beforeEach(async function () {
//     counter = await Counter.new();
//     counter.initialize(value, { from: owner });
//   });

//   it("should have proper owner", async () => {
//     (await counter.owner()).should.equal(owner);
//   });

//   it("should have proper default value", async () => {
//     (await counter.getCounter()).should.bignumber.equal(value);
//   });

//   it("should increase counter value", async () => {
//     await counter.increaseCounter(add);
//     (await counter.getCounter()).should.bignumber.equal(value.add(add));
//   });

//});
