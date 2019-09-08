const {
  BN,
  constants,
  expectEvent,
  shouldFail,
  expectRevert
} = require("openzeppelin-test-helpers");
const should = require("chai").should();

const WordStorage = artifacts.require("WordStorage");

contract(
  "Word Storage",
  async ([firstAddress, secondAddress, ...otherAccounts]) => {
    let wordStorage;

    const language = "english";
    let fee = new BN(10);
    let receiver = web3.eth.accounts.create();
    const word = "hello";
    const wordBytes32 = web3.utils.fromAscii(word);
    const word2 = "goodbye";
    const word3 = "love";

    beforeEach(async () => {
      wordStorage = await WordStorage.new(language, fee, receiver.address);
    });

    it("Should have the correct Language, Fee and receiver address", async () => {
      (await wordStorage.language()).should.equal(language);
      (await wordStorage.fee()).should.bignumber.equal(fee);
      (await wordStorage.ethReceiver()).should.equal(receiver.address);
    });

    it("Should allow to Change Fee only from WordDao Address", async () => {
      const newFee = new BN(11);
      const newFee2 = new BN(12);
      const {logs} = await wordStorage.changeFee(newFee);
      expectEvent.inLogs(logs, "feeChanged", {fee: newFee});
      await shouldFail(
        wordStorage.changeFee(newFee2, {from: secondAddress}),
        "The sender is not the WordDao"
      );
    });

    it("Should allow only the WordDao to add a word", async () => {
      const {logs} = await wordStorage.setWord(word, {from: firstAddress});
      expectEvent.inLogs(logs, "wordAdded", {word: word, from: firstAddress});
      await shouldFail(wordStorage.setWord(word2, {from: secondAddress}));
    });

    it("Should find the correct Integer for a word (for the WordDao)", async () => {
      await wordStorage.setWord(word, {from: firstAddress});
      await wordStorage.setWord(word2, {from: firstAddress});
      await wordStorage.setWord(word3, {from: firstAddress});

      (await wordStorage.getWordStringToUint256forDao(
        word
      )).should.bignumber.equal(new BN(0));
      (await wordStorage.getWordStringToUint256forDao(
        word2
      )).should.bignumber.equal(new BN(1));
      (await wordStorage.getWordStringToUint256forDao(
        word3
      )).should.bignumber.equal(new BN(2));
    });

    it("Should find the correct Integer only when paid for access", async () => {
      await wordStorage.setWord(word, {from: firstAddress});

      const tx = await wordStorage.getWordStringToUint256(word, {
        from: secondAddress,
        value: new BN(20)
      });

      expectEvent.inLogs(tx.logs, "wordRequested", {
        wordNumber: new BN(0),
        requestor: secondAddress
      });
      await shouldFail(
        wordStorage.getWordStringToUint256(word, {
          from: secondAddress
        })
      );
    });

    it("Should find the correct Integer only when paid for access", async () => {
      await wordStorage.setWord(word, {from: firstAddress});

      const {logs} = await wordStorage.getWordUint256ToString(new BN(0), {
        from: secondAddress,
        value: new BN(20)
      });

      expectEvent.inLogs(logs, "wordRequested", {
        wordNumber: new BN(0),
        requestor: secondAddress
      });
      await shouldFail(
        wordStorage.getWordStringToUint256(word, {
          from: secondAddress
        })
      );
    });

    it("Should find the correct word when sent as bytes32", async () => {
      await wordStorage.setWord(word, {from: firstAddress});

      const {logs} = await wordStorage.getWordBytes32ToString(wordBytes32, {
        from: secondAddress,
        value: new BN(20)
      });

      expectEvent.inLogs(logs, "wordRequested", {
        wordNumber: new BN(0),
        requestor: secondAddress
      });
    });

    it("Should find the correct word Integer when sent as bytes32", async () => {
      await wordStorage.setWord(word, {from: firstAddress});

      const {logs} = await wordStorage.getWordBytes32ToUint256(wordBytes32, {
        from: secondAddress,
        value: new BN(20)
      });

      expectEvent.inLogs(logs, "wordRequested", {
        wordNumber: new BN(0),
        requestor: secondAddress
      });
    });

    it("Should transfer any value in the contract to the ethReceiver", async () => {
      await wordStorage.setWord(word, {from: firstAddress});
      const balance = await web3.eth.getBalance(receiver.address);

      const {logs} = await wordStorage.getWordBytes32ToUint256(wordBytes32, {
        from: secondAddress,
        value: new BN(200000000)
      });

      const contractBalance = await web3.eth.getBalance(wordStorage.address);
      await wordStorage.transferEther();
      const balance2 = await web3.eth.getBalance(receiver.address);

      console.log(
        `Inital Address BAalnce: ${balance} after address balance: ${balance2}  and the contract balance when it had funds: ${contractBalance}`
      );
      expect(balance2).to.be.equal(balance.add(contractBalance));
    });
  }
);
