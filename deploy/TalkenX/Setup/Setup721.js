const { ethers } = require("hardhat")

const LZ_ENDPOINTS = require("../../../constants/layerzeroEndpoints.json")
const Chains = require("../../../constants/chainIds.json")
const minGasToStore = 40000
const batchSizeLimit = 3

const proxy = {
    "ethereum" : "",
    "polygon" : "",
    "bsc" : "",
    "klaytn" : "",
    "sepolia" : "",
    "mumbai" : "0x89a4e313fA1938281915284E9A375E72189C3430",
    "bsc-testnet" : "",
    "baobab" : ""
}

const factory = {
    "ethereum" : "",
    "polygon" : "",
    "bsc" : "",
    "klaytn" : "",
    "sepolia" : "",
    "mumbai" : "",
    "bsc-testnet" : "0x29bFddB2ec502B223A770Ece92bB5f66285A2b9b",
    "baobab" : ""
}

const mainNets = ["ethereum", "bsc", "polygon", "klaytn"]
const testNets = ["sepolia", "bsc-testnet","mumbai", "baobab"]

const setup721 = async () => {
    const proxyContract = await hre.ethers.getContractAt("NFT721Proxy", proxy[hre.network.name])
    const factoryContract = await hre.ethers.getContractAt("NFT721Factory", factory[hre.network.name])
    console.log('!! Proxy Contract   : ', proxyContract.address)
    console.log('!! Factory Contract : ', factoryContract.address)

    let networks
    if (mainNets.includes(hre.network.name)) {
        networks = mainNets
    } else if (testNets.includes(hre.network.name)) {
        networks = testNets;
    }

    for (let i = 0; i < networks.length; i++) {
        const network = networks[i]
        const chainId = Chains[network]

        if (network === hre.network.name) continue
        if (!proxy[network] || !factory[network]) continue
        console.log('!!!! Setup on ', network)

        proxyContract.setTrustedRemote(chainId, ethers.utils.solidityPack(["address", "address"], [proxy[network], proxyContract.address]))
        proxyContract.setDstChainIdToBatchLimit(chainId, batchSizeLimit)
        proxyContract.setMinDstGas(chainId, 1, 150000)

        factoryContract.setTrustedRemote(chainId, ethers.utils.solidityPack(["address", "address"], [factory[network], factoryContract.address]))
        factoryContract.setDstChainIdToBatchLimit(chainId, batchSizeLimit)
        factoryContract.setMinDstGas(chainId, 1, 150000)
    }
}

setup721().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
