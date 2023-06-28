// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "lib/forge-std/src/console.sol";

contract dummy {

    uint public input;

    function functionTest(uint _input) public payable {
        require(msg.value != 0, "must send value");
        input = _input;
    }


}


contract ScratchTest is Test {

    dummy public d;
    address public admin = address(0xad1);

    function setUp() public {
        vm.startPrank(admin);
        vm.deal(admin, 100 ether);
        d = new dummy();
    }

    function testBase() public {

        d.functionTest{value: 100}(100);
        assertEq(d.input(), 100);
        assertEq(address(d).balance, 100);

    }

    function testSig() public {

        bytes memory sig = abi.encodeWithSignature("functionTest(uint256)", abi.encode(100));

        emit log_bytes(sig);
    }

    function testPadded() public {

        uint value = 1;

        emit log_named_string("unchanged", toHexString(value));
    }

    function testunpadded3() public {

        uint value = 1;

        emit log_named_string("unpadded", toUnpaddedHexString3(value));
    }

    function testunpadded2() public {

        uint value = 1;

        emit log_named_string("unpadded", toUnpaddedHexString2(value));
    }

    function testunpadded_gas() public {

        uint value = 1;

        emit log_named_string("unpadded", toMinimalHexString(value));
    }


    function testunpadded() public {

        uint value = 1;

        emit log_named_string("unpadded 1", toUnpaddedHexString(value));
        emit log_named_string("unpadded 25", toUnpaddedHexString(25));
        emit log_named_string("unpadded 0", toUnpaddedHexString(0));
        emit log_named_string("unpadded 0x0123", toUnpaddedHexString(291));
        emit log_named_string("unpadded 0x1234", toUnpaddedHexString(4660));

    }

    function testAsm() public {
    
            console.log(checkAsm(string("0123")),"0123");
            console.log(checkAsm(string("1234")),"1234");
            bool result = startsWith0("1234");
            bool result2 = startsWith0("0123");
            console.log(result, "0x1234");
            console.log(result2, "0x0123");
    }

    function startsWith0(string memory subject)
        internal
        pure
        returns (bool result)
    {
        string memory zero = "0";
        /// @solidity memory-safe-assembly
        assembly {
            // Just using keccak256 directly is actually cheaper.
            // forgefmt: disable-next-item
            result := 
                eq(
                    keccak256(add(subject, 0x20), 1),
                    keccak256(add(zero, 0x20), 1)
                )
        }
    }

    function checkAsm(string memory subject)
        internal
        pure
        returns (bool result)
    {
        bool is30;
        /// @solidity memory-safe-assembly
        
        assembly {
            // Load the first byte of the data
            is30 := eq(byte(0, mload(add(subject, 0x20))), 0x30)
        }
        return is30;
    }


    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2 + 2` bytes.
    function toUnpaddedHexString3(uint256 value) public pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly

        bool leadingZero = startsWith(str, '0');

        if(leadingZero) {
            assembly {
                let strLength := add(mload(str), 2) // Compute the length.
                mstore(add(str,1), 0x3078) // Write the "0x" prefix.
                str := sub(str, 2) // Move the pointer.
                mstore(str, strLength) // Write the length.
            }
        } else {
            assembly {
                let strLength := add(mload(str), 2) // Compute the length.
                mstore(str, 0x3078) // Write the "0x" prefix.
                str := sub(str, 2) // Move the pointer.
                mstore(str, strLength) // Write the length.
            }
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2 + 2` bytes.
    function toUnpaddedHexString2(uint256 value) public pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly

        bool leadingZero = startsWith0(str);

        if(leadingZero) {
            assembly {
                let strLength := add(mload(str), 2) // Compute the length.
                mstore(add(str,1), 0x3078) // Write the "0x" prefix.
                str := sub(str, 2) // Move the pointer.
                mstore(str, strLength) // Write the length.
            }
        } else {
            assembly {
                let strLength := add(mload(str), 2) // Compute the length.
                mstore(str, 0x3078) // Write the "0x" prefix.
                str := sub(str, 2) // Move the pointer.
                mstore(str, strLength) // Write the length.
            }
        }
    }


    function toUnpaddedHexString(uint256 value) public pure returns (string memory str) {
        str = toHexStringNoPrefix(value);

        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            let leadingZero := eq(byte(0, mload(add(str, 0x20))), 0x30)

            let offset := 0 
            if leadingZero { offset := 1 }
            
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(add(str,offset), 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    function toMinimalHexString(uint256 value) public pure returns (string memory str) {
        str = toHexStringNoPrefix(value);

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

    function toUnpaddedHexString4(uint256 value) public pure returns (string memory str) {
        str = toHexStringNoPrefix(value);

        string memory zero = "0";

        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            let result := 
                eq(
                    keccak256(add(str, 0x20), 1),
                    keccak256(add(zero, 0x20), 1)
                )

            let offset := 0 
            if result { offset := 1 }
            
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(add(str,offset), 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }

    }


    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2 + 2` bytes.
    function toHexString(uint256 value) public pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2` bytes.
    function toHexStringNoPrefix(uint256 value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x40 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x40) is 0xa0.
            str := add(mload(0x40), 0x80)
            // Allocate the memory.
            mstore(0x40, add(str, 0x20))
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end to calculate the length later.
            let end := str
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let w := not(1) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                str := add(str, w) // `sub(str, 2)`.
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(temp) { break }
            }

            // Compute the string's length.
            let strLength := sub(end, str)
            // Move the pointer and write the length.
            str := sub(str, 0x20)
            mstore(str, strLength)
        }
    }

    function startsWith(string memory subject, string memory search)
        internal
        pure
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let searchLength := mload(search)
            // Just using keccak256 directly is actually cheaper.
            // forgefmt: disable-next-item
            result := and(
                iszero(gt(searchLength, mload(subject))),
                eq(
                    keccak256(add(subject, 0x20), searchLength),
                    keccak256(add(search, 0x20), searchLength)
                )
            )
        }
    }




}