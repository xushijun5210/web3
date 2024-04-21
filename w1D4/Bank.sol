//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Bank {
    //1.可以通过 Metamask 等钱包直接给 Bank 合约地址存款
    //2.在 Bank 合约你几率每个地址的存款金额
    //3.编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
    //4.用数组记录存款金额的前 3 名用户
    mapping(address => uint) public deposits; // 存储每个地址的存款金额
    address public  admin; // 管理员地址
    address[] public topAdress;// 存储所有的地址
    address[] public topThreeAdress;// 存储前3个地址的存款金额
      // 构造函数，设置管理员地址
    constructor(address _newOwner) {
        admin = _newOwner;
    }
    modifier onlyOwner() {
        require(msg.sender == admin, "only admin can withdraw");
        _;
    }
   //仅管理员可以通过该方法提取资金。
    function withdraw(uint amount) public virtual onlyOwner {
        require(admin==msg.sender,"only admin can withdraw");
        //金额不够
        require(admin.balance>=amount,"amount not enouth");
        payable(msg.sender).transfer(amount);
    }
     // 存款函数，允许用户通过 Metamask 等钱包直接向合约地址存款
     //通过 Metamask 等钱包直接给 Bank 合约地址存款
    //  function deposit() public payable virtual {
    //     require(msg.value>0,"deposit amount must > 0");
    //     deposits[msg.sender] += msg.value;
        
    // }
     function deposit() public payable virtual {
       deposits[msg.sender] = deposits[msg.sender] + msg.value;
       updateSortDeposits(msg.sender);
    }

    //对存储每个地址的存款金额大小进行排序
    function updateSortDeposits(address  newSender) internal {
        for(uint i=0;i<topAdress.length;i++){
            for(uint j=0;j<topAdress.length;j++){
                if(newSender.balance < topAdress[j].balance){
                      address temp = topAdress[j];
                      topAdress[j] = topAdress[i];
                      topAdress[i] = temp;
                }
            }
        }
        //获取数组的前3个
        for (uint i = 0; i < 3; i++) {
            topThreeAdress[i] = topAdress[i];
        }
    }
    //获取排名靠前的账号
    function getTopUser() public view returns (address[] memory) {
        return topThreeAdress;
    }
    receive() external payable {
        deposit();
    }
    fallback() external payable {}
}