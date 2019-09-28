pragma solidity ^0.5.0;

import "contracts/WordStorage.sol";

contract WordStorageFactory {
    function createWordStorage(
        string memory _language,
        uint256 _wordFee,
        address payable _fundRecipent
    ) public returns (WordStorage) {
        WordStorage wordStorage = new WordStorage();
        wordStorage.setupStorage(_language, _wordFee, _fundRecipent);

        return wordStorage;
    }

}
