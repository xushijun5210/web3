// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HookERC20.sol";

interface T {
    function tokensReceived(address sender, uint amount) external returns (bool);
}
contract HookTokenBank is HookERC20 {
    mapping(address => uint256) deposits;
    address public token;

    constructor(address addr){
        token = addr;
    }

    function deposit(uint256 amount) public {
        HookERC20(token).transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function withdraw(uint256 amount) public {
        HookERC20(token).transfer(msg.sender, amount);
        deposits[msg.sender] -= amount;
    }

    // tokensReceived 回调实现
    function tokenReceived(address recipient, uint256 amount) external returns (bool) {
        // 只有合约才能调用
        require(msg.sender == token, "no permission");
        deposits[recipient] += amount;
        return true;
    }
}