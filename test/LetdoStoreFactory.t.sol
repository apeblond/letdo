// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/contracts/LetdoStoreFactory.sol";
import "../src/contracts/LetdoStore.sol";
import "./TestERC20.sol";

contract LetdoStoreTest is Test {
    address public storeOwner = address(1);
    LetdoStoreFactory public factory;

    function setUp() public {
        vm.startPrank(storeOwner);
        factory = new LetdoStoreFactory(address(new TestERC20()));
        vm.stopPrank();
    }

    function testStoreCreation() public {
        assertEq(factory.allStoresLength(), 0);
        vm.startPrank(storeOwner);
        address createdStore = factory.createStore(
            "Test",
            "YItnQSip5+5vXVgcablSxSb5RuQEgQPNULJRw2T7OAs="
        );
        vm.stopPrank();
        assertFalse(createdStore == address(0));
        assertEq(factory.allStoresLength(), 1);
        assertEq(factory.allStores(0), createdStore);
    }

    function testCreateMultipleStores() public {
        testStoreCreation();
        vm.startPrank(storeOwner);
        address createdStore = factory.createStore(
            "Test",
            "YItnQSip5+5vXVgcablSxSb5RuQEgQPNULJRw2T7OAs="
        );
        assertEq(factory.allStoresLength(), 2);
        assertEq(factory.allStores(1), createdStore);
        vm.stopPrank();
    }

    function testFailStoreCreationWithEmptyString() public {
        assertEq(factory.allStoresLength(), 0);
        factory.createStore("", "");
    }

    function testOwnerIsSetByFactory() public {
        testStoreCreation();
        LetdoStore store = LetdoStore(factory.allStores(0));
        assertFalse(store.storeOwner() != storeOwner);
    }
}
