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
    //Set owner
    await wordDao.setupDao();
  });

  it("can setup a new WordDao", async () => {
    const {logs} = await wordDao.addWordStorage(
      language,
      fee,
      tribute,
      wordCount,
      keyPair.address
    );
    expectEvent.inLogs(logs, "storageCreated", {
      language,
      fee,
      tribute,
      wordCount
    });
  });

  it("can add a signed word with proper tribute", async () => {
    await wordDao.addWordStorage(
      language,
      fee,
      tribute,
      wordCount,
      keyPair.address
    );
    const word = "love";
    const signature = await signWord(word, keyPair.privateKey);

    await shouldFail(
      wordDao.addWord(language, word, signature, {
        from: secondAddress,
        value: new BN(0)
      }),
      "Tribute not high enough."
    );

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
  let storagePointer;
  let mock;
  const language = "english";
  const fee = new BN(10);
  const tribute = new BN(11);
  const wordCount = new BN(450000);

  const keyPair = web3.eth.accounts.create();

  beforeEach(async () => {
    wordDao = await WordDao.new();
    await wordDao.setupDao();
    const {logs} = await wordDao.addWordStorage(
      language,
      fee,
      tribute,
      wordCount,
      keyPair.address
    );

    storagePointer = logs[0].args["storagePointer"];

    //console.log("The logs: ", logs[0].args["storagePointer"]);
    //let mock = await MOCK.new(WordDao.address);
    //expectEvent.inLogs(logs, "storageCreated", {language, fee, tribute, wordCount});
  });

  it("can add multiple languages", async () => {
    const lang2 = "german";
    const lang3 = "spanish";

    const tx1 = await wordDao.addWordStorage(
      lang2,
      fee,
      tribute,
      wordCount,
      keyPair.address
    );

    const tx2 = await wordDao.addWordStorage(
      lang3,
      fee,
      tribute,
      wordCount,
      keyPair.address
    );

    expectEvent.inLogs(tx1.logs, "storageCreated", {
      language: lang2,
      fee,
      tribute,
      wordCount
    });
    expectEvent.inLogs(tx2.logs, "storageCreated", {
      language: lang3,
      fee,
      tribute,
      wordCount
    });
  });

  it("can retrieve created languages", async () => {
    const lang2 = "german";
    const lang3 = "spanish";

    const tx1 = await wordDao.addWordStorage(
      lang2,
      fee,
      tribute,
      wordCount,
      keyPair.address
    );

    const tx2 = await wordDao.addWordStorage(
      lang3,
      fee,
      tribute,
      wordCount,
      keyPair.address
    );

    //console.log(tx2.logs);
    const storagePointer1 = tx1.logs[0].args.storagePointer;
    const storagePointer2 = tx2.logs[0].args.storagePointer;
    const languageRetrieved1 = await wordDao.storageLanguage(storagePointer1);
    const languageRetrieved2 = await wordDao.storageLanguage(storagePointer2);

    expect(languageRetrieved1).to.be.equal(lang2);
    expect(languageRetrieved2).to.be.equal(lang3);
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

  it("will not allow illegal words to be added", async () => {
    const word = "love";
    const keyPair2 = web3.eth.accounts.create();
    const signature = await signWord(word, keyPair2.privateKey);
    await shouldFail(
      wordDao.addWord(language, word, signature, {
        from: secondAddress,
        value: tribute
      }),
      "Word Not Valid."
    );
    await shouldFail(
      wordDao.addWord(language, word, signature, {
        from: secondAddress
      }),
      "Tribute not high enough"
    );
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

  it("can change the value  of the Tribute fee", async () => {
    const newFee = new BN(200);
    const {logs} = await wordDao.setTributeFee(newFee, language);
    expectEvent.inLogs(logs, "setTribute", {fee: newFee, language: language});
  });

  it("can change the value  of the access fee", async () => {
    const newFee = new BN(200);
    const {logs} = await wordDao.setUseFee(newFee, language);
    expectEvent.inLogs(logs, "setFee", {fee: newFee, language: language});
  });

  it("can change the owner to the DAOController", async () => {
    const daoController = await wordDao.DAOController();
    const owner = await wordDao.owner();

    await wordDao.setOwnerToDao();

    const ownerAfter = await wordDao.owner();
    expect(owner).to.not.be.equal(ownerAfter);
    expect(ownerAfter).to.be.equal(daoController);
  });

  it("Can set the master Dao Address to a new address", async () => {
    const keyPair = web3.eth.accounts.create();

    const daoController = await wordDao.DAOController();
    const {logs} = await wordDao.setMaster(keyPair.address);
    const daoControllerAfter = await wordDao.DAOController();
    expectEvent.inLogs(logs, "daoMaster", {daoMaster: keyPair.address});
    expect(daoController).to.not.be.equal(daoControllerAfter);
    expect(daoControllerAfter).to.be.equal(keyPair.address);
  });

  it("We can withdraw the balance to an account with proper arugements", async () => {
    const word = "love";
    const signature = await signWord(word, keyPair.privateKey);
    const balanceBefore = await wordDao.getWordDaoBalance();
    await wordDao.addWord(language, word, signature, {
      from: secondAddress,
      value: tribute
    });

    const emptyKeypair = web3.eth.accounts.create();
    const addressBalanceBefore = await web3.eth.getBalance(
      emptyKeypair.address
    );

    const balanceWithOneWord = await wordDao.getWordDaoBalance();

    //Expect failure when using an unauthorized address
    await shouldFail(
      wordDao.withDraw(balanceWithOneWord, emptyKeypair.address, {
        from: secondAddress
      }),
      "WordDao:: Only Master DAO can Control"
    );
    await shouldFail(
      wordDao.withDraw(new BN(0), emptyKeypair.address),
      "Amount must be greater than zero"
    );
    await shouldFail(
      wordDao.withDraw(
        new BN(balanceWithOneWord).add(new BN(1000)),
        emptyKeypair.address
      ),
      "Amount must be less than or equal to balance"
    );

    await wordDao.withDraw(balanceWithOneWord, emptyKeypair.address);
    const balanceAfter = await wordDao.getWordDaoBalance();
    const addressBalanceAfter = await web3.eth.getBalance(emptyKeypair.address);

    expect(balanceAfter.toString()).to.equal(balanceBefore.toString());
    expect(addressBalanceAfter.toString()).to.equal(
      new BN(addressBalanceBefore).add(tribute).toString()
    );
  });
});
