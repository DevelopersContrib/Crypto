const EshToken = artifacts.require('EshToken');

module.exports = async function(deployer, network, accounts) {
	const DAN_ADDRESS = "0x3de17aedc9361543d9fbbabb7163459f4b47d0b5";
	const DAN_SUPPLY = 100000;
	// const OWNER_ADDRESS = "0x54c207dd155f8493c0ceda867b37f0af73a54540";
	// const OWNER_SUPPLY = 800000;
	
	// const RESERVE_ADDRESS = "0xB8cb36279d10E41b5c899fBFEFc46eAd6c9a3e05";
	// const RESERVE_SUPPLY = 100000;
	
	// const esh = await deployer.deploy(EshToken, "ESH TOKEN", "ESH", DAN_ADDRESS, DAN_SUPPLY, OWNER_ADDRESS, OWNER_SUPPLY, RESERVE_ADDRESS, RESERVE_SUPPLY);
	const esh = await deployer.deploy(EshToken, "ESH TOKEN", "ESH", DAN_ADDRESS, DAN_SUPPLY, '', 0, '', 0);
};
