pragma solidity ^0.5.0;

import "./WordToken.sol";
import "./WordStorage.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";

contract WordDao is Initializable, WordStorage {
    WordToken public token;
    WordStorage public wordStorage;

    uint256 public balance;
    address public signAuthority;
    address public DAOController;
    address public Owner;

    mapping(uint256 => string) wordMapping;

    event wordAdded(string word, uint256 tribute, address adder);

    function SetupDao(
        string memory _language,
        uint256 _fee,
        address _signAuthority
    ) public initializer {
        token = new WordToken(450000);
        signAuthority = _signAuthority;
        wordStorage = new WordStorage(_language, _fee);
        owner = msg.sender;
    }

    function setDaoController(address _dao) public {
        require(msg.sender == owner, "Only Owner can change dao Controller");
        DAOController = _dao;
    }

    function addWord(string memory _word) public payable {
        token.transfer(msg.sender, 1);
        balance += msg.value;
        emit wordAdded(_word, msg.value, msg.sender);
    }

    function getBalance() public returns (uint256) {
        return address(this).balance;
    }

}
