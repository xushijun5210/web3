// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {Bank} from "./Bank.sol";

interface IBigBank {
    function transferOwner(address owner) external;

    function withdraw(uint256 amount) external;
}

contract Ownable {
    address public admin;
    IBigBank bigBank;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == admin, "only admin can do this call");
        _;
    }

    function setBigBank(IBigBank _bigBank) external {
        bigBank = _bigBank;
    }

    function transferOwner(address newOwner) external onlyOwner {
        bigBank.transferOwner(newOwner);
    }

    function withdrawFromBank(uint amount) external onlyOwner {
        bigBank.withdraw(amount);
    }
}

// 用 Solidity 编写 BigBank 智能合约
contract BigBank is Bank {
    constructor(address _newOwner) Bank(_newOwner) {
        admin = _newOwner;
    }

    // 存款金额 >0.001 ether
    modifier validMinDeposit() {
        require(msg.value >  0.001 ether,"min deposit must great than 0.001 ether");
        _;
    }
    function transferOwner(address _newOwner) external onlyOwner {
        admin = _newOwner;
    }
}