web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
abi = JSON.parse('[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_newName","type":"string"}],"name":"changeName","outputs":[],"payable":false,"type":"function"}]')
address = '0xf211bcced1873c1fcab6d56746a1f37c62881953';

$(document).ready(function() {
	myContract = web3.eth.contract(abi).at(address);
	myContract.name(function(err, result){
		alert(result);
	})
	
});