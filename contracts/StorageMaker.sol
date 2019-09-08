pragma solidity ^0.5.0;

import "./WordStorage.sol";

contract StorageMaker {
    //Limit the Scope
    function makeStorage(
        string memory _language,
        uint256 _fee,
        address _fundRecipient
    ) public returns (WordStorage) {
        WordStorage wordStorage = new WordStorage(
            _language,
            _fee,
            _fundRecipent
        );

        return wordStorage;
    }
}
