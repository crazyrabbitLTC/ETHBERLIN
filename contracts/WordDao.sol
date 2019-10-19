pragma solidity ^0.5.0;

/**
 * @title WordDAO
 * @author Dennison Bertram, dennison@dennisonbertram.com
 * @notice WordDAO is an integer->word mapping of words
 * @dev WordDao is a factory contract which creates and manages individual
 * WordStorage contracts. These contracts are created on a per-language basis.
 * The indended purpose is that each WordStorage is created with a Merkle root
 * that references an off-chain master list of words which constitute the total
 * number of initial words intended to be stored in the WordStorage. Additional
 * vanity words can be added to the storage for an additional fee, but by having
 * a precomputed merkle tree of words, users can start to use WordDao prior to the
 * contract being completed, IE: all the words stored.
 * The WordDao contract is intended to be controlled by an external DAO where the
 * members of the DAO are all the constitutents who contributed words to the WordStorage.
 */

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./Verify.sol";
import "./StorageFactory.sol";
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
    mapping(bytes32 => WordToken) public tokens;

    //Address of WordStorageFactory
    StorageFactory public storageFactory;

    //Address of the WordStorage that is created by the WordDao contract
    //Track Multiple Storage Units
    mapping(bytes32 => WordStorage) public storageUnits;
    mapping(bytes32 => string) public storageLanguage;
    mapping(bytes32 => bool) public storageExists;
    WordStorage[] public storageUnitArray;
    uint256 public storageCount;

    //Balance of this contract. This should be set to a seperate contract (gnosis safe?)
    uint256 public contractBalance;

    //The payment required to set a word.
    mapping(bytes32 => uint256) public tribute;

    //The payment required to set a vanity word.
    mapping(bytes32 => uint256) public vanityTribute;

    //The signature Authority that is required to have signed the words before adding them.
    mapping(bytes32 => bytes32) public merkleRoot;

    //Address of the Dao contract which controls the WordDao
    address public DAOController;

    //Address of the initial Administrator for the WordDao. Once setup, it should be transfered
    //To the DAOController.
    address public owner;

    /********
    MODIFIERS
    ********/

    /**
    *@dev This is used to restrict functions to only the DAO (or master address)
    */
    modifier onlyMaster {
        require(msg.sender == owner, "WordDao:: Only Master DAO can Control");
        _;
    }

    /** @dev A generic check that the word has not already been added */
    modifier wordDoesNotExist(string memory _word, string memory _language) {
        bytes32 pointer = getStoragePointer(_language);
        require(
            storageUnits[pointer].wordExists(_word) == false,
            "WordDAO: Vanity Check: Word has already been Added"
        );
        _;
    }

    //Not clear  that we need this. Funds should be move out of Dao.
    //Not needed only DAO can withdraw anyway.
    //Should seperate money from Find.
    //To prevent Reentrancy  for withdrawls. Copied from Moloch Dao.
    // bool locked;
    // modifier noReentrancy() {
    //     require(!locked, "WordDao: Reentrant call");
    //     locked = true;
    //     _;
    //     locked = false;
    // }

    /********
    EVENTS
    ********/

    /**
    * Event for when a word is added.
    * @param word added to the WordDao database.
    * @param wordIndex is the index (integer) of the word.
    * @param tribute is the amount of money paid by the user to add a word to the database
    * @param vanity is a boolean indicating whether the word is a vanity word.
    * @param adder is the address of the person or contract which added the word.
    */
    event wordAdded(
        string word,
        uint256 indexed wordIndex,
        uint256 tribute,
        bool vanity,
        address adder
    );

    /**
    * Event for announcing the address that controls WordDao
    * @param daoMaster is the address that controls the WordDao Contract.
    */
    event daoMaster(address daoMaster);

    /**
    * Event for announcing the transfer of funds to a destination with amount
    * @param destination is the address that recieves funds sent to WordDao.
    * @param amount is the amount of money sent to the destination.
    */
    event fundsTransfered(address destination, uint256 amount);

    /**
    * Event for announcement of the creation of a WordStorage Contract
    * @param language is the language of the created WordStorage.
    * @param storagePointer is the index of the WordStorage in the WordDao mapping.
    * @param fee is the amount of money required to access the WordStorage.
    * @param tribute is the amount of money required to add a word. The
    * @param vanityTribute is the amount of money required to add a vanity word. The
    * @param wordCount is the number of words in the offical word list.
    * @param storageContract is the address of the WordStorage contract.
    * @param merkleRoot is the root required from the offical word list to add a word.
    */
    event storageCreated(
        string language,
        bytes32 storagePointer,
        uint256 fee,
        uint256 tribute,
        uint256 vanityTribute,
        uint256 wordCount,
        address storageContract,
        bytes32 merkleRoot
    );

    /**
    * Event for announcement of the setting of Tribute fee
    * @param fee is the amount of money required to add a word
    * @param language is the language the fee is being set for
    */
    event setTribute(uint256 fee, string language);

    /**
    * Event for announcement of the setting of the fee to access the WordStorage
    * @param fee is the amount of money required to access the WordStorage
    * @param language is the language the fee is being required for
    */
    event setFee(uint256 fee, string language);

    /********
    FUNCTIONS
    ********/

    //TODO: Make Sign Authority changable

    /** 
    * @dev This function is part of the setup. Currently we only set the address of the
    * storageFactory contract 
    * @param _storageFactory is the address of the storageFactory.
    */
    function setupDao(StorageFactory _storageFactory) public initializer {
        //Set inital contract values
        owner = msg.sender;
        storageFactory = _storageFactory;
    }

    /**
    * @dev This function creates new WordStorage contracts. It is used to add additional
    * languages to the WordDao contract.
    * @param _language is the language of the storage contract.
    * @param _fee is the amount of money required to access the WordStorage.
    * @param _tribute is the amount of money required to add a word.
    * @param _vanityTribute is the amount of money required to add a vanity word not in the list.
    * @param _totalWordCount is the numnber of words in the official word list.
    * @param _merkleRoot is the root of the merkle tree that holds the official word list.
    */
    function addWordStorage(
        string memory _language,
        uint256 _fee,
        uint256 _tribute,
        uint256 _vanityTribute,
        uint256 _totalWordCount,
        bytes32 _merkleRoot
    ) public onlyMaster {
        _createStorage(
            _language,
            _fee,
            _tribute,
            _vanityTribute,
            _totalWordCount,
            _merkleRoot
        );
    }

    /**
    * Todo: his needs a more robust system. It should allow for a setup time, a dao, transfer to  down, and renounce control.
    * @dev This function sets the address which can contrl the WordDao contract.
    * It is only possible to be called by the current owner/controller of the contract.
    * @param _dao is the address that is being set to control the WordDao contract.
    */
    function setMaster(address _dao) public onlyMaster {
        DAOController = _dao;
        emit daoMaster(_dao);
    }

    /** 
    * Todo: Not sure why we need this. 
    * @dev This needs to be reconsidered, feels like duplicate functionality
    */
    function setOwnerToDao() public onlyMaster {
        owner = DAOController;
    }

    /**
    * Todo: Should check to see if the size of our word list will make this function fail or not. 
    * @dev Add a word to the the wordStorage associated to the language. Core functionality for adding words.
    * @param _language is the language for which we are adding a word.
    * @param _word is the word to add to the storage. 
    * @param _vanity true if the word we are adding is not in the list of words.
    * It's not important if vanity is in the list or not, it just changes the price the users needs to pay
    * and avoids checking against the merkleRoot if it's a valid word or not.
    * @param _leaf required to check if the word is in the official list or not. 
    * @param _proof the merkle proof generated on the client side to prove the words is in the list.
    * @param _positions the position of the leaves in the proof.
    */
    function addWord(
        string memory _language,
        string memory _word,
        bool _vanity,
        bytes32 _leaf,
        bytes32[] memory _proof,
        uint256[] memory _positions
    ) public payable wordDoesNotExist(_word, _language) {
        bytes32 _storagePointer = getStoragePointer(_language);
        require(
            msg.value >= tribute[_storagePointer],
            "WordDAO: Vanity Check: Tribute not high enough"
        );

        if (_vanity) {
            require(
                msg.value - vanityTribute[_storagePointer] > 0,
                "WordDAO: Vanity Check: Vanity fee not high enough"
            );
        } else {
            require(
                isValidData(
                    _word,
                    merkleRoot[_storagePointer],
                    _leaf,
                    _proof,
                    _positions
                ),
                "WordDAO: Word Not Valid"
            );
        }

        storageUnits[_storagePointer].setWord(_word);
        tokens[_storagePointer].transfer(msg.sender, 1);
        contractBalance += msg.value;

        emit wordAdded(
            _word,
            storageUnits[_storagePointer].getWordStringToUint256forDao(_word),
            msg.value,
            _vanity,
            msg.sender
        );
    }

    /**
    * @dev This sets the fee that is required for contracts to access the wordStorage.
    * @param _fee This is the fee amount.
    * @param _language This is the language of the wordStorage we want to set the fee for.
    */
    function setUseFee(uint256 _fee, string calldata _language)
        external
        onlyMaster
    {
        emit setFee(_fee, _language);
        storageUnits[getStoragePointer(_language)].changeFee(_fee);
    }

    /**
    * @dev This sets the fee that is required to add a word.
    * @param _fee is the amount of money required to add a word.
    * @param _language is the language of the wordStorage we want to set the fee for.
    */
    function setTributeFee(uint256 _fee, string calldata _language)
        external
        onlyMaster
    {
        //In wei
        tribute[getStoragePointer(_language)] = _fee;
        emit setTribute(_fee, _language);
    }

    /**
    * @dev This retrieves the balance of the WordDao itself.
    * Going forward this might not be nessesary. The plan is to ideally not keep funds in
    * the contract at all.
    */
    function getWordDaoBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
    * @dev This will withdraw the balance of the WordDao contract if it has funds at it.
    * Going forward this may be removed (or not?) depending on if the contract can DIRECTLY
    * accept funds.
    */
    function withDraw(uint256 _amount, address payable _destination)
        public
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
    /**
    * @dev This is an internal utility function which returns the storage pointer for the wordStorage.
    * It is generated by hashing the language name. For this reason languages must be unique.
    */
    function getStoragePointer(string memory _language)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_language));
    }

    /**
    * @dev Internal function responsible for creating a new storage.
    */
    function _createStorage(
        string memory _language,
        uint256 _fee,
        uint256 _tribute,
        uint256 _vanityTribute,
        uint256 _totalWordCount,
        bytes32 _merkleRoot
    ) internal {
        //DRY: Storage pointer
        bytes32 _storagePointer = getStoragePointer(_language);
        require(
            storageExists[_storagePointer] == false,
            "WordDao:: Storage Language already exists."
        );
        tribute[_storagePointer] = _tribute;
        vanityTribute[_storagePointer] = _vanityTribute;
        //Setup the token with the tokens availible. This should be fixed to fix token supply.
        //Need to Extract this part to a new internal function
        WordToken tempToken = new WordToken(
            _totalWordCount,
            _language,
            _language
        );
        tokens[_storagePointer] = tempToken;

        //Cast the address of this contract, the WordDao to address payable
        address payable fundRecipent = address(uint160(address(this)));

        //Create a new wordStorage
        //TODO: Explore using Create2 to create wordStorage, this way we can predict their locations
        WordStorage wordStorage = storageFactory.createWordStorage(
            _language,
            _fee,
            fundRecipent,
            address(uint160(address(this)))
        );

        //Store the created WordStorage in the Storage Units
        storageUnitArray.push(wordStorage);
        storageUnits[_storagePointer] = wordStorage;
        storageLanguage[_storagePointer] = _language;
        storageExists[_storagePointer] = true;
        storageCount += 1;

        //Set the Merkle Root for the language
        merkleRoot[_storagePointer] = _merkleRoot;

        emit storageCreated(
            _language,
            _storagePointer,
            _fee,
            _tribute,
            _vanityTribute,
            _totalWordCount,
            address(storageUnits[_storagePointer]),
            merkleRoot[_storagePointer]
        );
    }

}
