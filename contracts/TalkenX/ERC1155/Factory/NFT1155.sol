// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

// NOTE: this ONFT contract has no public minting logic.
// must implement your own minting logic in child classes
contract NFT1155 is ERC1155URIStorage {
    string private name_;
    string private symbol_;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC1155(_uri) {
        name_ = _name;
        symbol_ = _symbol;
    }

    function name() public view returns (string memory) {
        return name_;
    }

    function symbol() public view returns (string memory) {
        return symbol_;
    }

    function setURI(uint256 tokenId, string memory tokenURI) public {
        _setURI(tokenId, tokenURI);
    }

    function setBaseURI(string memory baseURI) public {
        _setBaseURI(baseURI);
    }

    function debitFrom(
        address _from,
        uint16,
        bytes memory,
        uint[] memory _tokenIds,
        uint[] memory _amounts
    ) public {
        address spender = _msgSender();
        require(spender == _from || isApprovedForAll(_from, spender), "NFT1155: send caller is not owner nor approved");
        _burnBatch(_from, _tokenIds, _amounts);
    }

    function creditTo(
        uint16,
        address _toAddress,
        uint[] memory _tokenIds,
        uint[] memory _amounts
    ) public {
        _mintBatch(_toAddress, _tokenIds, _amounts, "");
    }
}
