// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./LetdoStoreMetadata.sol";
import "../structs/LetdoEscrowOp.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LetdoEscrowStoreMetadata is LetdoStoreMetadata {
    uint256 constant MAX_STORE_TIME = 90 days;
    mapping(uint256 => LetdoEscrowOp) ops; // id => op
    uint256 op_counter;

    error NotEnoughFunds();

    function beginEscrow(uint256 amount) internal {
        IERC20 token = IERC20(storeCurrencyERC20);
        if (token.balanceOf(msg.sender) < amount) revert NotEnoughFunds();
        token.transferFrom(msg.sender, address(this), amount);
        LetdoEscrowOp memory op = LetdoEscrowOp(
            msg.sender,
            amount,
            block.timestamp,
            true
        );
        ops[op_counter] = op;
        op_counter++;
    }
}
