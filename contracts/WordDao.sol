pragma solidity ^0.5.0;

import "./WordToken.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";

contract WordDao is Initializable {

  WordToken public token;

  function SetupDao() public initializer {
    token = new WordToken(450000);
  }

}