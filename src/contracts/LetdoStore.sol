// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./LetdoEscrowStoreMetadata.sol";
import "../structs/LetdoItem.sol";
import "../structs/LetdoOrder.sol";

contract LetdoStore is LetdoEscrowStoreMetadata {
    LetdoItem[] _inventory;
    mapping(uint256 => LetdoOrder) _orders;
    uint256 _orderCounter;
    uint256[2] _reviews; // [0] positive reviews, [1] negative reviews

    error IdNotFound();
    error ItemNotAvailable();
    error InvalidItemAmount();
    error InvalidBuyer();
    error OrderAlreadyCompleted();

    event OrderCreated(
        address indexed buyer,
        uint256 orderId,
        uint256 amount,
        uint256 itemId
    );

    constructor(string memory _storeName, address _storeCurrencyERC20) {
        storeName = _storeName;
        storeOwner = msg.sender;
        storeCurrencyERC20 = _storeCurrencyERC20;
    }

    modifier onlyExistingItem(uint256 id) {
        if (id > _inventory.length - 1) revert IdNotFound();
        _;
    }

    modifier onlyExistingOrder(uint256 id) {
        if (id > _orderCounter - 1) revert IdNotFound();
        _;
    }

    modifier onlyBuyerOfOrder(uint256 id) {
        LetdoOrder memory order = getOrder(id);
        if (order.buyer != msg.sender) revert InvalidBuyer();
        _;
    }

    modifier onlyEscrowNotCompleted(uint256 id) {
        if (_isOpFinished(id)) revert OrderAlreadyCompleted();
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

    function getOrder(uint256 id)
        public
        view
        onlyExistingOrder(id)
        returns (LetdoOrder memory)
    {
        return _orders[id];
    }

    function getStoreReviews() external view returns (uint256[2] memory) {
        return _reviews;
    }

    function purchase(
        uint256 itemId,
        uint256 quantity,
        string memory encryptedDeliveryAddress
    ) external onlyExistingItem(itemId) returns (uint256) {
        if (quantity == 0) revert InvalidItemAmount();
        LetdoItem memory item = getInventoryItem(itemId);
        _beginEscrow(_orderCounter, item.price * quantity);
        _orders[_orderCounter] = LetdoOrder(
            encryptedDeliveryAddress,
            item.price * quantity,
            itemId,
            msg.sender
        );

        emit OrderCreated(
            msg.sender,
            _orderCounter,
            item.price * quantity,
            itemId
        );

        _orderCounter++;

        return _orderCounter - 1;
    }

    function setPurchaseAsReceived(uint256 orderId, bool positiveVote)
        external
        onlyBuyerOfOrder(orderId)
        onlyEscrowNotCompleted(orderId)
    {
        if (positiveVote) {
            _reviews[0] += 1;
        } else {
            _reviews[1] += 1;
        }

        _releaseFundsEscrow(orderId);
    }
}
