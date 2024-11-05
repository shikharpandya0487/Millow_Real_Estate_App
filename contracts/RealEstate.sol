// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// Third party lib to create contract quickly
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract RealEstate is ERC721URIStorage {
    using Counters for Counters.Counter;   
    // This will allow us to make ERC721 make it enumerable
    Counters.Counter private _tokenIds;

    // settings configuration 
    constructor() ERC721("Real Estate", "REAL") {}

    // mint function which will let us create the contracts from scratch
    // tokenURI -> meta data
    function mint(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);  // internal minting function
        _setTokenURI(newItemId, tokenURI);  

        return newItemId;
    }

    // override the supply function to see how many nfts have been recently minted
    function totalSupply() public view returns (uint256) {
        return _tokenIds.current(); // Added missing semicolon here
    }
}
