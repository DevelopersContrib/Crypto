// const BigNumber = require('bignumber.js');
const CTBToken = artifacts.require('./CTBToken');
// const EshToken = artifacts.require('./EshToken');

const Farm = artifacts.require('./Farm');

module.exports = async function(deployer, network, accounts) {
	// const eshToken = await deployer.deploy(EshToken);
	// const deployedEshToken = await EshToken.deployed();
	// console.log('EshToken',deployedEshToken.address);
	
	const ctbtoken = await deployer.deploy(CTBToken);
	const deployedCTBToken = await CTBToken.deployed();
	
	console.log('CTBToken',deployedCTBToken.address);
	
	// const farm = await deployer.deploy(Farm,deployedCTBToken.address,deployedEshToken.address,'1500000000000000000');
	//const farm = await deployer.deploy(Farm,deployedCTBToken.address,deployedCTBToken.address,'1000000000000000000');
	const farm = await deployer.deploy(Farm,deployedCTBToken.address,deployedCTBToken.address,'198881490500000000',10,16);//10,15 blocks
	
};
