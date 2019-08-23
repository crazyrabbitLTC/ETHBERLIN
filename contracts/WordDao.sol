pragma solidity ^0.5.0;

import "./WordToken.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";

contract WordDao is Initializable {
    WordToken public token;
    uint256 public balance;

    event wordAdded(string word, uint256 tribute, address adder);

    function SetupDao() public initializer {
        token = new WordToken(450000);
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
