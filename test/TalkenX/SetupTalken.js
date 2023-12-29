const { ethers } = require("hardhat")

const LZ_ENDPOINTS = require("../../constants/layerzeroEndpoints.json")
const Chains = require("../../constants/chainIds.json")
const minGasToStore = 40000

const proxy = {
    "ethereum" : "",
    "sepolia" : "0xa3885CFDe9AA6CC42Ad3eE43f241b1607A794299",
}

const talk = {
    "polygon" : "",
    "bsc" : "",
    "klaytn" : "",
    "mumbai" : "0xce565ceD16D139fa13558Ab56060Ff4ddb22F799",
    "bsc-testnet" : "0xEFAF7c09aAd784F89A0ecEfaA72E3EA28C61c8E0",
    "baobab" : "0x0CB46dC603678b5073fB4e261E56f9A6283dc4B8"
}

const mainNets = ["ethereum", "bsc", "polygon", "klaytn"]
const testNets = ["sepolia", "bsc-testnet","mumbai", "baobab"]

const proxyContract = await hre.ethers.getContractAt("ProxyOFTV2", proxy[hre.network.name]);
const talkContract = await hre.ethers.getContractAt("OFTV2", talk[hre.network.name]);

let networks;
if (hre.network.name === 'ethereum')
    networks = mainNets;
else if (hre.network.name === 'sepolia') networks = testNets;

for (let i = 0; i < networks.length; i++) {
    const network = networks[i]
    const chainId = Chains[network]

    if (network === hre.network.name) {
        proxyContract.setTrustedRemote(chainId, ethers.utils.solidityPack(["address", "address"], [talk[network], proxy[hre.network.name]]));
        proxyContract.setMinDstGas(chainId, 0, 200000)
        proxyContract.setMinDstGas(chainId, 1, 200000)
    } else {
        talkContract.setTrustedRemote(chainId, ethers.utils.solidityPack(["address", "address"], [proxy[hre.network.name], talk[network]]));
        talkContract.setMinDstGas(chainId, 0, 200000)
        talkContract.setMinDstGas(chainId, 1, 200000)
    }
}


