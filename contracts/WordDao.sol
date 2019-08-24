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

    mapping(string => bool) wordExists;

    /********
    MODIFIERS
    ********/
    modifier onlyMaster {
        require(msg.sender == owner, "WordDao:: Only Master DAO can Control");
        _;
    }

    mapping(uint256 => string) wordMapping;

    event wordAdded(string word, uint256 tribute, address adder);
    event daoMaster(address daoMaster);

    //the Token should be mintable
    function SetupDao(string memory _language, uint256 _fee, address _signAuthority)
        public
        initializer
    {
        token = new WordToken(450000);
        wordStorage = new WordStorage(_language, _fee);
        owner = msg.sender;
        tribute = 1 wei;
        signAuthority = _signAuthority;
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
        require(
            isValidData(_word, signature, signAuthority),
            "Word Not Valid"
        );
        require(msg.value >= tribute, "Tribute not high enough");
        require(wordExists[_word] == false, "Word has already been Added");
        wordStorage.setWord(_word);
        token.transfer(msg.sender, 1);
        contractBalance += msg.value;
        wordExists[_word] = true;
        emit wordAdded(_word, msg.value, msg.sender);
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

}
