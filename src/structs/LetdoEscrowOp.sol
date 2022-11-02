// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct LetdoEscrowOp {
    address sender;
    uint256 amount;
    uint256 timestamp;
    bool locked;
}
