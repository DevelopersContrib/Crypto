const Voting = artifacts.require('Voting');

module.exports = async function(deployer, network, accounts) {
	const voting = await deployer.deploy(Voting);
	
	const contract = await Voting.deployed();
	
	console.log('voting',contract.address);
};
