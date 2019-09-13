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

    // Modifier that allows only the WordDao to administer the storage, copied from Moloch
    modifier onlyWordDao {
        require(msg.sender == wordDao, "The sender is not the WordDao");
        _;
    }

    // Modifier that requires a payment in the amount equal to the fee,
    // And sends the fee off to a predetermined address.
    modifier requireFeePayment {
        require(msg.value >= fee, "Requires Payment");
        ethReceiver.transfer(msg.value);
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

    //wordAdded
    event wordAdded(
        string word,
        address indexed from,
        uint256 wordNumber,
        bytes32 indexed wordBytes32
    );
    event wordRequested(uint256 wordNumber, address indexed requestor);
    event storageCreated(
        string language,
        uint256 fee,
        address storageAddress,
        address wordDao,
        address fundRecipient
    );
    event feeChanged(uint256 fee);

    /********
    CODE
    ********/

    function setupStorage(
        string memory _language,
        uint256 _fee,
        address payable _ethReceiver
    ) public initializer {
        language = _language;
        wordDao = msg.sender;
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

    function changeFee(uint256 _fee) external onlyWordDao {
        fee = _fee;
        emit feeChanged(fee);
    }

    function setWord(string memory _word) public onlyWordDao returns (bool) {
        bytes32 _wordBytes32 = keccak256(abi.encodePacked(_word));
        wordByNumber[totalWords] = _word;
        numberForWord[_word] = totalWords;
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

    //Get the integer value of a word, by word, allowed only for wordDao
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
    ********/

    //Get the integer value of a word, by word
    function getWordStringToUint256(string calldata _word)
        external
        payable
        requireFeePayment
        returns (uint256)
    {
        emit wordRequested(numberForWord[_word], msg.sender);
        return numberForWord[_word];
    }

    //Get bytes32 value for a word, by word.
    function getWordStringToBytes32(string calldata _word)
        external
        payable
        returns (bytes32)
    {
        emit wordRequested(numberForWord[_word], msg.sender);
        return bytes32ForWord[_word];
    }

    //Get string value for a word, by integer
    function getWordUint256ToString(uint256 _wordNumber)
        external
        payable
        requireFeePayment
        returns (string memory)
    {
        emit wordRequested(_wordNumber, msg.sender);
        return wordByNumber[_wordNumber];
    }

    //Get bytes32 value for a word, by integer
    function getWordUint256ToBytes32(uint256 _wordNumber)
        external
        payable
        requireFeePayment
        returns (bytes32)
    {
        emit wordRequested(_wordNumber, msg.sender);
        return uint256ForBytes32[_wordNumber];
    }

    //Get string value for a word, by bytes32
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

    // //Transfer function incase there is  value  left in the contract
    // function transferEther() external payable onlyWordDao {
    //     ethReceiver.transfer(address(this).balance);
    // }

}
