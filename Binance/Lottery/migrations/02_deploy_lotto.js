const lottery = artifacts.require('./Lottery.sol');
// const rDAO = artifacts.require('rDAO');
// const EshToken = artifacts.require('./EshToken.sol');

module.exports = async function(deployer, network, accounts) {
	// const esh = await deployer.deploy(EshToken);
	
	// const rdao = await deployer.deploy(rDAO);
	// const token = await rDAO.deployed();
	
	// const lotto = await deployer.deploy(lottery,token.address);
	
	const lotto = await deployer.deploy(lottery,'0x0d');
};
