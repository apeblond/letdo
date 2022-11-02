// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor() ERC20("Test", "TEST") {}

    function mint(uint256 amount) external {
        _mint(msg.sender, amount * 10**uint256(decimals()));
    }
}
