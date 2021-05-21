https://gist.github.com/uu-z/f4161378882a62bad9c658715608f8b8
https://forum.openzeppelin.com/t/how-to-use-a-token-transfer-function-into-another-function-erc20/2214/6
https://forum.openzeppelin.com/t/can-not-call-the-function-approve-of-the-usdt-contract/2130/2
https://ethereum.stackexchange.com/questions/52159/lottery-contract-for-an-erc20-token
source: https://gist.github.com/uu-z/f4161378882a62bad9c658715608f8b8



token = await rDAO.deployed()

lotto = await Lottery.deployed()

esh = await EshToken.deployed()

// set 100 token price
await lotto.create('100000000000000000000',[2,4,5],token.address)

a1 = await token.balanceOf(accounts[0])
web3.utils.fromWei(a1,'ether')


// send 2000 tokens to users
token.transfer(lotto.address, '2000000000000000000000',{from:accounts[0]})
lottoRewardBal = await token.balanceOf(lotto.address)
web3.utils.fromWei(lottoRewardBal,'ether')

lottoToken = await token.balanceOf(lotto.address)
web3.utils.fromWei(lottoToken,'ether')

t0 = await token.balanceOf(accounts[0])
web3.utils.fromWei(t0,'ether')

// send 100 tokens to users
token.transfer(accounts[1], '200000000000000000000',{from:accounts[0]})
t1 = await token.balanceOf(accounts[1])
web3.utils.fromWei(t1,'ether')

token.transfer(accounts[2], '100000000000000000000',{from:accounts[0]})
t2 = await token.balanceOf(accounts[2])
web3.utils.fromWei(t2,'ether')

token.transfer(accounts[3], '100000000000000000000',{from:accounts[0]})
t3 = await token.balanceOf(accounts[3])
web3.utils.fromWei(t3,'ether')

token.transfer(accounts[4], '100000000000000000000',{from:accounts[0]})
t4 = await token.balanceOf(accounts[4])
web3.utils.fromWei(t4,'ether')

token.transfer(accounts[5], '200000000000000000000',{from:accounts[0]})
t5 = await token.balanceOf(accounts[5])
web3.utils.fromWei(t5,'ether')

// set 100/200 allowance
await token.increaseAllowance(lotto.address, '200000000000000000000', { from: accounts[1] })
await token.increaseAllowance(lotto.address, '100000000000000000000', { from: accounts[2] })
await token.increaseAllowance(lotto.address, '100000000000000000000', { from: accounts[3] })
await token.increaseAllowance(lotto.address, '100000000000000000000', { from: accounts[4] })
await token.increaseAllowance(lotto.address, '200000000000000000000', { from: accounts[5] })

//check allowance
(await token.allowance(accounts[1],lotto.address)).toString()

await token.increaseAllowance(lotto.address, '100000000000000000000', { from: accounts[0] })
await lotto.enter(1,1,{from:accounts[0]})

await lotto.enter(1,2,{from:accounts[1]})
await lotto.enter(1,1,{from:accounts[2]})
await lotto.enter(1,1,{from:accounts[3]})
await lotto.enter(1,1,{from:accounts[4]})
await lotto.enter(1,2,{from:accounts[5]})

await lotto.enter(9,{from:accounts[5]})

bal = await token.balanceOf(lotto.address)
web3.utils.fromWei(bal,'ether')

await lotto.getUsers(1)
(await lotto.lotteriesCount()).toString()
(await lotto.getPrice(1)).toString()
price = await lotto.getPrice(1)
web3.utils.fromWei(price,'ether')

await lotto.getTokenReward(1)

await lotto.getPrices(1)

totalPrice = await lotto.getTotalPrice(1)
web3.utils.fromWei(totalPrice,'ether')

await lotto.pickWinners(1,true)

await lotto.getWinners(1)

await lotto.transferFund('2035000000000000000000')

