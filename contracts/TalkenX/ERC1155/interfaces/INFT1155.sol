// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./INFT1155Core.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 * @dev Interface of the ONFT standard
 */
interface INFT1155 is INFT1155Core, IERC1155 {
    function setURI(uint tokenId, string memory tokenURI) external;

    function setBaseURI(string memory baseURI) external;

    function debitFrom(
        address _from,
        uint16,
        bytes memory,
        uint[] memory _tokenIds,
        uint[] memory _amounts
    ) external;

    function creditTo(
        uint16,
        address _toAddress,
        uint[] memory _tokenIds,
        uint[] memory _amounts
    ) external;
}
