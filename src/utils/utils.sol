// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/solady/src/utils/LibString.sol";

library ExtLibString {

    function toMinimalHexString(uint256 value) public pure returns (string memory str) {
        str = LibString.toHexStringNoPrefix(value);

        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            let offset := eq(byte(0, mload(add(str, 0x20))), 0x30) // Check if leading zero is present.

            let strLength := add(mload(str), 2) // Compute the length.
            mstore(add(str, offset), 0x3078) // Write the "0x" prefix. Adjusting for leading zero.
            str := sub(str, sub(2, offset)) // Move the pointer.
            mstore(str, sub(strLength, offset)) // Write the length.
        }
    }

}