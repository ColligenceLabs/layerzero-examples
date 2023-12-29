const LZ_ENDPOINTS = require("../../constants/layerzeroEndpoints.json")

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    console.log(`>>> your address: ${deployer}`)

    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    console.log(`[${hre.network.name}] Endpoint Address: ${lzEndpointAddress}`)

    if (hre.network.name !== 'ethereum' && hre.network.name !== 'sepolia') {
        await deploy("OFTV2", {
            from: deployer,
            args: ["Talken", "TALK", 5, lzEndpointAddress],
            log: true,
            waitConfirmations: 1,
        })
    } else {
        console.log('No need to deploy LayerZero TALK on the Ethereum !!')
    }
}

module.exports.tags = ["OFTV2"]
