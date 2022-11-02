// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/contracts/LetdoStore.sol";
import "../src/structs/LetdoItem.sol";

contract LetdoStoreTest is Test {
    LetdoStore public store;
    address public storeOwner = address(1);

    function setUp() public {
        vm.startPrank(storeOwner);
        store = new LetdoStore("Test store");
        vm.stopPrank();
    }

    function testStoreCreation() public {
        assertEq("Test store", store.storeName());
        assertEq(storeOwner, store.storeOwner());
        assertEq(store.inventoryLength(), 0);
    }

    function testAddInventoryItem() public {
        vm.startPrank(storeOwner);
        store.addInventoryItem(
            "ipfs://QmbtiPZfgUzHd79T1aPcL9yZnhGFmzwar7h4vmfV6rV8Kq",
            50
        );
        assertEq(store.inventoryLength(), 1);
        vm.stopPrank();
    }

    function testGetInventoryItem() public {
        testAddInventoryItem();
        LetdoItem memory item = store.getInventoryItem(0);
        assertEq(
            "ipfs://QmbtiPZfgUzHd79T1aPcL9yZnhGFmzwar7h4vmfV6rV8Kq",
            item.metadataURI
        );
        assertEq(50, item.price);
        assertTrue(item.available);
    }

    function testGetNonExistantInventoryItem() public {
        testAddInventoryItem();
        vm.expectRevert(LetdoStore.ItemNotFound.selector);
        store.getInventoryItem(10);
    }

    function testGetDisabledInventoryItem() public {
        testAddInventoryItem();
        vm.startPrank(storeOwner);
        store.toggleInventoryItemAvailability(0);
        vm.expectRevert(LetdoStore.ItemNotAvailable.selector);
        store.getInventoryItem(0);
        vm.stopPrank();
    }
}
