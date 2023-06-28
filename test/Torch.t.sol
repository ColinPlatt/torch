// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Torch.sol";


contract TorchTest is Test {
    Torch public nft;
    address public dep = address(0xad1);

    function setUp() public {
        vm.startPrank(dep);
            nft = new Torch();
        vm.stopPrank();
        _multiTransfer(500);
    }

    function _multiTransfer(uint amount) internal {
        address[] memory tos = new address[](amount);

        for (uint256 i = 0; i < amount; i++) {
            tos[i] = address(bytes20(keccak256(abi.encodePacked(i, uint(100)))));   
            //emit log_named_address(string.concat("address for ", vm.toString(i)), tos[i]);
        }

        for (uint256 i = 0; i < amount; i++) {
            vm.startPrank(nft.ownerOf(1));
                nft.safeTransferFrom(nft.ownerOf(1), tos[i], 1);
            vm.stopPrank();
        }
    }

    function testMultiTransfer() public {

        assertEq(nft.pastOwners(0), dep);
        assertEq(nft.pastOwners(9), address(bytes20(keccak256(abi.encodePacked(uint(8), uint(100)))))); 
    }

    function testSVG() public {
        string memory svg = nft.tokenURI(1);

        emit log_named_string("svg", svg);
    }

    function testHTML() public {

        string memory result = nft.tokenURI(0);

        //emit log_named_string("website", result);
        vm.writeFile("test/output/renderedSite.html", result);
    }

}
