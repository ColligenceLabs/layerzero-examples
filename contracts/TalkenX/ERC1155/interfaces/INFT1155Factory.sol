// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev Interface of the ONFT Core standard
 */
interface INFT1155Factory is IERC165 {
    event SendToChain(
        uint16 indexed _dstChainId,
        address indexed _from,
        bytes indexed _toAddress,
        bytes _tokenAddress,
        uint _tokenId,
        uint _amount
    );
    event SendBatchToChain(
        uint16 indexed _dstChainId,
        address indexed _from,
        bytes indexed _toAddress,
        bytes _tokenAddress,
        uint[] _tokenIds,
        uint[] _amounts
    );
    event ReceiveFromChain(
        uint16 indexed _srcChainId,
        bytes indexed _srcAddress,
        address indexed _toAddress,
        address _tokenAddress,
        uint _tokenId,
        uint _amount
    );
    event ReceiveBatchFromChain(
        uint16 indexed _srcChainId,
        bytes indexed _srcAddress,
        address indexed _toAddress,
        address _tokenAddress,
        uint[] _tokenIds,
        uint[] _amounts
    );

    // _dstChainId - L0 defined chain id to send tokens too
    // _toAddress - dynamic bytes array which contains the address to whom you are sending tokens to on the dstChain
    // _tokenId - token Id to transfer
    // _amount - amount of the tokens to transfer
    // _useZro - indicates to use zro to pay L0 fees
    // _adapterParams - flexible bytes array to indicate messaging adapter services in L0
    function estimateSendFee(
        uint16 _dstChainId,
        bytes calldata _toAddress,
        uint _tokenId,
        uint _amount,
        bool _useZro,
        bytes calldata _adapterParams
    ) external view returns (uint nativeFee, uint zroFee);

    // _dstChainId - L0 defined chain id to send tokens too
    // _toAddress - dynamic bytes array which contains the address to whom you are sending tokens to on the dstChain
    // _tokenIds - tokens Id to transfer
    // _amounts - amounts of the tokens to transfer
    // _useZro - indicates to use zro to pay L0 fees
    // _adapterParams - flexible bytes array to indicate messaging adapter services in L0
    function estimateSendBatchFee(
        uint16 _dstChainId,
        bytes calldata _toAddress,
        uint[] calldata _tokenIds,
        uint[] calldata _amounts,
        bool _useZro,
        bytes calldata _adapterParams
    ) external view returns (uint nativeFee, uint zroFee);
}
