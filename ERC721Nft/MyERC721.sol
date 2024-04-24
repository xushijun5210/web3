// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC721 is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // 定义 NFT 集合
    // mapping(uint256 => NFT) public _nftCollection;
    // 定义 Token 余额映射
    mapping(address => uint256) public tokenBalances;
    // 定义 NFT 所有者映射
    mapping(uint256 => address) public nftOwners;

    constructor() ERC721(unicode"MyNft", "mynft") {}

    //  QmZNFPwox146ohY93ViFD8omSThRAVYF1A96MNHbWoa2Nr

    // ipfs://QmT4YDZ2dgTSpfHwPndnSuvHrAXNvtDBKNDUwN8nuZiVHT
    function mint(address admin, string memory tokenURI)
        public
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(admin, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }
}