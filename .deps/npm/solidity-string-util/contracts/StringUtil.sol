pragma solidity ^0.8.0;


library StringUtil {
    function toHash(string memory _s) internal pure returns (bytes32) {
        return keccak256(abi.encode(_s));
    }

    function isEmpty(string memory _s) internal pure returns (bool) {
        return bytes(_s).length == 0;
    }

    function equalTo(string memory _s1, string memory _s2) internal pure returns (bool) {
        return toHash(_s1) == toHash(_s2);
    } 
}
