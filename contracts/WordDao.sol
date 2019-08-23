pragma solidity ^0.5.0;

import "./WordToken.sol";
import "./WordStorage.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";

contract WordDao is Initializable, WordStorage {
    WordToken public token;
    WordStorage public wordStorage;

    uint256 public balance;
    uint256 public tribute;
    address public signAuthority;
    address public DAOController;
    address public owner;

    /********
    MODIFIERS
    ********/
    modifier onlyMaster {
        require(msg.sender == wordDao, "WordDao:: Only Master DAO can Control");
        _;
    }

    mapping(uint256 => string) wordMapping;

    event wordAdded(string word, uint256 tribute, address adder);

    //the Token should be mintable
    function SetupDao(
        string memory _language,
        uint256 _fee,
        address _signAuthority
    ) public initializer {
        token = new WordToken(450000);
        signAuthority = _signAuthority;
        wordStorage = new WordStorage(_language, _fee);
        owner = msg.sender;
        tribute = 1 ether;
    }

    function setMaster(address _dao) public {
        require(msg.sender == owner, "Only Owner can change dao Controller");
        DAOController = _dao;
    }

    //This needs to use ECRecover to besure the signer made it.
    function checkSignature() internal returns (bool) {
        return true;
    }

    function addWord(string memory _word) public payable {
        require(checkSignature(), "Signature does not match");
        require(msg.value >= tribute, "Tribute not high enough");
        token.transfer(msg.sender, 1);
        balance += msg.value;
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
