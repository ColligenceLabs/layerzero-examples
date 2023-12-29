const LZ_ENDPOINTS = require("../../constants/layerzeroEndpoints.json")

const minGasToStoreAndStore = 40000

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    console.log(`>>> your address: ${deployer}`)

    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    console.log(`[${hre.network.name}] Endpoint Address: ${lzEndpointAddress}`)

    await deploy("NFT721Factory", {
        from: deployer,
        args: [minGasToStoreAndStore, lzEndpointAddress],
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = ["NFT721Factory"]
