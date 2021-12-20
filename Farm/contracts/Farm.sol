pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Farm is Ownable{

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public userStartBlock;
    mapping(address => uint256) public totalUserRewards;

    IERC20 public ctbToken;
    IERC20 public tokenReward;
	
	uint256 public rewardPerBlock;
	uint256 public totalPool;
	uint256 public totalUnstake;
	
	uint256 public startBlock;
    uint256 public endBlock;
	
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
	
	function setEndBlock(uint256 _endBlock) public onlyOwner {
		endBlock = _endBlock;
	}
	
    function stake(uint256 amount) public {
		require(startBlock < block.number, "NOT_START");
		require(endBlock > block.number, "ALREADY_CLOSE");
        require(
            amount > 0 &&
            ctbToken.balanceOf(msg.sender) >= amount, 
            "You cannot stake zero tokens");
            
        if(isStaking[msg.sender] == true){
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            totalUserRewards[msg.sender] += toTransfer;
        }
		
		totalPool += amount;

        ctbToken.transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] += amount;
        userStartBlock[msg.sender] = block.number;
        isStaking[msg.sender] = true;
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) public {
        require(
            isStaking[msg.sender] == true &&
            stakingBalance[msg.sender] >= amount, 
            "Nothing to unstake"
        );
		
		totalUnstake += amount;
		
        uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        userStartBlock[msg.sender] = block.number;
        uint256 balTransfer = amount;
        amount = 0;
        stakingBalance[msg.sender] -= balTransfer;
        ctbToken.transfer(msg.sender, balTransfer);
        totalUserRewards[msg.sender] += yieldTransfer;
		
        if(stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
        }
		
        emit Unstake(msg.sender, balTransfer);
    }
	
	
	function userStart(address user) public view returns(uint256){
        return userStartBlock[user];
    }
	
	function userBalance(address user) public view returns(uint256){
        return stakingBalance[user];
    }
	
	function currBlock() public view returns(uint256){
        return block.number;
    }
	
    function calculateYieldBlocks(address user) public view returns(uint256){
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
    }
	
	function calculateRatio(address user) public view returns(uint256){
		uint256 stakeAmount = stakingBalance[user] * 10**18;
		return stakeAmount / totalPool;
	}
	
	function calculateRewardPerBlock(address user) public view returns(uint256){
		uint256 ratio = calculateRatio(user);
		return (ratio * rewardPerBlock) / (1  * 10**18 );
	}

    function calculateYieldTotal(address user) public view returns(uint256) {
        uint256 countBlocks = calculateYieldBlocks(user);
				
		uint256 userRewardPerBlock = calculateRewardPerBlock(user);
		uint256 rawYield = (userRewardPerBlock * countBlocks);
		
        return rawYield;
    }

    function withdrawYield() public {
        uint256 toTransfer = calculateYieldTotal(msg.sender);
		
		require(isStaking[msg.sender],"No_Stake ");
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