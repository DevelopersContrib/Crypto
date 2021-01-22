// migrations/2_deploy.js
// SPDX-License-Identifier: MIT
const RDAOCrowdsale = artifacts.require("RDAOCrowdsale");

module.exports = async function (deployer, network, accounts) {
	const owner = '';
	const token = '';
	const beneficiary = '';
	const rate = 64;
	await deployer.deploy(RDAOCrowdsale, rate, beneficiary, token, owner);
	const crowdsale = await RDAOCrowdsale.deployed();


};