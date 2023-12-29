const LZ_ENDPOINTS = require("../../constants/layerzeroEndpoints.json")

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    console.log(`>>> your address: ${deployer}`)

    const talk = {
        "ethereum": "0xCAabCaA4ca42e1d86dE1a201c818639def0ba7A7",
        "sepolia": "0x67FD18Cc70A7f8C26508c59c906B39B2A079866d"
    }
    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    console.log(`[${hre.network.name}] Endpoint Address: ${lzEndpointAddress}`)

    await deploy("ProxyOFTV2", {
        from: deployer,
        args: [talk[hre.network.name], 5, lzEndpointAddress],
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = ["ProxyOFTV2"]
