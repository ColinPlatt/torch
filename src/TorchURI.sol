// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LibString} from "lib/solady/src/Milady.sol";

import {jsonRPCProvider as jsonProvider, BrowserProvider as mmProvider} from "./utils/libBrowserProvider.sol";
import {HTML} from "lib/ethers.sol/src/utils/HTML.sol";

library TorchURI {

    function renderSVG(address[] memory previousOwners, address currentOwner) internal pure returns (string memory) {

        string memory svg = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 360 580">',
            '<defs><mask id="text-mask"><rect x="0" y="70" width="360" height="570" fill="white"/></mask></defs><style>text{font-family:monospace;font-size:12px; fill: #fff;}</style>',
            '<style type="text/css"><![CDATA[@keyframes scroll{0%{transform:translateY(100%);}100%{transform:translateY(-300%);}}#scrolling-text{animation:scroll 45s linear infinite;font-family:monospace;fill:white;font-size:12px;text-anchor:left;}]]></style>',
            '<rect width="360" height="580" rx="15" ry="15" fill="black"/>',
            '<text x="15" y="20">Current Owner: </text>', 
            '<text x="20" y="35">',
            LibString.toHexStringChecksummed(currentOwner),
            '</text><text x="15" y="55" fill="#fff">Previous Owners:</text><g mask="url(#text-mask)"><g id="scrolling-text">'
        ));

        uint256 y = 70;
        for (uint256 i = 0; i < previousOwners.length; i++) {
            svg = string(abi.encodePacked(
                svg,
                '<text x="20" y="',
                LibString.toString(y),
                '">',
                LibString.toHexStringChecksummed(previousOwners[i]),
                '</text>'
            ));
            y += 15;
        }

        svg = string(abi.encodePacked(
            svg,
            '</g></g></svg>'
        ));

        return svg;
    }

    function _getScript() internal pure returns (string memory) {
        return HTML.script(string.concat(
            'document.addEventListener("DOMContentLoaded", function() {var connectButton = document.getElementById("connectButton");connectButton.addEventListener("click", async function() {'
            'const provider = await connectWallet();',
            'if (provider) {await ',
            mmProvider.ethereum_request(mmProvider.eth_accounts()),
            '.then(async function (accounts) { if (accounts.length === 0) { ',
            'ethereum.enable().then(function (accounts) { console.log(accounts); }).catch(console.error); } else { console.log(accounts); } }).catch(console.error);}',
            '});});',
            mmProvider.connectWallet()
        ));
    }

    function _getBody() internal pure returns (string memory) {
        return HTML.body(string.concat(
            HTML.button('id="connectButton"', "Connect to Wallet"),
            _getScript()
        ));
    }

    function renderHTML() internal pure returns (string memory) {
        return HTML.html(string.concat(
            HTML.head(string.concat(
                HTML.title("TestSite")
            )),
            _getBody()
        ));
    }
}