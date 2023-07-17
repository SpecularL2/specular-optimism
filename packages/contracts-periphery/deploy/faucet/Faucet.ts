/* Imports: External */
import { DeployFunction } from 'hardhat-deploy/dist/types'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import '@nomiclabs/hardhat-ethers'
import '@eth-optimism/hardhat-deploy-config'
import 'hardhat-deploy'
import { BigNumber } from 'ethers'

import type { DeployConfig } from '../../src'

const deployFn: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const deployConfig = hre.deployConfig as DeployConfig

  const { deployer } = await hre.getNamedAccounts()
  console.log('Deploying Faucet')

  console.log('admin', deployConfig.faucetAdmin)
  console.log('deployer', deployer)
  const { deploy } = await hre.deployments.deterministic('Faucet', {
    salt: hre.ethers.utils.solidityKeccak256(['string'], ['Faucet']),
    from: deployer,
    args: [deployConfig.faucetAdmin],
    log: true,
    gasPrice: BigNumber.from(2000000000),
  })

  const result = await deploy()
  console.log('Faucet byte code', result.bytecode)
}

deployFn.tags = ['Faucet', 'FaucetEnvironment']

export default deployFn
