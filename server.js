var express = require('express');
var app = express();
var Web3 = require('web3');
var web3 = new Web3();
var url = require('url');

var abi = [{"constant":false,"inputs":[{"name":"newSellPrice","type":"uint256"},{"name":"newBuyPrice","type":"uint256"}],"name":"setPrices","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"sellPrice","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"standard","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"target","type":"address"},{"name":"mintedAmount","type":"uint256"}],"name":"mintToken","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"buyPrice","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"buy","outputs":[],"payable":true,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"frozenAccount","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"},{"name":"_extraData","type":"bytes"}],"name":"approveAndCall","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"amount","type":"uint256"}],"name":"sell","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"target","type":"address"},{"name":"freeze","type":"bool"}],"name":"freezeAccount","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"inputs":[{"name":"initialSupply","type":"uint256"},{"name":"tokenName","type":"string"},{"name":"decimalUnits","type":"uint8"},{"name":"tokenSymbol","type":"string"}],"payable":false,"type":"constructor"},{"payable":false,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":false,"name":"target","type":"address"},{"indexed":false,"name":"frozen","type":"bool"}],"name":"FrozenFunds","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}];

var bodyParser = require('body-parser');
app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies

web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

var allowCrossDomain = function(req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Content-Length, X-Requested-With');

    // intercept OPTIONS method
    if ('OPTIONS' == req.method) {
      res.send(200);
    }
    else {
      next();
    }
};
app.use(allowCrossDomain);

app.post('/mint', function(req, res) {
    var contractAddress = req.body.tokenaddress;
	var account = req.body.account;
	var passphrase = req.body.passphrase;
	var tokenvalue = req.body.tokenvalue;

	if(tokenvalue!= '' && !isNaN(tokenvalue) && passphrase!='' && account!='' && contractAddress!=''){
		try{
			web3.eth.defaultAccount = account;
			var unlock = web3.personal.unlockAccount(account,passphrase);
		} catch (err) {
			res.end(JSON.stringify({error:err}));
		}
		
		var contract = web3.eth.contract(abi).at(contractAddress);
		var txHash = contract.mintToken(account,tokenvalue);
		
		res.end(JSON.stringify({txHash:txHash}));
	}else{
		res.end(JSON.stringify({error:'Missing fields'}));
	}
});

app.post('/transfer', function(req, res) {
    var contractAddress = req.body.tokenaddress;
	var account = req.body.account;
	var passphrase = req.body.passphrase;
	
	var tokenvalue = req.body.tokenvalue;
	var addressto = req.body.addressto;

	if(addressto != '' && tokenvalue!= '' && !isNaN(tokenvalue) && passphrase!='' && account!='' && contractAddress!=''){
		try{
			web3.eth.defaultAccount = account;
			var unlock = web3.personal.unlockAccount(account,passphrase);
		} catch (err) {
			res.end(JSON.stringify({error:err}));
		}
		
		var contract = web3.eth.contract(abi).at(contractAddress);
		var txHash = contract.transfer(addressto,tokenvalue);
		
		res.end(JSON.stringify({txHash:txHash}));
	}else{
		res.end(JSON.stringify({error:'Missing fields'}));
	}
});

app.post('/setPrices', function(req, res) {
    var contractAddress = req.body.token;
	var sellprice = req.body.sellprice;
	var buyprice = req.body.buyprice;
	var account = req.body.account;
	var passphrase = req.body.passphrase;
	
	if(contractAddress != '' && !isNaN(sellprice) && !isNaN(buyprice) && account!=''&& passphrase!=''){
		try{
			web3.eth.defaultAccount = account;
			var unlock = web3.personal.unlockAccount(account,passphrase);
		} catch (err) {
			res.end(JSON.stringify({error:err}));
		}
		
		var contract = web3.eth.contract(abi).at(contractAddress);
		var txHash = contract.setPrices(parseInt(sellprice),parseInt(buyprice));
		
		res.end(JSON.stringify({txHash:txHash}));
	}else{
		res.end(JSON.stringify({error:'Missing fields'}));
	}
});

