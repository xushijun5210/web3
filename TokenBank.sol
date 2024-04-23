// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。
TokenBank 有两个方法：
deposit() : 需要记录每个地址的存入数量；
withdraw（）: 用户可以提取自己的之前存入的 token。
*/
contract TokenBank{
    BaseERC20 private token;

    address public tokenAddress;

    uint public balance;

    mapping(address => uint) public balances;

     constructor(address _tokenAddress){
        token = BaseERC20(_tokenAddress);
        tokenAddress = _tokenAddress;
    }
    //定义事件
    event Deposited(address _from, address _to, uint _value);
    //定义事件
    event Withdrawed(address _from, address _to, uint _value);
    //存
    function deposit(uint256 _value) public{

        /*1)判断地址的 Token 余额是不是够转账
          2)判断地址可以转账的代币数量
        */
        require(token.balanceOf(msg.sender)>_value,"Insufficient balance");
        require(token.allowance(msg.sender,address(this))>_value,"Insufficient balance");
        //开始转账
        token.transferFrom(msg.sender, address(this), _value);
        emit Deposited(msg.sender, address(this), _value);//触发事件函数
    }
        //取
    function withdraw(uint256 _value) public  {
        //判断
        require(balances[msg.sender] >= _value, "Insufficient balance");
        require(token.balanceOf(address(this)) >= _value, "Bankcrupted");
        //转币
        token.transfer(msg.sender,_value);
        balances[msg.sender] -= _value;
        emit Withdrawed(msg.sender, address(this), _value);
    }
}
contract BaseERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 
    uint256 public totalSupply; 
    mapping (address => uint256) balances;//余额 
    mapping (address => mapping (address => uint256)) allowances; 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    constructor(){
         name = "BaseERC20";
         symbol = "BERC20";
         decimals = 18;
         totalSupply = 100000000 ether;
        balances[msg.sender] = totalSupply;  
    }
    //允许任何人查看任何地址的 Token 余额（balanceOf）
    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        return balances[ _owner];

    }
    // 向 _to 地址转移 _value 数量的代币
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // write your code here
         //转帐超出余额时抛出异常(require),并显示错误消息 “ERC20: transfer amount exceeds balance”。
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        //减去转出余额
        balances[msg.sender] -= _value;
        //加上转如余额
        balances[ _to] += _value;
        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }
    //允许被授权的地址消费他们被授权的 Token 数量（transferFrom）；
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // write your code here
         //转帐超出余额时抛出异常(require)，异常信息：“ERC20: transfer amount exceeds balance”
        require(balances[_from] >=  _value, "ERC20: transfer amount exceeds balance");
        //转帐超出授权数量时抛出异常(require)，异常消息：“ERC20: transfer amount exceeds allowance”。
        require(allowances[_from][msg.sender] >=  _value, "ERC20: transfer amount exceeds allowance");
        balances[_from] -=  _value;
        allowances[_from][msg.sender] -=  _value;
        balances[_to] +=  _value;
        emit Transfer(_from, _to, _value); 
        return true; 
    }
    //允许 Token 的所有者批准某个地址消费他们的一部分Token（approve）
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // write your code here
         //授权额度
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }
    //允许任何人查看一个地址可以从其它账户中转账的代币数量（allowance）
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // write your code here     
         return allowances[_owner][_spender];
    }
}