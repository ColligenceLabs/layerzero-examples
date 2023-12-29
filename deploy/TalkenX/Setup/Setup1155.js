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
    "mumbai" : "",
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
    "bsc-testnet" : "",
    "baobab" : ""
}

const mainNets = ["ethereum", "bsc", "polygon", "klaytn"]
const testNets = ["sepolia", "bsc-testnet","mumbai", "baobab"]

let networks
if (mainNets.includes(hre.network.name)) {
    networks = mainNets
} else if (testNets.includes(hre.network.name)) {
    networks = testNets;
}

const setup1155 = async () => {
    const proxyContract = await hre.ethers.getContractAt("NFT1155Proxy", proxy[hre.network.name])
    const factoryContract = await hre.ethers.getContractAt("NFT1155Factory", factory[hre.network.name])

    for (let i = 0; i < networks.length; i++) {
        const network = networks[i]
        if (network === hre.network.name) continue
        if (!proxy[network] || !factory[network]) continue
        const chainId = Chains[network]

        proxyContract.setTrustedRemote(chainId, ethers.utils.solidityPack(["address", "address"], [proxy[network], proxy[hre.network.name]]))
        proxyContract.setDstChainIdToBatchLimit(chainId, batchSizeLimit)
        proxyContract.setMinDstGas(chainId, 1, 150000)

        factoryContract.setTrustedRemote(chainId, ethers.utils.solidityPack(["address", "address"], [factory[network], factory[hre.network.name]]))
        factoryContract.setDstChainIdToBatchLimit(chainId, batchSizeLimit)
        factoryContract.setMinDstGas(chainId, 1, 150000)
    }
}

setup1155().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
