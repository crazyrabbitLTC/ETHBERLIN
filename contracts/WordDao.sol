pragma solidity ^0.5.0;

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./Verify.sol";
import "./WordStorage.sol";
import "./WordToken.sol";

contract WordDao is Initializable, Verify {
    WordToken public token;
    WordStorage public wordStorage;

    uint256 public contractBalance;
    uint256 public tribute;
    address public signAuthority;
    address public DAOController;
    address public owner;

    mapping(string => bool) public wordExists;

    /********
    MODIFIERS
    ********/
    modifier onlyMaster {
        require(msg.sender == owner, "WordDao:: Only Master DAO can Control");
        _;
    }

    bool locked;
    modifier noReentrancy() {
        require(!locked, "WordDao: Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    mapping(uint256 => string) wordMapping;

    event wordAdded(
        string word,
        uint256 indexed wordIndex,
        uint256 tribute,
        address adder
    );
    event daoMaster(address daoMaster);

    //the Token should be mintable
    function SetupDao(string memory _language, uint256 _fee, uint256 _tribute)
        public
        initializer
    {
        token = new WordToken(450000);
        wordStorage = new WordStorage(_language, _fee);
        owner = msg.sender;
        tribute = _tribute;
        signAuthority = address(0x76991b32A0eE1996E5c3dB5FdD29029882D587DF);
    }

    function setMaster(address _dao) public onlyMaster {
        require(msg.sender == owner, "Only Owner can change dao Controller");
        DAOController = _dao;
        emit daoMaster(_dao);
    }

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
            wordStorage.stringToInt(_word),
            msg.value,
            msg.sender
        );
    }

    function setUseFee(uint256 _fee) external onlyMaster {
        wordStorage.changeFee(_fee);
    }

    function setTributeFee(uint256 _fee) external onlyMaster {
        //In wei
        tribute = _fee;
    }

    function getWordDaoBalance() public view returns (uint256) {
        return address(this).balance;
    }

    event fundsTransfered(address destination, uint256 amount);
    function withDraw(uint256 _amount, address payable _destination)
        public
        noReentrancy
        onlyMaster
    {
        address(_destination).transfer(_amount);
        emit fundsTransfered(_destination, _amount);
    }

}
