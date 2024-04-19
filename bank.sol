//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Bank {
    //1.可以通过 Metamask 等钱包直接给 Bank 合约地址存款
    //2.在 Bank 合约你几率每个地址的存款金额
    //3.编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
    //4.用数组记录存款金额的前 3 名用户
    mapping(address => uint) public deposits; // 存储每个地址的存款金额
    address public admin; // 管理员地址
    address[3] public topThreeAdress;// 存储前3个地址的存款金额
      // 构造函数，设置管理员地址
    constructor() {
        admin = msg.sender;
    }
    // 存款函数，允许用户通过 Metamask 等钱包直接向合约地址存款
     //通过 Metamask 等钱包直接给 Bank 合约地址存款
    receive() external payable {
        require(msg.value>0,"deposit amount must > 0");
        deposits[msg.sender] += msg.value;
        updateSortDeposits(msg.sender);
    }
   //仅管理员可以通过该方法提取资金。
    function withdraw(uint amount) public {
        require(admin==msg.sender,"only admin can withdraw");
        //金额不够
        require(admin.balance>=amount,"amount not enouth");
        payable(msg.sender).transfer(amount);
    }
    //对存储每个地址的存款金额大小进行排序
    function updateSortDeposits(address  newSender) internal {
        if(newSender.balance > topThreeAdress[0].balance){
              topThreeAdress[2] = topThreeAdress[1];
              topThreeAdress[1] = topThreeAdress[0];
              topThreeAdress[0] = newSender;
        }else if (newSender.balance > topThreeAdress[1].balance) {
            topThreeAdress[2] = topThreeAdress[1];
            topThreeAdress[1] = newSender;
        } else if(newSender.balance > topThreeAdress[2].balance) {
            topThreeAdress[2] = newSender;
        }
    }
    fallback() external payable {}
}