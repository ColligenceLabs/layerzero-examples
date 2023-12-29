const { ethers } = require("hardhat")

const LZ_ENDPOINTS = require("../../../constants/layerzeroEndpoints.json")
const Chains = require("../../../constants/chainIds.json")
const minGasToStore = 40000

const mainNets = ["ethereum", "bsc", "polygon", "klaytn"]
const testNets = ["sepolia", "bsc-testnet","mumbai", "baobab"]

const talk = {
    "ethereum" : "", // Proxy
    "polygon" : "",
    "bsc" : "",
    "klaytn" : "",
    "sepolia" : "0xa3885CFDe9AA6CC42Ad3eE43f241b1607A794299", // Proxy
    "mumbai" : "0xce565ceD16D139fa13558Ab56060Ff4ddb22F799",
    "bsc-testnet" : "0xEFAF7c09aAd784F89A0ecEfaA72E3EA28C61c8E0",
    "baobab" : "0x0CB46dC603678b5073fB4e261E56f9A6283dc4B8"
}

let networks;
let nameOrAbi;

if (hre.network.name === 'ethereum') {
    networks = mainNets;
    nameOrAbi = "ProxyOFTV2";
} else if (hre.network.name === 'sepolia') {
    networks = testNets;
    nameOrAbi = "OFTV2";
}

const setupTalken = async () => {
    const talkenContract = await hre.ethers.getContractAt(nameOrAbi, talk[hre.network.name]);

    for (let i = 0; i < networks.length; i++) {
        const network = networks[i]
        const chainId = Chains[network]

        if (network === hre.network.name) continue

        talkenContract.setTrustedRemote(chainId, ethers.utils.solidityPack(["address", "address"], [talk[network], talkenContract.address]));
        talkenContract.setMinDstGas(chainId, 0, 200000)
        talkenContract.setMinDstGas(chainId, 1, 200000)
    }
}

setupTalken().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
