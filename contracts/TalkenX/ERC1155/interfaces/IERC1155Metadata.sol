// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC1155Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function setURI(uint tokenId, string memory tokenURI) external;

    function setBaseURI(string memory baseURI) external;
}
