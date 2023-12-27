// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "../interfaces/INFT1155Core.sol";
import "../interfaces/IERC1155Metadata.sol";
import "../../../lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

abstract contract NFT1155Core is NonblockingLzApp, ERC165, INFT1155Core {
    uint public constant NO_EXTRA_GAS = 0;
    uint16 public constant FUNCTION_TYPE_SEND = 1;
    uint16 public constant FUNCTION_TYPE_SEND_BATCH = 2;
    bool public useCustomAdapterParams;

    address[] public tokens;
    uint public tokenCount;
    mapping(address => bool) public tokenExists;

    event SetUseCustomAdapterParams(bool _useCustomAdapterParams);

    constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {}

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(INFT1155Core).interfaceId || super.supportsInterface(interfaceId);
    }

    function estimateSendFee(
        uint16 _dstChainId,
        bytes memory _toAddress,
        uint _tokenId,
        uint _amount,
        bool _useZro,
        bytes memory _adapterParams
    ) public view virtual override returns (uint nativeFee, uint zroFee) {
        return estimateSendBatchFee(_dstChainId, _toAddress, _toSingletonArray(_tokenId), _toSingletonArray(_amount), _useZro, _adapterParams);
    }

    function estimateSendBatchFee(
        uint16 _dstChainId,
        bytes memory _toAddress,
        uint[] memory _tokenIds,
        uint[] memory _amounts,
        bool _useZro,
        bytes memory _adapterParams
    ) public view virtual override returns (uint nativeFee, uint zroFee) {
        bytes memory payload = abi.encode(_toAddress, _tokenIds, _amounts);
        return lzEndpoint.estimateFees(_dstChainId, address(this), payload, _useZro, _adapterParams);
    }

    function sendFrom(
        address _from,
        uint16 _dstChainId,
        bytes memory _tokenAddress,
        bytes memory _toAddress,
        uint _tokenId,
        uint _amount,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams
    ) public payable {
        _sendBatch(
            _from,
            _dstChainId,
            _tokenAddress,
            _toAddress,
            _toSingletonArray(_tokenId),
            _toSingletonArray(_amount),
            _refundAddress,
            _zroPaymentAddress,
            _adapterParams
        );
    }

    function sendBatchFrom(
        address _from,
        uint16 _dstChainId,
        bytes memory _tokenAddress,
        bytes memory _toAddress,
        uint[] memory _tokenIds,
        uint[] memory _amounts,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams
    ) public payable {
        _sendBatch(_from, _dstChainId, _tokenAddress, _toAddress, _tokenIds, _amounts, _refundAddress, _zroPaymentAddress, _adapterParams);
    }

    function _sendBatch(
        address _from,
        uint16 _dstChainId,
        bytes memory _tokenAddress,
        bytes memory _toAddress,
        uint[] memory _tokenIds,
        uint[] memory _amounts,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams
    ) internal {
        address tokenAddress;
        assembly {
            tokenAddress := mload(add(_tokenAddress, 20))
        }

        require(_from == _msgSender(), "NFT1155Proxy: owner is not send caller");

        IERC1155(tokenAddress).safeBatchTransferFrom(_from, address(this), _tokenIds, _amounts, "");

        string memory name = IERC1155Metadata(tokenAddress).name();
        string memory symbol = IERC1155Metadata(tokenAddress).symbol();
        string[] memory uris = new string[](_tokenIds.length);

        for (uint i = 0; i < _tokenIds.length; i++) {
            if (IERC1155(tokenAddress).supportsInterface(type(IERC1155MetadataURI).interfaceId)) {
                uris[i] = IERC1155MetadataURI(tokenAddress).uri(_tokenIds[i]);
            } else {
                uris[i] = IERC1155MetadataURI(tokenAddress).uri(_tokenIds[0]);
            }
        }

        bytes memory payload = abi.encode(_tokenAddress, _toAddress, _tokenIds, _amounts, name, symbol, uris);

        if (_tokenIds.length == 1) {
            if (useCustomAdapterParams) {
                _checkGasLimit(_dstChainId, FUNCTION_TYPE_SEND, _adapterParams, NO_EXTRA_GAS);
            } else {
                require(_adapterParams.length == 0, "LzApp: _adapterParams must be empty.");
            }
            _lzSend(_dstChainId, payload, _refundAddress, _zroPaymentAddress, _adapterParams, msg.value);
            emit SendToChain(_dstChainId, _from, _toAddress, _tokenIds[0], _amounts[0]);
        } else if (_tokenIds.length > 1) {
            if (useCustomAdapterParams) {
                _checkGasLimit(_dstChainId, FUNCTION_TYPE_SEND_BATCH, _adapterParams, NO_EXTRA_GAS);
            } else {
                require(_adapterParams.length == 0, "LzApp: _adapterParams must be empty.");
            }
            _lzSend(_dstChainId, payload, _refundAddress, _zroPaymentAddress, _adapterParams, msg.value);
            emit SendBatchToChain(_dstChainId, _from, _toAddress, tokenAddress, _tokenIds, _amounts);
        }
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64, /*_nonce*/
        bytes memory _payload
    ) internal virtual override {
        // decode and load the toAddress
        (bytes memory tokenAddressBytes, bytes memory toAddressBytes, uint[] memory tokenIds, uint[] memory amounts) = abi.decode(
            _payload,
            (bytes, bytes, uint[], uint[])
        );

        address tokenAddress;
        assembly {
            tokenAddress := mload(add(tokenAddressBytes, 20))
        }

        address toAddress;
        assembly {
            toAddress := mload(add(toAddressBytes, 20))
        }

        IERC1155(tokenAddress).safeBatchTransferFrom(address(this), toAddress, tokenIds, amounts, "");

        if (tokenIds.length == 1) {
            emit ReceiveFromChain(_srcChainId, _srcAddress, toAddress, tokenAddress, tokenIds[0], amounts[0]);
        } else if (tokenIds.length > 1) {
            emit ReceiveBatchFromChain(_srcChainId, _srcAddress, toAddress, tokenAddress, tokenIds, amounts);
        }
    }

    function setUseCustomAdapterParams(bool _useCustomAdapterParams) external onlyOwner {
        useCustomAdapterParams = _useCustomAdapterParams;
        emit SetUseCustomAdapterParams(_useCustomAdapterParams);
    }

    function _toSingletonArray(uint element) internal pure returns (uint[] memory) {
        uint[] memory array = new uint[](1);
        array[0] = element;
        return array;
    }
}
