// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./LetdoStoreMetadata.sol";
import "../structs/LetdoEscrowOp.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LetdoEscrowStoreMetadata is LetdoStoreMetadata {
    uint256 constant MAX_STORE_TIME = 90 days;
    mapping(uint256 => LetdoEscrowOp) _ops; // id => op
    uint256 _availableCurrencyToken;

    error NotEnoughFunds();
    error OpAlreadyFinished();

    function _beginEscrow(uint256 orderId, uint256 amount) internal {
        IERC20 token = IERC20(storeCurrencyERC20);
        if (token.balanceOf(msg.sender) < amount) revert NotEnoughFunds();
        token.transferFrom(msg.sender, address(this), amount);
        LetdoEscrowOp memory op = LetdoEscrowOp(
            msg.sender,
            amount,
            block.timestamp,
            false
        );
        _ops[orderId] = op;
    }

    function _returnFundsEscrow(uint256 escrowOpId) internal {
        LetdoEscrowOp memory op = _ops[escrowOpId];
        if (op.completed) revert OpAlreadyFinished();
        IERC20 token = IERC20(storeCurrencyERC20);
        token.transfer(op.sender, op.amount);
        op.completed = true;
        _ops[escrowOpId] = op;
    }

    function _releaseFundsEscrow(uint256 escrowOpId) internal {
        LetdoEscrowOp memory op = _ops[escrowOpId];
        if (op.completed) revert OpAlreadyFinished();
        _availableCurrencyToken += op.amount;
        op.completed = true;
        _ops[escrowOpId] = op;
    }

    function _isOpFinished(uint256 escrowOpId) internal view returns (bool) {
        LetdoEscrowOp memory op = _ops[escrowOpId];
        return op.completed;
    }

    function checkAvailableCurrencyToken() external view returns (uint256) {
        return _availableCurrencyToken;
    }
}
