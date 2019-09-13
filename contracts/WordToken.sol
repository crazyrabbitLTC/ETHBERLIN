pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract WordToken is ERC20, ERC20Detailed {
    constructor(
        uint256 initialSupply,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public ERC20Detailed(_tokenName, _tokenSymbol, 18) {
        _mint(msg.sender, initialSupply);
    }
}
