// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/INFT721.sol";
import "../interfaces/INFT721Factory.sol";
import "../../../lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./NFT721.sol";

contract NFT721Factory is NonblockingLzApp, ERC165, ReentrancyGuard, INFT721Factory {
    uint16 public constant FUNCTION_TYPE_SEND = 1;

    struct StoredCredit {
        uint16 srcChainId;
        address tokenAddress;
        address toAddress;
        uint index; // which index of the tokenIds remain
        bool creditsRemain;
    }

    uint public minGasToTransferAndStore; // min amount of gas required to transfer, and also store the payload
    mapping(uint16 => uint) public dstChainIdToBatchLimit;
    mapping(uint16 => uint) public dstChainIdToTransferGas; // per transfer amount of gas required to mint/transfer on the dst
    mapping(bytes32 => StoredCredit) public storedCredits;

    mapping(address => address) public tokens;
    uint public tokenCount;
    mapping(address => bool) public tokenExists;
    mapping(address => address) public tokenMap;

    event TokenDeployed(address tokenAddress);

    constructor(uint _minGasToTransferAndStore, address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {
        require(_minGasToTransferAndStore > 0, "minGasToTransferAndStore must be > 0");
        minGasToTransferAndStore = _minGasToTransferAndStore;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(INFT721Factory).interfaceId || super.supportsInterface(interfaceId);
    }

    function estimateSendFee(
        uint16 _dstChainId,
        bytes memory _tokenAddress,
        bytes memory _toAddress,
        uint _tokenId,
        bool _useZro,
        bytes memory _adapterParams
    ) public view virtual override returns (uint nativeFee, uint zroFee) {
        return estimateSendBatchFee(_dstChainId, _tokenAddress, _toAddress, _toSingletonArray(_tokenId), _useZro, _adapterParams);
    }

    function estimateSendBatchFee(
        uint16 _dstChainId,
        bytes memory _tokenAddress,
        bytes memory _toAddress,
        uint[] memory _tokenIds,
        bool _useZro,
        bytes memory _adapterParams
    ) public view virtual override returns (uint nativeFee, uint zroFee) {
        bytes memory payload = abi.encode(_tokenAddress, _toAddress, _tokenIds);
        return lzEndpoint.estimateFees(_dstChainId, address(this), payload, _useZro, _adapterParams);
    }

    function sendFrom(
        address _from,
        uint16 _dstChainId,
        bytes memory _tokenAddress,
        bytes memory _toAddress,
        uint _tokenId,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams
    ) public payable {
        _send(_from, _dstChainId, _tokenAddress, _toAddress, _toSingletonArray(_tokenId), _refundAddress, _zroPaymentAddress, _adapterParams);
    }

    function sendBatchFrom(
        address _from,
        uint16 _dstChainId,
        bytes memory _tokenAddress,
        bytes memory _toAddress,
        uint[] memory _tokenIds,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams
    ) public payable {
        _send(_from, _dstChainId, _tokenAddress, _toAddress, _tokenIds, _refundAddress, _zroPaymentAddress, _adapterParams);
    }

    function _send(
        address _from,
        uint16 _dstChainId,
        bytes memory _tokenAddress,
        bytes memory _toAddress,
        uint[] memory _tokenIds,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams
    ) internal {
        // allow 1 by default
        require(_tokenIds.length > 0, "tokenIds[] is empty");
        require(_tokenIds.length == 1 || _tokenIds.length <= dstChainIdToBatchLimit[_dstChainId], "batch size exceeds dst batch limit");

        address tokenAddress;
        assembly {
            tokenAddress := mload(add(_tokenAddress, 20))
        }

        address targetAddress = tokenMap[tokenAddress];
        require(tokenExists[targetAddress], "Not available NFT");

        for (uint i = 0; i < _tokenIds.length; i++) {
            INFT721(tokenAddress).debitFrom(_from, _dstChainId, _toAddress, _tokenIds[i]);
        }

        bytes memory payload = abi.encode(abi.encodePacked(targetAddress), _toAddress, _tokenIds);

        uint gas = dstChainIdToTransferGas[_dstChainId];
        _checkGasLimit(_dstChainId, FUNCTION_TYPE_SEND, _adapterParams, gas * _tokenIds.length);
        _lzSend(_dstChainId, payload, _refundAddress, _zroPaymentAddress, _adapterParams, msg.value);
        emit SendToChain(_dstChainId, _from, _toAddress, _tokenAddress, _tokenIds);
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64, /*_nonce*/
        bytes memory _payload
    ) internal virtual override {
        // decode and load the toAddress
        (
            bytes memory tokenAddressBytes,
            bytes memory toAddressBytes,
            uint[] memory tokenIds,
            string memory name,
            string memory symbol,
            string[] memory tokenUris
        ) = abi.decode(_payload, (bytes, bytes, uint[], string, string, string[]));

        address tokenAddress;
        assembly {
            tokenAddress := mload(add(tokenAddressBytes, 20))
        }

        address toAddress;
        assembly {
            toAddress := mload(add(toAddressBytes, 20))
        }

        if (!tokenExists[tokenAddress]) {
            // How to get NAME, SYMBOL ?
            address deployed = deployToken(name, symbol);
            tokens[tokenAddress] = deployed;
            tokenExists[tokenAddress] = true;
            tokenMap[deployed] = tokenAddress;
            tokenCount += 1;
        }

        uint nextIndex = _creditTill(_srcChainId, tokens[tokenAddress], toAddress, 0, tokenIds, tokenUris);
        if (nextIndex < tokenIds.length) {
            // not enough gas to complete transfers, store to be cleared in another tx
            bytes32 hashedPayload = keccak256(_payload);
            storedCredits[hashedPayload] = StoredCredit(_srcChainId, tokens[tokenAddress], toAddress, nextIndex, true);
            emit CreditStored(hashedPayload, _payload);
        }

        emit ReceiveFromChain(_srcChainId, _srcAddress, toAddress, tokenAddress, tokenIds);
    }

    // Public function for anyone to clear and deliver the remaining batch sent tokenIds
    function clearCredits(bytes memory _payload) external virtual nonReentrant {
        bytes32 hashedPayload = keccak256(_payload);
        require(storedCredits[hashedPayload].creditsRemain, "no credits stored");

        (, , uint[] memory tokenIds, , , string[] memory tokenUris) = abi.decode(_payload, (bytes, bytes, uint[], string, string, string[]));

        uint nextIndex = _creditTill(
            storedCredits[hashedPayload].srcChainId,
            storedCredits[hashedPayload].tokenAddress,
            storedCredits[hashedPayload].toAddress,
            storedCredits[hashedPayload].index,
            tokenIds,
            tokenUris
        );
        require(nextIndex > storedCredits[hashedPayload].index, "not enough gas to process credit transfer");

        if (nextIndex == tokenIds.length) {
            // cleared the credits, delete the element
            delete storedCredits[hashedPayload];
            emit CreditCleared(hashedPayload);
        } else {
            // store the next index to mint
            storedCredits[hashedPayload] = StoredCredit(
                storedCredits[hashedPayload].srcChainId,
                storedCredits[hashedPayload].tokenAddress,
                storedCredits[hashedPayload].toAddress,
                nextIndex,
                true
            );
        }
    }

    // When a srcChain has the ability to transfer more chainIds in a single tx than the dst can do.
    // Needs the ability to iterate and stop if the minGasToTransferAndStore is not met
    function _creditTill(
        uint16 _srcChainId,
        address _tokenAddress,
        address _toAddress,
        uint _startIndex,
        uint[] memory _tokenIds,
        string[] memory _tokenUris
    ) internal returns (uint) {
        uint i = _startIndex;
        while (i < _tokenIds.length) {
            // if not enough gas to process, store this index for next loop
            if (gasleft() < minGasToTransferAndStore) break;

            INFT721(_tokenAddress).creditTo(_srcChainId, _toAddress, _tokenIds[i], _tokenUris[i]);
            i++;
        }

        // indicates the next index to send of tokenIds,
        // if i == tokenIds.length, we are finished
        return i;
    }

    function setMinGasToTransferAndStore(uint _minGasToTransferAndStore) external onlyOwner {
        require(_minGasToTransferAndStore > 0, "minGasToTransferAndStore must be > 0");
        minGasToTransferAndStore = _minGasToTransferAndStore;
        emit SetMinGasToTransferAndStore(_minGasToTransferAndStore);
    }

    // ensures enough gas in adapter params to handle batch transfer gas amounts on the dst
    function setDstChainIdToTransferGas(uint16 _dstChainId, uint _dstChainIdToTransferGas) external onlyOwner {
        require(_dstChainIdToTransferGas > 0, "dstChainIdToTransferGas must be > 0");
        dstChainIdToTransferGas[_dstChainId] = _dstChainIdToTransferGas;
        emit SetDstChainIdToTransferGas(_dstChainId, _dstChainIdToTransferGas);
    }

    // limit on src the amount of tokens to batch send
    function setDstChainIdToBatchLimit(uint16 _dstChainId, uint _dstChainIdToBatchLimit) external onlyOwner {
        require(_dstChainIdToBatchLimit > 0, "dstChainIdToBatchLimit must be > 0");
        dstChainIdToBatchLimit[_dstChainId] = _dstChainIdToBatchLimit;
        emit SetDstChainIdToBatchLimit(_dstChainId, _dstChainIdToBatchLimit);
    }

    function _toSingletonArray(uint element) internal pure returns (uint[] memory) {
        uint[] memory array = new uint[](1);
        array[0] = element;
        return array;
    }

    function deployToken(string memory _name, string memory _symbol) public returns (address) {
        NFT721 token = new NFT721(_name, _symbol);
        emit TokenDeployed(address(token));
        return address(token);
    }
}
