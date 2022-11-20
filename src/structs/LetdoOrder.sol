// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct LetdoOrder {
    string encryptedDeliveryAddress;
    uint256 amount;
    uint256 quantity;
    uint256 itemId;
    address buyer;
}
