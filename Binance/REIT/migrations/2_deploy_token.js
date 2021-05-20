// migrations/2_deploy_token.js
const REIT = artifacts.require('REIT');
 
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
 
module.exports = async function (deployer) {
  
  await deployProxy(REIT, ['0x988877D0229903FFe6A5C3c86A7e77329b7F7b63'], { deployer, unsafeAllowCustomTypes: true, initializer: 'initialize' });
};