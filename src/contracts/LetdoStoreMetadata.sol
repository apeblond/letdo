// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract LetdoStoreMetadata {
    string public storeName;
    address public storeOwner;
    address public storeCurrencyERC20;

    error NotOwner();

    modifier onlyStoreOwner() {
        if (msg.sender != storeOwner) revert NotOwner();
        _;
    }
}
