pragma solidity ^0.5.0;

import "./WordStorage.sol";

contract StorageMaker {
    //Limit the Scope
    function makeStorage(
        string memory _language,
        uint256 _fee,
        address payable _fundRecipient
    ) public returns (WordStorage) {
        WordStorage wordStorage = new WordStorage(
            _language,
            _fee,
            _fundRecipient
        );

        return wordStorage;
    }
}
