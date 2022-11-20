// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/contracts/LetdoStoreFactory.sol";

contract LetdoScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new LetdoStoreFactory(0x9D233A907E065855D2A9c7d4B552ea27fB2E5a36); // Deploying it with Goerli DAI
        vm.stopBroadcast();
    }
}
