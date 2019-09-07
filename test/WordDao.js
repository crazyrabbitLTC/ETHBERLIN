const {
  BN,
  constants,
  expectEvent,
  shouldFail,
  expectRevert
} = require("openzeppelin-test-helpers");
const {signWord} = require("./utils/utils.js");
const should = require("chai").should();

const WordDao = artifacts.require("WordDao");

contract("Setup WordDao", async ([sender, secondAddress, ...otherAccounts]) => {
  let wordDao;
  const language = "english";
  const fee = new BN(10);
  const tribute = new BN(11);
  const wordCount = new BN(450000);

  const keyPair = web3.eth.accounts.create();

  beforeEach(async () => {
    wordDao = await WordDao.new();
  });

  it("can setup a new WordDao", async () => {
    const {logs} = await wordDao.setupDao(
      language,
      fee,
      tribute,
      wordCount,
      keyPair.address
    );
    expectEvent.inLogs(logs, "daoSetup", {language, fee, tribute, wordCount});
  });

  it("can add a signed word", async () => {
    await wordDao.setupDao(language, fee, tribute, wordCount, keyPair.address);
    const word = "love";
    const signature = await signWord(word, keyPair.privateKey);
    const {logs} = await wordDao.addWord(language, word, signature, {
      from: secondAddress,
      value: tribute
    });
    expectEvent.inLogs(logs, "wordAdded", {
      word,
      tribute,
      adder: secondAddress
    });
  });
});

contract("Using WordDao", async ([sender, secondAddress, ...otherAccounts]) => {
  let wordDao;
  const language = "english";
  const fee = new BN(10);
  const tribute = new BN(11);
  const wordCount = new BN(450000);

  const keyPair = web3.eth.accounts.create();

  beforeEach(async () => {
    wordDao = await WordDao.new();
    const {logs} = await wordDao.setupDao(
      language,
      fee,
      tribute,
      wordCount,
      keyPair.address
    );
    expectEvent.inLogs(logs, "daoSetup", {language, fee, tribute, wordCount});
  });

  it("can add a signed word", async () => {
    const word = "love";
    const signature = await signWord(word, keyPair.privateKey);
    const {logs} = await wordDao.addWord(language, word, signature, {
      from: secondAddress,
      value: tribute
    });
    expectEvent.inLogs(logs, "wordAdded", {
      word,
      tribute,
      adder: secondAddress
    });
  });

  it("will not accept the same word twice", async () => {
    const word = "love";
    const signature = await signWord(word, keyPair.privateKey);
    await wordDao.addWord(language, word, signature, {
      from: secondAddress,
      value: tribute
    });
    await shouldFail(
      wordDao.addWord(language, word, signature, {
        from: secondAddress,
        value: tribute
      }),
      "Word has already been Added."
    );
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
