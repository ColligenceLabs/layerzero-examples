// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// NOTE: this ONFT contract has no public minting logic.
// must implement your own minting logic in child classes
contract NFT721 is ERC721URIStorage {
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function debitFrom(
        address _from,
        uint16,
        bytes memory,
        uint _tokenId
    ) public {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "NFT721: send caller is not owner nor approved");
        require(ERC721.ownerOf(_tokenId) == _from, "NFT721: send from incorrect owner");
        
        // _transfer(_from, address(this), _tokenId);
        _burn(_tokenId);
    }

    function creditTo(
        uint16,
        address _toAddress,
        uint _tokenId,
        string memory _uri
    ) public {
        require(!_exists(_tokenId) || (_exists(_tokenId) && ERC721.ownerOf(_tokenId) == address(this)));
        if (!_exists(_tokenId)) {
            _safeMint(_toAddress, _tokenId);
            _setTokenURI(_tokenId, _uri);
        } else {
            _transfer(address(this), _toAddress, _tokenId);
        }
    }
}
