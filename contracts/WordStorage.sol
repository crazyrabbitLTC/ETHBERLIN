pragma solidity ^0.5.0;

contract WordStorage {
    uint256 public totalWords;
    string public language;
    address public wordDao;
  
    uint256 public fee;

    /********
    MODIFIERS
    ********/
    modifier onlyWordDao {
        require(msg.sender == wordDao, "Moloch::onlyMember - not a member");
        _;
    }

    //It might be a good idea that the fee is transfered out of the wordstorage contract
    modifier requireFeePayment {
        require(msg.value >= fee, "Requires Payment");
        _;
    }

    //Store words based on Integers
    mapping(uint256 => string) internal wordByNumber;
    mapping(string => uint256) internal numberForWord;
    mapping(bytes32 => string) internal wordByBytes32;
    mapping(string => bytes32) internal bytes32ForWord;
    mapping(uint256 => bytes32) internal uint256ForBytes32;
    mapping(bytes32 => uint256) internal bytes32ForWordUint256;

    //Arrays
    bytes32[] internal arrayOfBytes32;
    uint256[] internal arrayOfUint256;
    string[] internal arrayOfWords;

    //events for accessing words
    //wordAdded
    event wordAdded(
        string _word,
        address indexed _from,
        uint256 _wordNumber,
        bytes32 indexed _wordBytes32
    );
    event wordRequested(uint256 _wordNumber, address indexed _from);
    event storageCreated(
        string language,
        uint256 fee,
        address storageAddress,
        address wordDao
    );
    event feeChanged(uint256 fee);

    constructor(string memory _language, uint256 _fee) public {
        language = _language;
        wordDao = msg.sender;
        fee = _fee;
        emit storageCreated(language, fee, address(this), msg.sender);
    }

    //only doa
    function changeFee(uint256 _fee) external onlyWordDao {
        fee = _fee;
        emit feeChanged(fee);
    }

    function setWord(string memory _word)
        public
        onlyWordDao
        returns (bool)
    {
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
        emit wordAdded(_word, msg.sender, totalWords, _wordBytes32);

        return true;
    }

    //Public Getters

    //getWordStringToUint256
    function getWordStringToUint256(string calldata _word)
        external
        payable
        requireFeePayment
        returns (uint256)
    {
        return numberForWord[_word];
    }

    function stringToInt(string calldata _word)
        external
        view
        onlyWordDao
        returns (uint256)
    {
        return numberForWord[_word];
    }

    //getWordStringToBytes32
    function getWordStringToBytes32(string calldata _word)
        external
        payable
        returns (bytes32)
    {
        return bytes32ForWord[_word];
    }
    //getWordUint256ToString
    function getWordUint256ToString(uint256 _wordNumber)
        external
        payable
        requireFeePayment
        returns (string memory)
    {
        return wordByNumber[_wordNumber];
    }
    //getWordUint256ToBytes32
    function getWordUint256ToBytes32(uint256 _wordNumber)
        external
        payable
        requireFeePayment
        returns (bytes32)
    {
        return uint256ForBytes32[_wordNumber];
    }
    //getWordBytes32ToString
    function getWordBytes32ToString(bytes32 _wordBytes)
        external
        payable
        requireFeePayment
        returns (string memory)
    {
        return wordByBytes32[_wordBytes];
    }
    //getWordBytes32ToUint256
    function getWordBytes32ToUint256(bytes32 _wordBytes)
        external
        payable
        requireFeePayment
        returns (uint256)
    {
        return bytes32ForWordUint256[_wordBytes];
    }
  //Transfer function incase there is  value  left in the contract
        function transferEther() external payable onlyWordDao {
        address(wordDao).transfer(address(this).balance);
    }
}
