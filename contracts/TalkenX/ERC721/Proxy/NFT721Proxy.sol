// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "./NFT721Core.sol";

contract NFT721Proxy is NFT721Core, IERC721Receiver {
    using ERC165Checker for address;

    constructor(uint _minGasToTransfer, address _lzEndpoint) NFT721Core(_minGasToTransfer, _lzEndpoint) {}

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC721Receiver).interfaceId || super.supportsInterface(interfaceId);
    }

    function onERC721Received(
        address _operator,
        address,
        uint,
        bytes memory
    ) public virtual override returns (bytes4) {
        // only allow `this` to transfer token from others
        if (_operator != address(this)) return bytes4(0);
        return IERC721Receiver.onERC721Received.selector;
    }
}
