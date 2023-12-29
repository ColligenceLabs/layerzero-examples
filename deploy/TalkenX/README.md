
## TALK Bridge

### Deploy Talken Proxy :
```
npx hardhat --network ethereum deploy --tags ProxyOFTV2
```

### Deploy LayerZero Talken :

```
npx hardhat --network bsc deploy --tags OFTV2
npx hardhat --network polygon deploy --tags OFTV2
npx hardhat --network klaytn deploy --tags OFTV2
```

### Setup Talken Contracts :
```
npx hardhat --network ethereum run deploy/TalkenX/Setup/SetupTalken.js
npx hardhat --network bsc run deploy/TalkenX/Setup/SetupTalken.js
npx hardhat --network polygon run deploy/TalkenX/Setup/SetupTalken.js
npx hardhat --network klaytn run deploy/TalkenX/Setup/SetupTalken.js
```

## ERC721 Bridge

### Deploy ERC721 Proxy & Factory :
```
npx hardhat --network ethereum deploy --tags NFT721Proxy
npx hardhat --network ethereum deploy --tags NFT721Factory

npx hardhat --network bsc deploy --tags NFT721Proxy
npx hardhat --network bsc deploy --tags NFT721Factory

npx hardhat --network polygon deploy --tags NFT721Proxy
npx hardhat --network polygon deploy --tags NFT721Factory

npx hardhat --network klaytn deploy --tags NFT721Proxy
npx hardhat --network klaytn deploy --tags NFT721Factory
```

### Setup Scripts :
> Set all contract addresses deployed into Setup/Setup721.js
```
npx hardhat --network ethereum run deploy/TalkenX/Setup/Setup721.js
npx hardhat --network bsc run deploy/TalkenX/Setup/Setup721.js
npx hardhat --network polygon run deploy/TalkenX/Setup/Setup721.js
npx hardhat --network klaytn run deploy/TalkenX/Setup/Setup721.js
```

## ERC1155 Bridge

### Deploy ERC1155 Proxy & Factory :
```
npx hardhat --network ethereum deploy --tags NFT1155Proxy
npx hardhat --network ethereum deploy --tags NFT1155Factory

npx hardhat --network bsc deploy --tags NFT1155Proxy
npx hardhat --network bsc deploy --tags NFT1155Factory

npx hardhat --network polygon deploy --tags NFT1155Proxy
npx hardhat --network polygon deploy --tags NFT1155Factory

npx hardhat --network klaytn deploy --tags NFT1155Proxy
npx hardhat --network klaytn deploy --tags NFT1155Factory
```

### Setup Scripts :
> Set all contract addresses deployed into Setup/Setup1155.js
```
npx hardhat --network ethereum run deploy/TalkenX/Setup/Setup1155.js
npx hardhat --network bsc run deploy/TalkenX/Setup/Setup1155.js
npx hardhat --network polygon run deploy/TalkenX/Setup/Setup1155.js
npx hardhat --network klaytn run deploy/TalkenX/Setup/Setup1155.js
```
