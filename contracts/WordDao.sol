pragma solidity ^0.5.0;

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./WordStorage.sol";
import "./WordToken.sol";

contract WordDao is WordStorage, Initializable {
    WordToken public token;
    WordStorage public wordStorage;

    uint256 public contractBalance;
    uint256 public tribute;
    address public signAuthority = address(
        0xb4d7ca717459a622ae3ae02fe4adc1a7317a6b96c8d2eeeeda1a3697f3f4fd8e
    );
    address public DAOController;
    address public owner;

    mapping(string => bool) wordExists;

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
    function SetupDao(string memory _language, uint256 _fee)
        public
        initializer
    {
        token = new WordToken(450000);
        wordStorage = new WordStorage(_language, _fee);
        owner = msg.sender;
        tribute = 1 ether;
    }

    function setMaster(address _dao) public {
        require(msg.sender == owner, "Only Owner can change dao Controller");
        DAOController = _dao;
    }

    //This needs to use ECRecover to besure the signer made it.
    function checkSignature(bytes32 hash, bytes memory signature)
        internal view
        returns (bool)
    {
        if (recover(hash, signature) == signAuthority) {
            return true;
        } else {
            return false;
        }
    }

    function addWord(string memory _word, bytes32 hash, bytes memory signature)
        public
        payable
    {
        require(checkSignature(hash, signature), "Word Not Valid");
        require(msg.value >= tribute, "Tribute not high enough");
        require(wordExists[_word] == false, "Word has already been Added");
        wordStorage.setWord(_word);
        token.transfer(msg.sender, 1);
        contractBalance += msg.value;
        wordExists[_word] = true;
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

    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

}
