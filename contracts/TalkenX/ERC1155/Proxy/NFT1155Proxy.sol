// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./NFT1155Core.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

contract NFT1155Proxy is NFT1155Core, IERC1155Receiver {
    using ERC165Checker for address;

    constructor(address _lzEndpoint) NFT1155Core(_lzEndpoint) {}

    function supportsInterface(bytes4 interfaceId) public view virtual override(NFT1155Core, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }

    function onERC1155Received(
        address _operator,
        address,
        uint,
        uint,
        bytes memory
    ) public virtual override returns (bytes4) {
        // only allow `this` to tranfser token from others
        if (_operator != address(this)) return bytes4(0);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address _operator,
        address,
        uint[] memory,
        uint[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        // only allow `this` to tranfser token from others
        if (_operator != address(this)) return bytes4(0);
        return this.onERC1155BatchReceived.selector;
    }
}
