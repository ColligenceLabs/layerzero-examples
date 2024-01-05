const { ethers } = require("hardhat")

const defaultAdapterParams = ethers.utils.solidityPack(["uint16", "uint256"], [1, 200000])
console.log("defaultAdapterParams : ", defaultAdapterParams)
console.log("")

const proxy = "0xa3885CFDe9AA6CC42Ad3eE43f241b1607A794299"
const bTalk = "0xEFAF7c09aAd784F89A0ecEfaA72E3EA28C61c8E0"
const pTalk = "0xce565ceD16D139fa13558Ab56060Ff4ddb22F799"
const kTalk = "0x0CB46dC603678b5073fB4e261E56f9A6283dc4B8"

// setTrustedRemote

// Ethereum
console.log("Polygon  10109 : ", ethers.utils.solidityPack(["address", "address"], [pTalk, proxy]))
console.log("Klaytn   10150 : ", ethers.utils.solidityPack(["address", "address"], [kTalk, proxy]))
console.log("Binance  10102 : ", ethers.utils.solidityPack(["address", "address"], [bTalk, proxy]))
// console.log("Polygon  109 : ", ethers.utils.solidityPack(["address", "address"], [pTalk, proxy]))
// console.log("Klaytn   150 : ", ethers.utils.solidityPack(["address", "address"], [kTalk, proxy]))
// console.log("Binance  102 : ", ethers.utils.solidityPack(["address", "address"], [bTalk, proxy]))
console.log("")

// Polygon
console.log("Ethereum 10161 : ", ethers.utils.solidityPack(["address", "address"], [proxy, pTalk]))
console.log("Klaytn   10150 : ", ethers.utils.solidityPack(["address", "address"], [kTalk, pTalk]))
console.log("Binance  10102 : ", ethers.utils.solidityPack(["address", "address"], [bTalk, pTalk]))
// console.log("Ethereum 101 : ", ethers.utils.solidityPack(["address", "address"], [proxy, pTalk]))
// console.log("Klaytn   150 : ", ethers.utils.solidityPack(["address", "address"], [kTalk, pTalk]))
// console.log("Binance  102 : ", ethers.utils.solidityPack(["address", "address"], [bTalk, pTalk]))
console.log("")

// Klaytn
console.log("Ethereum 10161 : ", ethers.utils.solidityPack(["address", "address"], [proxy, kTalk]))
console.log("Polygon  10109 : ", ethers.utils.solidityPack(["address", "address"], [pTalk, kTalk]))
console.log("Binance  10102 : ", ethers.utils.solidityPack(["address", "address"], [bTalk, kTalk]))
// console.log("Ethereum 101 : ", ethers.utils.solidityPack(["address", "address"], [proxy, kTalk]))
// console.log("Polygon  109 : ", ethers.utils.solidityPack(["address", "address"], [pTalk, kTalk]))
// console.log("Binance  102 : ", ethers.utils.solidityPack(["address", "address"], [bTalk, kTalk]))
console.log("")

// Binance
console.log("Ethereum 10161 : ", ethers.utils.solidityPack(["address", "address"], [proxy, bTalk]))
console.log("Polygon  10109 : ", ethers.utils.solidityPack(["address", "address"], [pTalk, bTalk]))
console.log("Klaytn   10150 : ", ethers.utils.solidityPack(["address", "address"], [kTalk, bTalk]))
// console.log("Ethereum 101 : ", ethers.utils.solidityPack(["address", "address"], [proxy, bTalk]))
// console.log("Polygon  109 : ", ethers.utils.solidityPack(["address", "address"], [pTalk, bTalk]))
// console.log("Klaytn   150 : ", ethers.utils.solidityPack(["address", "address"], [kTalk, bTalk]))
