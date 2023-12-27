// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./INFT721Core.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @dev Interface of the ONFT standard
 */
interface INFT721 is INFT721Core, IERC721 {
    function debitFrom(
        address _from,
        uint16,
        bytes memory,
        uint _tokenId
    ) external;

    function creditTo(
        uint16,
        address _toAddress,
        uint _tokenId,
        string memory _uri
    ) external;
}
