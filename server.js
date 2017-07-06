var express = require('express');
var app = express();
var Web3 = require('web3');
var web3 = new Web3();
var url = require('url');

web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));
//web3.setProvider(new web3.providers.HttpProvider("http://52.25.91.1:8545/"));
//web3 = new Web3(new Web3.providers.HttpProvider("https://ropsten.infura.io/MezSkDvkG0jHFFkL6rYZ "));

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

app.get('/getAccounts', function (req, res) {
	var accounts = web3.eth.accounts;
	res.end(JSON.stringify(accounts));
})

app.get('/createAccount', function (req, res) {
	var url_parts = url.parse(req.url, true);
	var query = url_parts.query;
	//res.end(JSON.stringify({passphrase:query.passphrase}));
	
	if(query.passphrase!=''){
		web3.personal.newAccount(query.passphrase,function(error,result){
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
var server = app.listen(8081, function () {
  var host = server.address().address
  var port = server.address().port

  console.log("Example app listening at http://%s:%s", host, port)
})