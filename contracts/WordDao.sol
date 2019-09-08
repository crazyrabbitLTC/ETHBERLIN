pragma solidity ^0.5.0;

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./Verify.sol";
import "./WordStorage.sol";
import "./WordToken.sol";

contract WordDao is Initializable, Verify {
    //TODO: Decide if the WordDao should delegateCall the requests to the storage, or if the storage should be addressed inidividually.
    //PROS: DelegateCall would make the code more DRY and the storage units could reduce their code
    //CONS: might introduce more complexity
    //TODO: Make everything an upgradable instance
    //PROS: We can upgrade whenever
    //CONS?: We need to involve the OZ SDK programatic libray for increased complexity.
    //TODO: Mint ERC721 Tokens for users that would like them.
    //TODO: Improve ERC20 minting situation
    //TODO: Calculate the Tribute to a fixed amount. (Use DAI?)

    /********
    Storage Variables
    ********/

    //Address of the ERC20 token that is given to users who contribute words
    WordToken public token;

    //Address of the WordStorage that is created by the WordDao contract
    //Track Multiple Storage Units
    mapping(bytes32 => WordStorage) public storageUnits;
    mapping(bytes32 => string) public storageLanguage;
    WordStorage[] public storageUnitArray;
    uint256 public storageCount;

    //Balance of this contract. This should be set to a seperate contract (gnosis safe?)
    uint256 public contractBalance;

    //The payment required to set a word.
    mapping(bytes32 => uint256) public tribute;

    //The signature Authority that is required to have signed the words before adding them.
    mapping(bytes32 => address) public signAuthority;

    //Address of the Dao contract which controls the WordDao
    address public DAOController;

    //Address of the initial Administrator for the WordDao. Once setup, it should be transfered
    //To the DAOController.
    address public owner;

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
        bytes32 storagePointer,
        uint256 fee,
        uint256 tribute,
        uint256 wordCount,
        address storageContract,
        address signAuthority
    );

    event setTribute(uint256 fee, string language);
    event setFee(uint256 fee, string language);

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
        //DRY: Storage pointer
        bytes32 _storagePointer = getStoragePointer(_language);

        //Set inital contract values
        owner = msg.sender;
        tribute[_storagePointer] = _tribute;

        //Setup the token with the tokens availible. This should not be fixed to allow for new words.
        token = new WordToken(_totalWordCount);

        //Cast the address of this contract, the WordDao  to address payable
        address payable fundRecipent = address(uint160(address(this)));

        //Create a new wordStorage
        WordStorage wordStorage = new WordStorage(
            _language,
            _fee,
            fundRecipent
        );

        //Store the created WordStorage in the Storage Units
        storageUnitArray.push(wordStorage);
        storageUnits[_storagePointer] = wordStorage;
        storageLanguage[_storagePointer] = _language;
        storageCount += 1;

        //Set the address that has the authority to sign new words
        // signAuthority = address(0x76991b32A0eE1996E5c3dB5FdD29029882D587DF);
        signAuthority[_storagePointer] = _signAuthority;

        emit daoSetup(
            _language,
            _storagePointer,
            _fee,
            _tribute,
            _totalWordCount,
            address(storageUnits[_storagePointer]),
            signAuthority[_storagePointer]
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
    function addWord(
        string memory _language,
        string memory _word,
        bytes memory signature
    ) public payable {
        bytes32 _storagePointer = getStoragePointer(_language);
        require(
            storageUnits[_storagePointer].wordExists(_word) == false,
            "Word has already been Added"
        );
        require(
            isValidData(_word, signature, signAuthority[_storagePointer]),
            "Word Not Valid"
        );
        require(
            msg.value >= tribute[_storagePointer],
            "Tribute not high enough"
        );

        storageUnits[_storagePointer].setWord(_word);
        token.transfer(msg.sender, 1);
        contractBalance += msg.value;
        emit wordAdded(
            _word,
            storageUnits[_storagePointer].getWordStringToUint256forDao(_word),
            msg.value,
            msg.sender
        );
    }

    //Set the fee required to access a word.
    function setUseFee(uint256 _fee, string calldata _language)
        external
        onlyMaster
    {
        emit setFee(_fee, _language);
        storageUnits[getStoragePointer(_language)].changeFee(_fee);
    }

    //Set the Fee required to add a word.
    function setTributeFee(uint256 _fee, string calldata _language)
        external
        onlyMaster
    {
        //In wei
        tribute[getStoragePointer(_language)] = _fee;
        emit setTribute(_fee, _language);
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
        require(_amount > 0, "Amount must be greater than zero");
        require(
            _amount <= address(this).balance,
            "Amount must be less than or equal to balance"
        );
        address(_destination).transfer(_amount);
        emit fundsTransfered(_destination, _amount);
    }

    //Utility Function to get the Storage Pointer Name from string into bytes32
    function getStoragePointer(string memory _storageName)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_storageName));
    }

}
