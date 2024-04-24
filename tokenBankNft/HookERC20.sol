// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface TokenRecipient {
    function tokensReceived(address sender, uint amount) external returns (bool);
}
contract HookERC20 is ERC20 {
    constructor() ERC20("MYDS", "myds") {
        _mint(msg.sender, 1000 * 10 ** 18);
    }
    function transferWithCallback(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);

        if (recipient.code.length > 0 ) {
            bool rv = TokenRecipient(recipient).tokensReceived(msg.sender, amount);
            require(rv, "No tokensReceived");
        }

        return true;
    }
}