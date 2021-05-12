const Exchange = artifacts.require('Exchange');
const rDAO = artifacts.require('rDAO');
// const EshToken = artifacts.require('EshToken');

module.exports = async function(deployer, network, accounts) {
	// const esh = await deployer.deploy(EshToken);
	
	const rdao = await deployer.deploy(rDAO);
	const rdaoToken = await rDAO.deployed();
	
	const exchange = await deployer.deploy(Exchange,rdaoToken.address);
	
	
	// const exchange = await deployer.deploy(Exchange,'0x7937696ba41015a910ffd25d2580f0bd9403ad58');
	
};
