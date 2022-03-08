const Exchange = artifacts.require('Exchange');
const rDAO = artifacts.require('rDAO');
const EshToken = artifacts.require('EshToken');
const Crowdsale = artifacts.require('Crowdsale');

module.exports = async function(deployer, network, accounts) {
	const crowdsale = await deployer.deploy(Crowdsale,web3.utils.toWei('0.1','ether'));
	const crowdsaleContract = await Crowdsale.deployed();
	
	const esh = await deployer.deploy(EshToken);
	
	const rdao = await deployer.deploy(rDAO);
	const rdaoToken = await rDAO.deployed();
	
	const exchange = await deployer.deploy(Exchange,rdaoToken.address,crowdsaleContract.address,'0xa202a8f36f01f9E73d98d7540eec21c3362f10af');
	
	
};
