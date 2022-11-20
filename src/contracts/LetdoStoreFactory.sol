// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./LetdoStore.sol";

contract LetdoStoreFactory {
    address[] public allStores;

    event StoreCreated(address store, address indexed owner);

    address public storesCurrencyERC20;

    error EmptyString();

    constructor(address _storesCurrencyERC20) {
        require(_storesCurrencyERC20 != address(0));
        storesCurrencyERC20 = _storesCurrencyERC20;
    }

    function allStoresLength() external view returns (uint256) {
        return allStores.length;
    }

    function createStore(
        string calldata storeName,
        string calldata storePublicKey
    ) external returns (address) {
        if (bytes(storeName).length == 0 || bytes(storePublicKey).length == 0)
            revert EmptyString();

        bytes32 salt = keccak256(
            abi.encodePacked(allStores.length, msg.sender)
        );

        address newStoreAddress = address(
            new LetdoStore{salt: salt}(
                storeName,
                msg.sender,
                storesCurrencyERC20,
                storePublicKey
            )
        );

        allStores.push(newStoreAddress);

        emit StoreCreated(newStoreAddress, msg.sender);

        return newStoreAddress;
    }
}
