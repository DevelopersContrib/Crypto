https://forum.openzeppelin.com/t/request-example-of-a-mintable-and-pausable-erc20-token/2132/2

esh = await EshToken.deployed()

supply = await esh.totalSupply()
web3.utils.fromWei(supply,'ether')

a1 = await esh.balanceOf(accounts[0])
web3.utils.fromWei(a1,'ether')

await esh.mint(accounts[2],'200000000000000000000')

a2 = await esh.balanceOf(accounts[2])
web3.utils.fromWei(a2,'ether')

await esh.burn('200000000000000000000',{from:accounts[2]})


a2 = await esh.balanceOf(accounts[1])
web3.utils.fromWei(a2,'ether')

esh.transfer(accounts[0], '200000000000000000000',{from:accounts[1]})
t1 = await esh.balanceOf(accounts[0])
web3.utils.fromWei(t1,'ether')





a1 = await esh.balanceOf('0x13a3eFff9A6464669Bc3fe472fdb7999c92e01A5')
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

bal = await token.balanceOf(lotto.address)
web3.utils.fromWei(bal,'ether')
