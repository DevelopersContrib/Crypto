pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Farm is Ownable{

    mapping(address => uint256) private stakingBalance;
    mapping(address => bool) private onStake;
    mapping(address => uint256) private userStartBlock;
    mapping(address => uint256) private totalUserRewards;

    IERC20 public ctbToken;
    IERC20 public tokenReward;
	
	uint256 private rewardPerBlock;
	uint256 private totalPool;
	uint256 private totalUnstake;
	
	uint256 private startBlock;
    uint256 private endBlock;
	
    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);

    constructor(
        IERC20 _ctbToken,
        IERC20 _tokenReward,
		uint256 _reward_per_block,
		uint256 _startBlock,
		uint256 _endBlock
        ) {
            ctbToken = _ctbToken;
            tokenReward = _tokenReward;
			rewardPerBlock = _reward_per_block;
			
			startBlock = _startBlock;
			endBlock = _endBlock;
        }
	
	
	
    function stake(uint256 amount) public {
		require(startBlock < block.number, "NOT_START");
		require(endBlock > block.number, "ALREADY_CLOSE");
        require(
            amount > 0 &&
            ctbToken.balanceOf(msg.sender) >= amount, 
            "You cannot stake zero tokens");
            
        if(onStake[msg.sender] == true){
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            totalUserRewards[msg.sender] += toTransfer;
        }
		
		totalPool += amount;

        ctbToken.transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] += amount;
        userStartBlock[msg.sender] = block.number;
        onStake[msg.sender] = true;
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) public {
        require(
            onStake[msg.sender] == true &&
            stakingBalance[msg.sender] >= amount, 
            "Nothing to unstake"
        );
		
        uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        userStartBlock[msg.sender] = block.number;
        uint256 balTransfer = amount;
        amount = 0;
        stakingBalance[msg.sender] -= balTransfer;
        ctbToken.transfer(msg.sender, balTransfer);
        totalUserRewards[msg.sender] += yieldTransfer;
		
        if(stakingBalance[msg.sender] == 0){
            onStake[msg.sender] = false;
			totalUserRewards[msg.sender] = 0;
			tokenReward.transfer(msg.sender, yieldTransfer);
        }
		
		totalUnstake += balTransfer;
		 
        emit Unstake(msg.sender, balTransfer);
    }
	
	function getEndBlock() public view returns(uint256){
		return endBlock;
	}
	
	function getStartBlock() public view returns(uint256){
		return startBlock;
	}
	
	function getTotalUnstake() public view returns(uint256){
		return totalUnstake;
	}
	
	function getTotalPool() public view returns(uint256){
		return totalPool;
	}
	
	function getRewardPerBlock() public view returns(uint256){
		return rewardPerBlock;
	}
	
	function isStaking(address user) public view returns(bool){
        return onStake[user];
    }
	
	function balanceOf(address user) public view returns(uint256){
        return stakingBalance[user];
    }
	
	function totalRewards(address user) public view returns(uint256){
        return totalUserRewards[user];
    }
	
	function userStart(address user) public view returns(uint256){
        return userStartBlock[user];
    }
	
	function userBalance(address user) public view returns(uint256){
        return stakingBalance[user];
    }
	
	function setEndBlock(uint256 _endBlock) public onlyOwner {
		endBlock = _endBlock;
	}
	
    function calculateYieldBlocks(address user) public view returns(uint256){
		if(onStake[user]){
			uint256 end = block.number;
			
			if(end > endBlock){
				end = endBlock;
			}
			
			uint256 total = 0;
			
			if(userStartBlock[user]>end){
				total = 0;
			}else{
				total = end - userStartBlock[user];
			}
			
			return total;
		}else{
			return 0;
		}
    }
	
	function calculateRatio(address user) public view returns(uint256){
		if(onStake[user]){
			uint256 stakeAmount = stakingBalance[user] * 10**18;
			return stakeAmount / (totalPool - totalUnstake);
		}else{
			return 0;
		}
	}
	
	function calculateRewardPerBlock(address user) public view returns(uint256){
		if(onStake[user]){
			uint256 ratio = calculateRatio(user);
			return (ratio * rewardPerBlock) / (1  * 10**18 );
		}else{
			return 0;
		}
	}

    function calculateYieldTotal(address user) public view returns(uint256) {
        uint256 countBlocks = calculateYieldBlocks(user);
				
		uint256 userRewardPerBlock = calculateRewardPerBlock(user);
		uint256 rawYield = (userRewardPerBlock * countBlocks);
		
        return rawYield;
    }

    function withdrawYield() public {
        uint256 toTransfer = calculateYieldTotal(msg.sender);
		
		require(onStake[msg.sender],"No_Stake ");
		require(stakingBalance[msg.sender]>0,"Nothing_to_withdraw");
		
        if(totalUserRewards[msg.sender] != 0){
            uint256 oldBalance = totalUserRewards[msg.sender];
            totalUserRewards[msg.sender] = 0;
            toTransfer += oldBalance;
        }

        userStartBlock[msg.sender] = block.number;
        tokenReward.transfer(msg.sender, toTransfer);
        emit YieldWithdraw(msg.sender, toTransfer);
    }
		
	function withdrawLeftOver(uint256 amount, address token, address to) public onlyOwner {
		IERC20(token).transfer(to, amount);
	}
}