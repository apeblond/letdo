// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/contracts/LetdoStore.sol";
import "../src/structs/LetdoItem.sol";
import "../src/structs/LetdoOrder.sol";
import "./TestERC20.sol";

contract LetdoStoreTest is Test {
    LetdoStore public store;
    TestERC20 public currency;
    address public storeOwner = address(1);
    address public buyer = address(2);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
        vm.startPrank(storeOwner);
        currency = new TestERC20();
        store = new LetdoStore("Test store", address(currency));
        vm.stopPrank();
        vm.startPrank(buyer);
        currency.mint(1000 * 10**uint256(currency.decimals()));
        currency.approve(address(store), type(uint256).max);
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
        vm.expectRevert(LetdoStore.IdNotFound.selector);
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

    function testPurchase() public {
        testAddInventoryItem();
        vm.startPrank(buyer);
        uint256 orderId = store.purchase(0, 1, "ajsghajkshgkjaghjakghakjghkaj");
        vm.stopPrank();
        LetdoOrder memory order = store.getOrder(orderId);
        assertEq(buyer, order.buyer);
        assertEq(50, order.amount);
        assertEq(
            "ajsghajkshgkjaghjakghakjghkaj",
            order.encryptedDeliveryAddress
        );
        assertEq(0, order.itemId);
    }

    function testSetPurchaseAsReceivedWithPositiveReview() public {
        testPurchase();
        vm.startPrank(address(1000));
        vm.expectRevert(LetdoStore.InvalidBuyer.selector);
        store.setPurchaseAsReceived(0, true);
        vm.stopPrank();
        vm.startPrank(buyer);
        assertEq(0, store.checkAvailableCurrencyToken());
        store.setPurchaseAsReceived(0, true);
        assertEq(50, store.checkAvailableCurrencyToken());
        assertEq(1, store.getStoreReviews()[0]);
        assertEq(0, store.getStoreReviews()[1]);
        vm.expectRevert(LetdoStore.OrderAlreadyCompleted.selector);
        store.setPurchaseAsReceived(0, true);
        vm.stopPrank();
    }

    function testSetPurchaseAsReceivedWithNegativeReview() public {
        testPurchase();
        vm.startPrank(buyer);
        assertEq(0, store.checkAvailableCurrencyToken());
        store.setPurchaseAsReceived(0, false);
        assertEq(50, store.checkAvailableCurrencyToken());
        assertEq(0, store.getStoreReviews()[0]);
        assertEq(1, store.getStoreReviews()[1]);
        vm.stopPrank();
    }

    function testSetPurchaseAsNotReceived() public {
        testPurchase();
        vm.startPrank(address(10000));
        vm.expectRevert(LetdoStore.InvalidBuyer.selector);
        store.setPurchaseAsNotReceived(0);
        vm.stopPrank();
        vm.startPrank(buyer);
        vm.expectRevert(LetdoStore.ActionNotAvailable.selector);
        store.setPurchaseAsNotReceived(0);
        vm.warp(block.timestamp + 61 days);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(store), buyer, 50);
        store.setPurchaseAsNotReceived(0);
        assertEq(0, store.getStoreReviews()[0]);
        assertEq(1, store.getStoreReviews()[1]);
        assertEq(0, store.checkAvailableCurrencyToken());
        vm.stopPrank();
    }

    function testSetPurchaseAsNotReceivedAfter90Days() public {
        testPurchase();
        vm.startPrank(buyer);
        vm.expectRevert(LetdoStore.ActionNotAvailable.selector);
        store.setPurchaseAsNotReceived(0);
        vm.warp(block.timestamp + 91 days);
        vm.expectRevert(LetdoStore.ActionNotAvailable.selector);
        store.setPurchaseAsNotReceived(0);
        vm.stopPrank();
    }
}
