https://medium.com/coinmonks/yield-farming-tutorial-part-1-3fd5972ce717
https://github.com/andrew-fleming/pmkn-farm
https://docs.google.com/spreadsheets/d/1fWdNyAWKikY_tPdd2YHWYOBZT37ZhywLhvWjCh1Rob0/edit#gid=0

testnet https://testnet.bscscan.com/apidoc#blocks
https://docs.bscscan.com/api-endpoints/blocks

Get Estimated Block Countdown Time by BlockNo
https://api.bscscan.com/api?module=block&action=getblockcountdown&blockno=13489681&apikey=M74UP9WRV3NNVYZQUV8A2RV3HE7SEA67M7

https://api.bscscan.com/api?module=block&action=getblockcountdown&blockno=13489681&apikey=M74UP9WRV3NNVYZQUV8A2RV3HE7SEA67M7


Get Block Number by Timestamp
https://api.bscscan.com/api?module=block&action=getblocknobytime&timestamp=1601510400&closest=before&apikey=M74UP9WRV3NNVYZQUV8A2RV3HE7SEA67M7

const networkId = await web3.eth.net.getId();
const chainId = await web3.eth.getChainId();

esh = await EshToken.deployed()

token = await CTBToken.deployed()
farm = await Farm.deployed()

(await farm.currBlock()).toString()
(await farm.startBlock()).toString()
(await farm.getEndBlock()).toString()

900
token.mint(farm.address,'900000000000000000000')
token.mint(accounts[9],'1000000000000000000',{from:accounts[0]})

100
token.mint(accounts[1],'100000000000000000000',{from:accounts[0]})
token.mint(accounts[2],'100000000000000000000',{from:accounts[0]})
token.mint(accounts[3],'100000000000000000000',{from:accounts[0]})
token.mint(accounts[4],'100000000000000000000',{from:accounts[0]})

a1 = await token.balanceOf(accounts[1])
web3.utils.fromWei(a1,'ether')

100
await token.increaseAllowance(farm.address, '100000000000000000000', { from: accounts[1] })
farm.stake('100000000000000000000', { from: accounts[1] })

token.mint(accounts[9],'1000000000000000000',{from:accounts[0]})
token.mint(accounts[9],'1000000000000000000',{from:accounts[0]})

farm.unstake('100000000000000000000', { from: accounts[1] })
               
farm.unstake('1000000000000000000', { from: accounts[1] })
farm.unstake('98000000000000000000', { from: accounts[1] })
farm.unstake('1000000000000000000', { from: accounts[1] })

block = await web3.eth.getBlock("latest")
block.number

c = await farm.userBalance(accounts[1])
web3.utils.fromWei(c,'ether')
c = await farm.totalPool()
c.toString()
c = await farm.totalUnstake()
c.toString()



c = await farm.calculateRatio(accounts[1])
web3.utils.fromWei(c,'ether')

10
await token.increaseAllowance(farm.address, '10000000000000000000', { from: accounts[2] })
farm.stake('10000000000000000000', { from: accounts[2] })

10
await token.increaseAllowance(farm.address, '10000000000000000000', { from: accounts[3] })
farm.stake('10000000000000000000', { from: accounts[3] })

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



t = await farm.startBlock()
web3.utils.fromWei(t,'ether')


//mint here
token.mint(farm.address,'100000000000000000000')
token.mint(farm.address,'100000000000000000000')


t1 = await farm.calculateRatio(accounts[1])
t1.toString()
web3.utils.fromWei(t1,'ether')

t1 = await farm.calculateRewardPerBlock(accounts[1])
t1.toString()
web3.utils.fromWei(t1,'ether')

c1 = await farm.calculateYieldTotal(accounts[1])
c1.toString()
web3.utils.fromWei(c1,'ether')

c1 = await farm.getunstake('1000000000000000000',accounts[1])
c1.toString()

c = await farm.checkYield(accounts[1])
c.toString()
web3.utils.fromWei(c,'ether')


c = await farm.userBalance(accounts[1])
web3.utils.fromWei(c,'ether')


(await farm.userStart(accounts[1])).toString()
(await farm.currBlock()).toString()

block = await web3.eth.getBlock("latest")
block.number


await farm.withdrawYield({ from: accounts[1] })
await farm.withdrawYield({ from: accounts[2] })

a1 = await token.balanceOf(accounts[1])
web3.utils.fromWei(a1,'ether')

a1 = await farm.totalUserRewards(accounts[1])
web3.utils.fromWei(a1,'ether')

farm.unstake('1000000000000000000', { from: accounts[1] })
farm.unstake('98000000000000000000', { from: accounts[1] })

c = await farm.userBalance(accounts[1])
web3.utils.fromWei(c,'ether')
