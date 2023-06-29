// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LibString} from "lib/solady/src/Milady.sol";

import {jsonRPCProvider as jsonProvider, BrowserProvider as mmProvider} from "./utils/libBrowserProvider.sol";
import {HTML} from "lib/ethers.sol/src/utils/HTML.sol";
import {ExtLibString} from "./utils/utils.sol";

library TorchURI {

    function renderSVG(address[] memory previousOwners, address currentOwner) internal pure returns (string memory) {

        string memory svg = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 360 580" preserveAspectRatio="xMidYMid meet">',
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

    function _getPassFeeDisplay(uint256 _passValue) internal pure returns (string memory) {
        return string.concat(
            'document.getElementById("amount-box").innerHTML = "Pass fee: "+ ', 
            LibString.toString(_passValue),
            ' / 1e18 + " ETH";'
        );
    }

    function _getIframeHandler(uint256 _passValue) internal view returns (string memory) {
        return string.concat(
            'document.addEventListener("DOMContentLoaded", function () {',
                'if (window.self !== window.top) {',
                    'document.getElementById("connect-button").disabled = true; document.getElementById("pass-torch-button").disabled = true;',
                '} else {',
                    _getConnectionButtonLogic(),
                    _getPassTorchButtonLogic(_passValue),
                '}});'
        );
    }

    function _getConnectionButtonLogic() internal view returns (string memory) {
        return string.concat(
                    'var connectButton = document.getElementById("connect-button");var provider;var connectedAccount;connectButton.addEventListener("click", async function() {'
                    'provider = await connectWallet();',
                    'if (provider) {',
                        'await ', mmProvider.ethereum_request(mmProvider.eth_accounts()),'.then(async function (accounts) { ',
                            'if (accounts.length === 0) { ethereum.enable().then(function (accounts) { setDotColor("green"); console.log(accounts);connectedAccount = accounts[0];document.getElementById("connect-button").innerText = "Connected";}).catch(console.error);',
                    ' } else {',
                        ' setDotColor("green"); console.log(accounts);connectedAccount = accounts[0];document.getElementById("connect-button").innerText = "Connected";} ',
                    'await checkAndChangeChain(provider, "', ExtLibString.toMinimalHexString(block.chainid), '");',
                ' }).catch(console.error);}});'
        );
    }

    function _getFormedTansaction(uint256 _passValue) internal view returns (string memory) {

        return string.concat(
            '{',
                'from: connectedAccount,'
                'to: "', LibString.toHexString(address(this)), '",'
                'value: "', ExtLibString.toMinimalHexString(_passValue), '",'
                'data: "', LibString.toHexString(abi.encodeWithSignature("passTorch()")),
            '"}'
        );
    }

    function _getPassTorchButtonLogic(uint256 _passValue) internal view returns (string memory) {
        
        string memory txn = _getFormedTansaction(_passValue);

        return string.concat(
            'var passButton = document.getElementById("pass-torch-button");',
            'passButton.addEventListener("click", async function() {',
                'if(connectedAccount == undefined) {alert("Please connect your wallet first");}',
                'const gasEstimate = await ', mmProvider.ethereum_request(jsonProvider.eth_estimateGas(txn, jsonProvider.blockTag.latest)), ';',
                'const txnHash = await ', mmProvider.ethereum_request(jsonProvider.eth_sendTransaction(txn)), ';',
                'const receipt = await new Promise((resolve) => {const interval = setInterval(async () => { const receipt = await ', 
                mmProvider.ethereum_request(jsonProvider.eth_getTransactionReceipt(string("txnHash"))),
                '; if (receipt) { clearInterval(interval); resolve(receipt); }}, 5000); });',
                'alert("Transaction complete! You can view it here: https://goerli.etherscan.io/tx/" + txnHash);',
            '});'
        );
    }

    function _getScript(uint256 _passValue) internal view returns (string memory) {
        return HTML.script(string.concat(
            'function setDotColor(e) {document.querySelector(".connection-dot").style.backgroundColor = e}',
            _getPassFeeDisplay(_passValue),
            _getIframeHandler(_passValue),
            mmProvider.connectWallet(),
            mmProvider.checkAndChangeChain()
        ));
    }

    function _getCSS() internal pure returns (string memory) {
        return ':root{--text-color:#ffffff;--button-margin:5px;--title-bar-shadow:0 10px 10px 0px rgba(70, 80, 90, 1);--body-container-padding:20px;--box-padding:15px;--box-margin:15px;--box-border-radius:15px;--box-shadow:0px 0px 10px 10px rgba(70, 80, 90, 1);--box-width:400px}body{background-color:#1c2833;color:var(--text-color);font-family:monospace}button{background-color:#67676d;color:var(--text-color);border:inset 1px #ffffffb3 1px 1px;padding:8px;border-radius:5px;font-family:var(--font-family);font-size:14px;font-weight:600px;cursor:pointer}.title-bar{display:flex;justify-content:space-between;align-items:center;padding:0 var(--body-container-padding);margin-left:-10px;margin-right:-10px;box-shadow:var(--title-bar-shadow)}.connection-dot{height:10px;width:10px;background-color:red;border-radius:50%;display:inline-block;margin-right:5px}.body-container{display:flex;flex-direction:column;padding:var(--body-container-padding)}.box{padding:var(--box-padding);margin:var(--box-margin);border-radius:var(--box-border-radius)}.box-inner{width:var(--box-width);box-shadow:var(--box-shadow)}.column{display:flex;flex-direction:column;justify-content:top;align-items:center}#pass-torch-button{margin-top:var(--button-margin);margin-bottom:var(--button-margin)}#svg-box{height:650px;width:420px;padding:var(--body-container-padding);box-sizing:border-box}#info-box{width:var(--box-width);height:495px;box-shadow:var(--box-shadow)}@media (min-aspect-ratio:1/1) and (min-width:975px){.body-container{flex-direction:row}.column{width:50%}}';
    }

    function _getBody(uint256 _passValue, address[] memory previousOwners, address currentOwner) internal view returns (string memory) {
        return HTML.body(string.concat(
            '<div class="title-bar"><h1>Torch &#128293;</h1><div><span class="connection-dot"></span><button id="connect-button">Connect Wallet</button></div></div><div class="body-container"><div class="column"><div class="box box-inner"><div id="pass-box"><button id="pass-torch-button">Pass Torch</button><div id="amount-box"></div></div></div>',
            '<div class="box box-inner" id="info-box"><h3>About Torch &#128293;</h3><br><p>Torch &#128293; is a unique NFT that can be passed from the current holder to anyone for 0.0001 ETH more than the price paid by the current owner.</p><p>Inspired by the 2019 Bitcoin Lightning Torch, which saw hundreds of users pass a virtual torch around the globe, Torch is fully automated, trustless, and intended to be a piece of art demonstrating web3 enabled onchain websites.</p><p>Torch is a fully onchain SVG, showing the last 100 owners of the Torch. It uses an onchain webpage to allow users to interact with it.</p><p>Each transfer is subject to a 1% pass fee tax, which is claimable by the deployer of the Torch.</p><br><p>NOTE: There is no roadmap, and users of Torch understand and agree that there is no plan to profit from it. The contracts have not been audited, and users assume full responsibility for any loss.</p></div></div>',
            '<div class="column"><div class="box box-inner" id="svg-box">',
            renderSVG(previousOwners, currentOwner),
            '</div></div></div>',
            _getScript(_passValue)
        ));
    }

    function renderHTML(uint256 passValue, address[] memory previousOwners, address currentOwner) internal view returns (string memory) {
        return HTML.html(string.concat(
            HTML.head(string.concat(
                '<script src="http://livejs.com/live.js"></script>',
                HTML.title("Torch - Interface"),
                HTML.style(_getCSS())
            )),
            _getBody(passValue, previousOwners, currentOwner)
        ));
    }
}