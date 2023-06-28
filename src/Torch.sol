// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable, SafeTransferLib, Base64} from "lib/solady/src/Milady.sol";
import {ERC721, ERC721TokenReceiver} from "lib/solmate/src/tokens/ERC721.sol";
import {ReentrancyGuard} from "lib/solmate/src/utils/ReentrancyGuard.sol";
import {json} from "./utils/JSON.sol";

import {TorchURI} from "./TorchURI.sol";

contract Torch is ERC721("Torch", unicode"🔥"), Ownable, ReentrancyGuard {
    
    address[] public pastOwners;
    uint256 public passAmt = 0.0001 ether;
    uint256 public withdrawable;
    
    error INCORRECT_PASS_VALUE();
    error INVALID_RECIPIENT();
    error UNSAFE_RECIPIENT();
    error INVALID_TOKEN_ID();

    constructor(){
        _initializeOwner(msg.sender);
        _mint(msg.sender, 0); //mint UI
        _mint(msg.sender, 1); //torch
    }


    function getSVG() public view returns (string memory) {
        uint256 len = pastOwners.length > 100 ? 100 : pastOwners.length;
        
        address[] memory previousOwners = new address[](len);
        unchecked{
            for (uint256 i = 0; i < len; ++i) {
                previousOwners[i] = pastOwners[pastOwners.length - 1 - i];
            }
        }

        return TorchURI.renderSVG(previousOwners, ownerOf(1));
    }

    function getHTML() public view returns (string memory) {
        uint256 len = pastOwners.length > 100 ? 100 : pastOwners.length;
        
        address[] memory previousOwners = new address[](len);
        unchecked{
            for (uint256 i = 0; i < len; ++i) {
                previousOwners[i] = pastOwners[pastOwners.length - 1 - i];
            }
        }
        
        return TorchURI.renderHTML(passAmt, previousOwners, ownerOf(1));
    }

    string constant description = "Torch is a social experiment in NFTs. The torch is passed from one owner to the next, increasing in value each time. The torch is a standard ERC721 NFT, but it also has a UI NFT that displays the torch's current owner and value. The UI NFT is minted to the torch's owner each time the torch is passed.";

    function getHTMLJson() public view returns (string memory) {
        return json.formattedMetadataHTML(
            unicode"Torch 🔥",
            description,
            getHTML()
        );
    }

    function getSVGJson() public view returns (string memory) {
        return json.formattedMetadata(
            unicode"Torch 🔥",
            description,
            getSVG()
        );
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if(id == 0) return getHTMLJson();
        if(id == 1) return getSVGJson();
        revert INVALID_TOKEN_ID();        
    }

    // override transferFrom to record past owners (hooked internally by safeTransferFrom)
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public override(ERC721) {
        if (from != address(0) && id == 1) {
            pastOwners.push(from);
        } 
        super.transferFrom(from, to, id);
    }

    function _passSafeTransferFrom(
        address from,
        address to
    ) internal {
        if (from != address(0)) {
            pastOwners.push(from);
        } 
        if(to == address(0)) revert INVALID_RECIPIENT();

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[1] = to;

        delete getApproved[1];

        emit Transfer(from, to, 1);

        if(
            to.code.length != 0 &&
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, 1, "") !=
                ERC721TokenReceiver.onERC721Received.selector
            ) revert UNSAFE_RECIPIENT();
    }

    // we're calling out to external addresses for both the NFT transfer and the ETH, so better to go overkill on reentrancy protection
    function passTorch() public payable nonReentrant {
        if(msg.value != passAmt) revert INCORRECT_PASS_VALUE();

        address from = ownerOf(1);
        // increase the pass amount
        passAmt += 0.001 ether;

        // set aside withdrawable amount (1% of the torch value)
        uint passFee = msg.value / 100;
        withdrawable += passFee;

        // pay existing owner for the NFT
        SafeTransferLib.forceSafeTransferETH(from, msg.value - passFee);
        
        // transfer the NFT
        _passSafeTransferFrom(from, msg.sender);

    }

    // owner can withdraw the accumulated fees
    function withdraw() public onlyOwner {
        uint _withdrawable = withdrawable;
        withdrawable = 0;
        SafeTransferLib.safeTransferETH(msg.sender, _withdrawable);
    }

}
