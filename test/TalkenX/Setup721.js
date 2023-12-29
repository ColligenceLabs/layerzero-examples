const { ethers } = require("hardhat")

const LZ_ENDPOINTS = require("../../constants/layerzeroEndpoints.json")
const Chains = require("../../constants/chainIds.json")
const minGasToStore = 40000
const batchSizeLimit = 3

const defaultAdapterParams = ethers.utils.solidityPack(["uint16", "uint256"], [1, 200000])
console.log("defaultAdapterParams : ", defaultAdapterParams)
console.log("")

const proxy = "0xa3885CFDe9AA6CC42Ad3eE43f241b1607A794299"
const bTalk = "0xEFAF7c09aAd784F89A0ecEfaA72E3EA28C61c8E0"
const pTalk = "0xce565ceD16D139fa13558Ab56060Ff4ddb22F799"
const kTalk = "0x0CB46dC603678b5073fB4e261E56f9A6283dc4B8"

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

const proxyContract = await hre.ethers.getContractAt("NFT721Proxy", proxy[hre.network.name])
const factoryContract = await hre.ethers.getContractAt("NFT721Factory", factory[hre.network.name])

let networks
if (mainNets.includes(hre.network.name)) {
    networks = mainNets
} else if (testNets.includes(hre.network.name)) {
    networks = testNets;
}

for (let i = 0; i < networks.length; i++) {
    const network = networks[i]
    if (network === hre.network.name) continue
    const chainId = Chains[network]

    proxyContract.setTrustedRemote(chainId, ethers.utils.solidityPack(["address", "address"], [proxy[network], proxy[hre.network.name]]))
    proxyContract.setDstChainIdToBatchLimit(chainId, batchSizeLimit)
    proxyContract.setMinDstGas(chainId, 1, 150000)

    factoryContract.setTrustedRemote(chainId, ethers.utils.solidityPack(["address", "address"], [factory[network], factory[hre.network.name]]))
    factoryContract.setDstChainIdToBatchLimit(chainId, batchSizeLimit)
    factoryContract.setMinDstGas(chainId, 1, 150000)
}


