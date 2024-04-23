// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "hardhat/console.sol";
/*
编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。
TokenBank 有两个方法：
deposit() : 需要记录每个地址的存入数量；
withdraw（）: 用户可以提取自己的之前存入的 token。
*/
contract TokenBank{
    mapping(address => uint256) deposits;
    
    BaseERC20 public erc20;

    constructor (address tokenAddress) {
        erc20 =  BaseERC20(tokenAddress);
    }

    function deposit(uint256 amount) public payable {
        erc20.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function withdraw(uint256 amount) public {
        deposits[msg.sender] -= amount;
        erc20.transfer(msg.sender, amount);
    }
}


contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() {
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * 10 ** 18;
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        address owner = msg.sender;

        _transfer(owner, _to, _value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // get spender
        address _spender = msg.sender;
       
        // update spender allowance
        _updateSpenderAllowance(_from, _spender, _value);

        // update origin owner 's balance
        _transfer(_from, _to, _value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function _updateSpenderAllowance(address owner, address spender, uint256 value) internal {
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= value, "ERC20: transfer amount exceeds allowance");

        _approve(owner, spender, currentAllowance - value);
    }

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        address _owner = msg.sender;
        _approve(_owner,_spender, _value);

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _approve(address owner, address spender,uint256 value) internal {
        allowances[owner][spender] = value;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        // 允许任何人查看一个地址可以从其它账户中转账的代币数量（allowance）
        return allowances[_owner][_spender];
    }

    function _transfer(address from, address to, uint256 value) internal {
        uint256 amount = balances[from];
        require(amount >= value, "ERC20: transfer amount exceeds balance");
        
        if (from == address(0)) {
            // 如果是零地址，总供应量增加
            totalSupply += value;
        } else {
            uint256 fromBalance = balances[from];
            require(fromBalance >= value, "ERC20: transfer amount exceeds balance");
            balances[from] -= value;
        }

        if (to == address(0)) {
            // 如果是零地址，总供应量减少
            totalSupply -= value;
        } else {
            balances[to] += value;
        }
    }
}