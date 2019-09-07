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
  const tribute = new BN(10000000000);
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

  it("the balance of the contract increases when a word is added", async () => {
    const word = "love";
    const balanceBefore = await wordDao.getWordDaoBalance();
    const signature = await signWord(word, keyPair.privateKey);
    await wordDao.addWord(language, word, signature, {
      from: secondAddress,
      value: tribute
    });
    const balanceAfter = await wordDao.getWordDaoBalance();
    expect(balanceAfter.toString()).to.equal(
      balanceBefore.add(tribute).toString()
    );
  });

  //TODO: get the exact cost of gas for the transaction.
  it("We can withdraw the balance to an account", async () => {
    const word = "love";
    const signature = await signWord(word, keyPair.privateKey);
    const balanceBefore = await wordDao.getWordDaoBalance();
    await wordDao.addWord(language, word, signature, {
      from: secondAddress,
      value: tribute
    });

    const addressBalanceBefore = await web3.eth.getBalance(secondAddress);
    const gas = new BN(21000);
    const gasPrice = web3.utils.toWei(new BN(1), "gwei");
    const cost = gas.mul(gasPrice);
    const sendAmount = new BN(addressBalanceBefore).sub(cost);

    await web3.eth.sendTransaction({
      from: secondAddress,
      to: sender,
      gas,
      gasPrice,
      value: sendAmount
    });
    const balanceWithOneWord = await wordDao.getWordDaoBalance();
    await wordDao.withDraw(balanceWithOneWord, secondAddress);
    const balanceAfter = await wordDao.getWordDaoBalance();
    const addressBalanceAfter = await web3.eth.getBalance(secondAddress);

    expect(balanceAfter.toString()).to.equal(balanceBefore.toString());
    //expect(addressBalanceAfter.toString()).to.equal(new BN(addressBalanceBefore).add(tribute).add(cost).toString());
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
