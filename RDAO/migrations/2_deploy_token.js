// migrations/2_deploy_token.js
const RDAO = artifacts.require('RDAO');
 
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
 
module.exports = async function (deployer) {
  await deployProxy(RDAO, ['RDAO Token', 'RDAO', '1000000000000000000000000000'], { deployer, initializer: 'initialize' });
};