// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./LetdoStoreMetadata.sol";
import "../structs/LetdoEscrowOp.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LetdoEscrowStoreMetadata is LetdoStoreMetadata {
    uint256 constant MAX_STORE_TIME = 90 days;
    uint256 constant THRESHOLD_NOT_RECEIVED = 60 days;
    mapping(uint256 => LetdoEscrowOp) _ops; // id => op
    uint256 _availableCurrencyToken;

    error NotEnoughFunds();
    error OpAlreadyFinished();

    event AvailableFundsForWithdraw(uint256 amount);

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

    function _returnFundsEscrow(uint256 orderId) internal {
        LetdoEscrowOp memory op = _ops[orderId];
        if (op.completed) revert OpAlreadyFinished();
        IERC20 token = IERC20(storeCurrencyERC20);
        token.transfer(op.sender, op.amount);
        op.completed = true;
        _ops[orderId] = op;
    }

    function _releaseFundsEscrow(uint256 orderId) internal {
        LetdoEscrowOp memory op = _ops[orderId];
        if (op.completed) revert OpAlreadyFinished();
        _availableCurrencyToken += op.amount;
        emit AvailableFundsForWithdraw(op.amount);
        op.completed = true;
        _ops[orderId] = op;
    }

    function _isOpFinished(uint256 orderId) internal view returns (bool) {
        LetdoEscrowOp memory op = _ops[orderId];
        return op.completed;
    }

    function _canBeSetAsNotReceived(uint256 orderId)
        internal
        view
        returns (bool)
    {
        LetdoEscrowOp memory op = _ops[orderId];
        if (
            !op.completed &&
            block.timestamp > op.timestamp + THRESHOLD_NOT_RECEIVED &&
            block.timestamp < op.timestamp + MAX_STORE_TIME
        ) {
            return true;
        }

        return false;
    }

    function checkAvailableCurrencyToken() external view returns (uint256) {
        return _availableCurrencyToken;
    }
}
