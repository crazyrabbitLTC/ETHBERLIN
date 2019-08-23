pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract WordToken is ERC20, ERC20Detailed {
    constructor(uint256 initialSupply)
        public
        ERC20Detailed("WordToken", "WT", 18)
    {
        _mint(msg.sender, initialSupply);
    }
}
