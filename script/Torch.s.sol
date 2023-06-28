// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "src/Torch.sol";

contract TorchScript is Script {
    Torch public nft;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
            nft = new Torch();
        vm.stopBroadcast();
    }
}

//forge script script/Torch.s.sol:TorchScript --rpc-url $RPC_URL_GOERLI --broadcast --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY --chain 5 --slow --verify -vvvv