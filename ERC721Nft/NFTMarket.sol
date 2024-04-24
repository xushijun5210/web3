// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract  NFTMarket {
    mapping(address => mapping(uint256 => uint256)) public priceOf;
    mapping(address => mapping(uint256 => address)) public owner;

    function list(
        address _nftToken,
        uint256 _tokenId,
        uint256 _tokenPrice
    ) external  {
        require(IERC721(_nftToken).ownerOf(_tokenId) == msg.sender);
        priceOf[_nftToken][_tokenId] = _tokenPrice;
        owner[_nftToken][_tokenId] = msg.sender;
    }

    function buy(
        address _nftToken,
        address _erc20Token,
        uint256 _tokenId
    ) external {
        uint256 price = priceOf[_nftToken][_tokenId];
        address erc20Receive = owner[_nftToken][_tokenId];
        require(erc20Receive != address(0));

        priceOf[_nftToken][_tokenId] = 0;
        owner[_nftToken][_tokenId] = address(0);

        bool success = ERC20(_erc20Token).transferFrom(
            msg.sender,
            erc20Receive,
            price
        );
        if (success) {
            IERC721(_nftToken).safeTransferFrom(
                erc20Receive,
                msg.sender,
                _tokenId,
                new bytes(0)
            );
        }
    }
}