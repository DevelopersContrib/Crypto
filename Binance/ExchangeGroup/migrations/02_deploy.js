const Exchange = artifacts.require('Exchange');
const rDAO = artifacts.require('rDAO');
const EshToken = artifacts.require('EshToken');
const Esha = artifacts.require('Esha');
const Eshb = artifacts.require('Eshb');

module.exports = async function(deployer, network, accounts) {
	const esh = await deployer.deploy(EshToken);	
	const esha = await deployer.deploy(Esha);
	const eshb = await deployer.deploy(Eshb);
	
	const rdao = await deployer.deploy(rDAO);
	const rdaoToken = await rDAO.deployed();
	
	const exchange = await deployer.deploy(Exchange,rdaoToken.address);
};
