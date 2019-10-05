pragma solidity ^0.5.0;
import "./MerkleProof.sol";

contract Verify is MerkleProof {
    function isValidData(
        string memory _word,
        bytes32 _root,
        bytes32 _leaf,
        bytes32[] memory _proof,
        uint256[] memory _positions
    ) public pure returns (bool) {
        if (keccak256(abi.encodePacked(_word)) == _leaf) {
            return merkleVerify(_root, _leaf, _proof, _positions);
        } else {
            return false;
        }
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        public
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }
    function splitSignature(bytes memory sig)
        public
        pure
        returns (uint8, bytes32, bytes32)
    {
        require(
            sig.length == 65,
            "There is an error with the signature length: Verify contract line 29"
        );
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }
}
