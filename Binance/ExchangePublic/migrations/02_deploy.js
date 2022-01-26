const Exchange = artifacts.require('Exchange');
const rDAO = artifacts.require('rDAO');
const EshToken = artifacts.require('EshToken');

module.exports = async function(deployer, network, accounts) {
	const esh = await deployer.deploy(EshToken);
	
	const rdao = await deployer.deploy(rDAO);
	const rdaoToken = await rDAO.deployed();
	
	//const exchange = await deployer.deploy(Exchange,rdaoToken.address,"0x0d7C5c6775B55C84057A2E9cB01E6cbA3dB395DA");
	
	const exchange = await deployer.deploy(Exchange,rdaoToken.address);
	
	// const exchange = await deployer.deploy(Exchange,"0x0d7C5c6775B55C84057A2E9cB01E6cbA3dB395DA");
	
};
