pragma solidity ^0.5.0;
import "@openzeppelin/upgrades/contracts/Initializable.sol";

contract WordStorage is Initializable {
    uint256 public totalWords;
    string public language;
    address public wordDao;
    address payable public ethReceiver;
    uint256 public fee;

    /********
    MODIFIERS
    ********/

    /**
    * @dev Modifier that allows only the WordDao to administer the storage.
    */
    modifier onlyWordDao {
        require(
            msg.sender == wordDao,
            "WordStorage:: The sender is not the WordDao"
        );
        _;
    }
    /** 
    * @dev Modifier that requires a payment in the amount equal to the fee,
    * And sends the fee off to a predetermined address.
    */
    modifier requireFeePayment {
        require(msg.value >= fee, "Requires Payment");
        if (msg.value > 0) {
            ethReceiver.transfer(msg.value);
        }
        _;
    }

    /********
    STORAGE
    ********/

    //MAPPING
    mapping(uint256 => string) internal wordByNumber;
    mapping(string => uint256) internal numberForWord;
    mapping(bytes32 => string) internal wordByBytes32;
    mapping(string => bytes32) internal bytes32ForWord;
    mapping(uint256 => bytes32) internal uint256ForBytes32;
    mapping(bytes32 => uint256) internal bytes32ForWordUint256;

    mapping(string => bool) public wordExists;

    //ARRAYS
    bytes32[] internal arrayOfBytes32;
    uint256[] internal arrayOfUint256;
    string[] internal arrayOfWords;

    /********
    EVENTS
    ********/

    /**
    * Event for when a word is added.
    * @param word added to the storage.
    * @param from who the word was added, (the adders address)
    * @param wordNumber the integer that maps to the word added.
    * @param wordByBytes32 the bytes32 version of the word.
    */
    event wordAdded(
        string word,
        address indexed from,
        uint256 wordNumber,
        bytes32 indexed wordBytes32
    );

    /**
    * Event for when a word is requested.
    * @param wordNumber is the integer of the word requested.
    * @param requestor is the address requesting the word.
    */
    event wordRequested(uint256 wordNumber, address indexed requestor);

    /**
    * Event for when this storage is created along with it's details.
    * @param language of the storage.
    * @param fee how much it costs to access a word.
    * @param storageAddress is THIS contracts address.
    * @param wordDao is the controlling wordDao contract address.
    * @param fundRecipient is the address where the monenies collected are sent.
    */
    event storageCreated(
        string language,
        uint256 fee,
        address storageAddress,
        address wordDao,
        address fundRecipient
    );

    /**
    * Event for the change in fees.
    * @param fee is the new fee. 
    */
    event feeChanged(uint256 fee);

    /********
    CODE
    ********/

    /**
    * @dev function to setup the intial properties of the wordStorage. This is called when the storage
    * is created.
    * @param _language is the language of the storage.
    * @param _fee is the cost to access a word by default.
    * @param _ethReceiver is the address that gets any funds collected by the contract.
    * @param _owner is the initial owner of the countract which is set to the wordDao.
    * TODO: This needs to be improved.
    */
    function setupStorage(
        string memory _language,
        uint256 _fee,
        address payable _ethReceiver,
        address _owner
    ) public initializer {
        language = _language;
        wordDao = _owner;
        fee = _fee;
        ethReceiver = _ethReceiver;
        emit storageCreated(
            language,
            fee,
            address(this),
            msg.sender,
            ethReceiver
        );
    }

    /********
    SETTERS
    ********/

    /**
    * @dev Function change the fee request for accessing a word.
    * @param _fee is the cost to access a word.
    */
    function changeFee(uint256 _fee) external onlyWordDao {
        fee = _fee;
        emit feeChanged(fee);
    }

    /**
    * @dev Function to set a word, basically ADD a word to the Storage. Can only be called by WordDao.
    * @param _word to be added to the storage.
    * @return true. (Always returns true, should possibly change this?)
    * TODO: look into the purpose of 'totalWords' maybe there is a better way.
    */
    function setWord(string memory _word) public onlyWordDao returns (bool) {
        bytes32 _wordBytes32 = keccak256(abi.encodePacked(_word));
        wordByNumber[totalWords] = _word;
        numberForWord[_word] = totalWords; //need to revist what is happening here....confusing
        wordByBytes32[_wordBytes32] = _word;
        bytes32ForWord[_word] = _wordBytes32;
        uint256ForBytes32[totalWords] = _wordBytes32;
        bytes32ForWordUint256[_wordBytes32] = totalWords;
        arrayOfBytes32.push(_wordBytes32);
        arrayOfWords.push(_word);
        arrayOfUint256.push(totalWords);
        totalWords = totalWords + 1;
        wordExists[_word] = true;
        emit wordAdded(_word, msg.sender, totalWords, _wordBytes32);

        return true;
    }

    /********
    Internal(ish) Getter  (NonPaid)
    ********/

    /**
    * @dev This function returns the integer that the word is mapped to.
    * Only the address which represents the wordDao can call this.
    * @param _word Is the word requested as a string.
    * @return Integer that represents the words mapping.
    * TODO: Is it nessesary for this to be restricted to wordDao? In case we remove
    * the nessesity for there to be a fee?
    */
    function getWordStringToUint256forDao(string calldata _word)
        external
        view
        onlyWordDao
        returns (uint256)
    {
        return numberForWord[_word];
    }

    /********
    PUBLIC GETTERS (FOR PAYMENT)
    TODO: reconsider the payment idea for interest on stored value.
    ********/

    /**
    * @dev Get the integer value of a word, by word, for contracts.
    * @param _word requetsed.
    * @return`Integer value which maps to the requested word. 
    */
    function getWordStringToUint256(string calldata _word)
        external
        payable
        requireFeePayment
        returns (uint256)
    {
        emit wordRequested(numberForWord[_word], msg.sender);
        return numberForWord[_word];
    }

    /**
    * @dev Get bytes32 value for a word, by word. by word, for contracts.
    * @param _word requetsed.
    * @return`bytes32 value which maps to the requested word. 
    */
    function getWordStringToBytes32(string calldata _word)
        external
        payable
        returns (bytes32)
    {
        emit wordRequested(numberForWord[_word], msg.sender);
        return bytes32ForWord[_word];
    }

    /**
    * @dev Get the string value of a word, by the integer which maps to it.
    * @param _wordNumber is an integer which maps to a word.
    * @return the word as a string.
    */
    function getWordUint256ToString(uint256 _wordNumber)
        external
        payable
        requireFeePayment
        returns (string memory)
    {
        emit wordRequested(_wordNumber, msg.sender);
        return wordByNumber[_wordNumber];
    }

    /**
    * @dev Get the bytes32 value of a word by the integer of the word.
    * @param _wordNumber the integer value that maps to the word.
    * @return the bytes32 value of the word.
    */
    function getWordUint256ToBytes32(uint256 _wordNumber)
        external
        payable
        requireFeePayment
        returns (bytes32)
    {
        emit wordRequested(_wordNumber, msg.sender);
        return uint256ForBytes32[_wordNumber];
    }

    /**
    * @dev Get the string value of a word by it's bytes32 representation.
    * @param _wordBytes is the bytes32 representation of the word.
    * @return the string version of the word.
    */
    function getWordBytes32ToString(bytes32 _wordBytes)
        external
        payable
        requireFeePayment
        returns (string memory)
    {
        emit wordRequested(bytes32ForWordUint256[_wordBytes], msg.sender);
        return wordByBytes32[_wordBytes];
    }

    //Get integer value for a word, by bytes32
    /**
    * @dev Get the integer value for a word by it's bytes32 version.
    * @param _wordBytes is the word represented in bytes32.
    * @return the integer representation of the word.
    */
    function getWordBytes32ToUint256(bytes32 _wordBytes)
        external
        payable
        requireFeePayment
        returns (uint256)
    {
        emit wordRequested(bytes32ForWordUint256[_wordBytes], msg.sender);
        return bytes32ForWordUint256[_wordBytes];
    }

    /********
    UTILS
    ********/

    //Transfer function incase there is  value  left in the contract
    /**
    * @dev retreive any ETH which might be stuck in the contract.
    * TODO: Add a fallback function to capture eth sent.
    */
    function transferEther() external payable onlyWordDao {
        ethReceiver.transfer(address(this).balance);
    }

}
