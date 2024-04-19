//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Bank {
    //1.可以通过 Metamask 等钱包直接给 Bank 合约地址存款
    //2.在 Bank 合约你几率每个地址的存款金额
    //3.编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
    //4.用数组记录存款金额的前 3 名用户
    mapping(address => uint) public deposits; // 存储每个地址的存款金额
    address admin; // 管理员地址
    address[] public topThreeAdress;// 存储前3个地址的存款金额
    uint[3] public topThreeDeposits;
    address[3] public  topThreeAddr;
      // 构造函数，设置管理员地址
    constructor() {
        admin = msg.sender;
    }
    // 存款函数，允许用户通过 Metamask 等钱包直接向合约地址存款
     //通过 Metamask 等钱包直接给 Bank 合约地址存款
    receive() external payable {
        require(msg.value>0,"deposit amount must > 0");
        deposits[msg.sender] += msg.value;
        updateSortDeposits(msg.sender, msg.value);
    }
   //仅管理员可以通过该方法提取资金。
    function withdraw(uint amount) public {
        require(admin==msg.sender,"only admin can withdraw");
        //金额不够
        require(admin.balance>=amount,"amount not enouth");
        payable (address(this)).transfer(amount);
    }
    //对存储每个地址的存款金额大小进行排序
    function updateSortDeposits(address depositor,uint amount) internal{
        for (uint i=0; i<topThreeDeposits.length; i++) {
            if (amount > topThreeDeposits[i]) {
                for (uint j = topThreeDeposits.length - 1; j > i; j--) {
                    topThreeDeposits[j] = topThreeDeposits[j-1];
                    topThreeDeposits[j] = topThreeDeposits[j-1];
        for(uint i=0;i<topThreeAddr.length;i++){
            if (amount > deposits[topThreeAddr[i]]){
                for (uint j=topThreeAddr.length-1; j>i; j--) {
                    topThreeAddr[j] = topThreeAddr[j-1];
                }
                topThreeDeposits[i] = depositor;
                topThreeDeposits[i] = amount;
                topThreeAddr[i] = depositor;
                break ;
            }
        }
    }

}