app.get('/getAccounts', function (req, res) {
	var accounts = web3.eth.accounts;
	res.end(JSON.stringify(accounts));
})

app.get('/getAccntEthBalance', function (req, res) {
	var url_parts = url.parse(req.url, true);
	var query = url_parts.query;
	var address = query.address;
	if(address!=''){
		var balance = web3.fromWei(web3.eth.getBalance(address), 'ether').toNumber();
		res.end(JSON.stringify({address:address,balance:balance}));
	}else{
		res.end(JSON.stringify({error:'Passphrase required'}));
	}
})

app.get('/getTokenName', function (req, res) {
	var url_parts = url.parse(req.url, true);
	var query = url_parts.query;
	var address = query.address;
	if(address!=''){
		var myTokenContract = web3.eth.contract(abi).at(address);		
		myTokenContract.name(function(err, result){
			res.end(JSON.stringify({address:myTokenContract.address,name:result}));
		})
		
	}else{
		res.end(JSON.stringify({error:'Passphrase required'}));
	}
})

app.get('/getTotalSupply', function (req, res) {
	var url_parts = url.parse(req.url, true);
	var query = url_parts.query;
	var address = query.address;
	if(address!=''){
		var myTokenContract = web3.eth.contract(abi).at(address);
		myTokenContract.totalSupply(function(err, result){
			res.end(JSON.stringify({address:myTokenContract.address,totalSupply:result}));
		})
		
	}else{
		res.end(JSON.stringify({error:'Passphrase required'}));
	}
})

app.get('/getBalanceOf', function (req, res) {
	var url_parts = url.parse(req.url, true);
	var query = url_parts.query;
	var address = query.token;
	var account = query.account;
	if(address!=''){
		var myTokenContract = web3.eth.contract(abi).at(address);		
		res.end(JSON.stringify({address:account,balance:myTokenContract.balanceOf(account)}));
	}else{
		res.end(JSON.stringify({error:'Invalid address'}));
	}
})

app.get('/getSellPrice', function (req, res) {
	var url_parts = url.parse(req.url, true);
	var query = url_parts.query;
	var address = query.address;
	if(address!=''){
		var myTokenContract = web3.eth.contract(abi).at(address);		
		myTokenContract.sellPrice(function(err, result){
			res.end(JSON.stringify({address:address,sellPrice:result.c[0]}));
		})
		
	}else{
		res.end(JSON.stringify({error:'Invalid address'}));
	}
})

app.get('/getBuyPrice', function (req, res) {
	var url_parts = url.parse(req.url, true);
	var query = url_parts.query;
	var address = query.address;
	if(address!=''){
		var myTokenContract = web3.eth.contract(abi).at(address);		
		myTokenContract.buyPrice(function(err, result){
			res.end(JSON.stringify({address:address,buyPrice:result.c[0]}));
		})
		
	}else{
		res.end(JSON.stringify({error:'Invalid address'}));
	}
})

app.get('/createAccount', function (req, res) {
	var url_parts = url.parse(req.url, true);
	var query = url_parts.query;
	
	if(query.passphrase!=''){
		web3.personal.newAccount("password",function(error,result){
			if(!error){
				console.log(result);
				res.end(JSON.stringify({address:result}));
			}
		});
	}else{
		res.end(JSON.stringify({error:'Passphrase required'}));
	}
})



app.get('/index',function (req, res){
	var fs = require('fs');
	fs.readFile('./accounts.html', function (err, html) {
		if (err) throw err;   
		res.writeHeader(200, {"Content-Type": "text/html"});
		res.end( html );
	});
})

app.get('/tester',function (req, res){
	var fs = require('fs');
	fs.readFile('./tester.html', function (err, html) {
		if (err) throw err;   
		res.writeHeader(200, {"Content-Type": "text/html"});
		res.end( html );
	});
})

var server = app.listen(8081, function () {
  var host = server.address().address
  var port = server.address().port

  console.log("App listening at http://%s:%s", host, port)
})