// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./LetdoStoreMetadata.sol";
import "../structs/LetdoItem.sol";

contract LetdoStore is LetdoStoreMetadata {
    LetdoItem[] _inventory;

    error ItemNotFound();
    error ItemNotAvailable();

    constructor(string memory _storeName, address _storeCurrencyERC20) {
        storeName = _storeName;
        storeOwner = msg.sender;
        storeCurrencyERC20 = _storeCurrencyERC20;
    }

    modifier onlyExistingItem(uint256 id) {
        if (id > _inventory.length - 1) revert ItemNotFound();
        _;
    }

    function addInventoryItem(string calldata metadataURI, uint256 price)
        external
        onlyStoreOwner
    {
        _inventory.push(LetdoItem(metadataURI, price, true));
    }

    function toggleInventoryItemAvailability(uint256 id)
        external
        onlyStoreOwner
        onlyExistingItem(id)
    {
        LetdoItem memory item = getInventoryItem(id);
        item.available = !item.available;
        _inventory[id] = item;
    }

    function inventoryLength() external view returns (uint256) {
        return _inventory.length;
    }

    function getInventoryItem(uint256 id)
        public
        view
        onlyExistingItem(id)
        returns (LetdoItem memory)
    {
        LetdoItem memory item = _inventory[id];
        if (!item.available) revert ItemNotAvailable();
        return item;
    }
}
