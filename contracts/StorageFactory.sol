pragma solidity ^0.5.0;

import "./WordStorage.sol";

contract StorageFactory {
    function createWordStorage(
        string memory _language,
        uint256 _wordFee,
        address payable _fundRecipent,
        address _owner
    ) public returns (WordStorage) {
        WordStorage wordStorage = new WordStorage();
        wordStorage.setupStorage(_language, _wordFee, _fundRecipent, _owner);
        return wordStorage;
    }

}
