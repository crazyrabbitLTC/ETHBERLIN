pragma solidity ^0.5.0;

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./Verify.sol";
import "./WordStorage.sol";
import "./WordToken.sol";

contract WordDao is Initializable, Verify {
    //TODO: Decide if the WordDao should delegateCall the requests to the storage, or if the storage should be addressed inidividually.

    /********
    Storage Variables
    ********/

    //Address of the ERC20 token that is given to users who contribute words
    WordToken public token;

    //Address of the WordStorage that is created by the WordDao contract
    WordStorage public wordStorage;

    //Balance of the contract. This should be set to a seperate contract (gnosis safe?)
    uint256 public contractBalance;

    //The payment required to set a word.
    uint256 public tribute;

    //The signature Authority that is required to have signed the words before adding them.
    address public signAuthority;

    //Address of the Dao contract which controls the WordDao
    address public DAOController;

    //Address of the initial Administrator for the WordDao. Once setup, it should be transfered
    //To the DAOController.
    address public owner;

    //Public Getter for if a word Exists. This should either be extracted to the wordStorage,
    //Or there should be availible functionlity to select by what contract you are addressing.
    //Arguments for leaving it here is reduced complexity for the Storage contract.
    //Arguments for putting it on the storage contract is that it kind of 'belongs' there.
    mapping(string => bool) public wordExists;
    mapping(uint256 => string) wordMapping;

    /********
    MODIFIERS
    ********/

    //This requires that contract be from the owner. Owner can be set  to be  MasterDao.
    modifier onlyMaster {
        require(msg.sender == owner, "WordDao:: Only Master DAO can Control");
        _;
    }

    //To prevent Reentrancy  for withdrawls. Copied from Moloch Dao.
    bool locked;
    modifier noReentrancy() {
        require(!locked, "WordDao: Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    /********
    EVENTS
    ********/

    event wordAdded(
        string word,
        uint256 indexed wordIndex,
        uint256 tribute,
        address adder
    );

    event daoMaster(address daoMaster);
    event fundsTransfered(address destination, uint256 amount);
    event daoSetup(
        string language,
        uint256 fee,
        uint256 tribute,
        uint256 wordCount,
        address storageContract,
        address signAuthority
    );

    /********
    FUNCTIONS
    ********/

    //TODO: Make Sign Authority changable

    //WordDao Setup
    function setupDao(
        string memory _language,
        uint256 _fee,
        uint256 _tribute,
        uint256 _totalWordCount,
        address _signAuthority
    ) public initializer {
        //Set inital contract values
        owner = msg.sender;
        tribute = _tribute;
        //Setup the token with the tokens availible. This should not be fixed to allow for new words.
        token = new WordToken(_totalWordCount);
        //Cast the address of this contract, the WordDao  to address payable
        address payable fundRecipent = address(uint160(address(this)));
        //Create a  new wordStorage
        wordStorage = new WordStorage(_language, _fee, fundRecipent);
        //Set the address that has the authority to sign new words
        // signAuthority = address(0x76991b32A0eE1996E5c3dB5FdD29029882D587DF);
        signAuthority = _signAuthority;
        emit daoSetup(
            _language,
            _fee,
            _tribute,
            _totalWordCount,
            address(wordStorage),
            signAuthority
        );
    }

    //Set the controller of the WordDao.
    //Todo: his needs a more robust system. It should allow for a setup time, a dao, transfer to  down, and renounce control.
    function setMaster(address _dao) public onlyMaster {
        DAOController = _dao;
        emit daoMaster(_dao);
    }

    function setOwnerToDao() public onlyMaster {
        owner = DAOController;
    }

    //Add a word to the DAO.
    //TODO: Allow for Multiple Storage Units
    function addWord(string memory _word, bytes memory signature)
        public
        payable
    {
        require(wordExists[_word] == false, "Word has already been Added");
        require(isValidData(_word, signature, signAuthority), "Word Not Valid");
        require(msg.value >= tribute, "Tribute not high enough");

        wordStorage.setWord(_word);
        token.transfer(msg.sender, 1);
        contractBalance += msg.value;
        wordExists[_word] = true;
        emit wordAdded(
            _word,
            wordStorage.getWordStringToUint256forDao(_word),
            msg.value,
            msg.sender
        );
    }

    //Set the fee required to access a word.
    function setUseFee(uint256 _fee) external onlyMaster {
        wordStorage.changeFee(_fee);
    }

    //Set the Fee required to add a word.
    function setTributeFee(uint256 _fee) external onlyMaster {
        //In wei
        tribute = _fee;
    }

    //Get the balance of the WordDao Contract itself.
    function getWordDaoBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //Withdraw the Balance of the WordDao Contract
    //There should be a seperate Contract for splitting payments to Token Holders.
    function withDraw(uint256 _amount, address payable _destination)
        public
        noReentrancy
        onlyMaster
    {
        address(_destination).transfer(_amount);
        emit fundsTransfered(_destination, _amount);
    }

}
