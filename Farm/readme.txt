
esh = await EshToken.deployed()

token = await CTBToken.deployed()
farm = await Farm.deployed()


100
token.mint(farm.address,'100000000000000000000')
token.mint(accounts[9],'1000000000000000000',{from:accounts[0]})

100
token.mint(accounts[1],'100000000000000000000',{from:accounts[0]})
token.mint(accounts[2],'100000000000000000000',{from:accounts[0]})

a1 = await token.balanceOf(accounts[1])
web3.utils.fromWei(a1,'ether')

100
await token.increaseAllowance(farm.address, '100000000000000000000', { from: accounts[1] })
farm.stake('100000000000000000000', { from: accounts[1] })

c = await farm.calculateRatio(accounts[1])
web3.utils.fromWei(c,'ether')

10
await token.increaseAllowance(farm.address, '10000000000000000000', { from: accounts[2] })
farm.stake('10000000000000000000', { from: accounts[2] })

t = await farm.totalPool()
web3.utils.fromWei(t,'ether')

c = await farm.calculateRatio(accounts[1])
web3.utils.fromWei(c,'ether')

r = await farm.calculateRewardPerBlock(accounts[1])
web3.utils.fromWei(r,'ether')


r = await farm.calculateRewardPerBlock(accounts[2])
web3.utils.fromWei(r,'ether')


(await farm.stakingBalance(accounts[1])).toString()


a1 = await farm.tknBalance(accounts[1])
web3.utils.fromWei(a1,'ether')

a1 = await token.balanceOf(accounts[1])
web3.utils.fromWei(a1,'ether')

t = await farm.rewardPerBlock()
web3.utils.fromWei(t,'ether')

t = await farm.currBlock()
t.toString()
web3.utils.fromWei(t,'ether')



//mint here
token.mint(farm.address,'100000000000000000000')
token.mint(farm.address,'100000000000000000000')


t1 = await farm.calculateYieldTime(accounts[1])
t1.toString()
web3.utils.fromWei(t1,'ether')

c1 = await farm.calculateYieldTotal(accounts[1])
web3.utils.fromWei(c1,'ether')

(await farm.userStart(accounts[1])).toString()
(await farm.currBlock()).toString()

w = await farm.withdrawYieldTest({ from: accounts[1] })
web3.utils.fromWei(w,'ether')

await farm.withdrawYield({ from: accounts[1] })

a1 = await token.balanceOf(accounts[1])
web3.utils.fromWei(a1,'ether')

a1 = await farm.totalUserRewards(accounts[1])
web3.utils.fromWei(a1,'ether')






s1 = await token.totalSupply()
web3.utils.fromWei(s1,'ether')

s1 = await esh.totalSupply()
web3.utils.fromWei(s1,'ether')

a1 = await esh.balanceOf(accounts[0])
web3.utils.fromWei(a1,'ether')

100
token.mint(accounts[0],'100000000000000000000',{from:accounts[0]})


100
esh.mint(accounts[1],'100000000000000000000',{from:accounts[0]})













web3.utils.toWei('1.5','ether')
