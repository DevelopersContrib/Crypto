pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Farm {

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public totalUserRewards;

    IERC20 public ctbToken;
    IERC20 public tokenReward;
	
	uint256 public rewardPerBlock;
	uint256 public totalPool;
	
    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);

    constructor(
        IERC20 _ctbToken,
        IERC20 _tokenReward,
		uint256 reward_per_block
        ) {
            ctbToken = _ctbToken;
            tokenReward = _tokenReward;
			rewardPerBlock = reward_per_block;
        }

    function stake(uint256 amount) public {
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
        startTime[msg.sender] = block.number;
        isStaking[msg.sender] = true;
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) public {
        require(
            isStaking[msg.sender] = true &&
            stakingBalance[msg.sender] >= amount, 
            "Nothing to unstake"
        );
		
		totalPool -= amount;
		
        uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        startTime[msg.sender] = block.number;
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
        return startTime[user];
    }
	
	function currBlock() public view returns(uint256){
        uint256 end = block.number;
		return end;
    }
	
    function calculateYieldBlocks(address user) public view returns(uint256){
        uint256 end = block.number;
        uint256 totalTime = end - startTime[user];
        return totalTime;
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
		
		require(stakingBalance[msg.sender] && isStaking[msg.sender],"Nothing to withdraw");
		   
        if(totalUserRewards[msg.sender] != 0){
            uint256 oldBalance = totalUserRewards[msg.sender];
            totalUserRewards[msg.sender] = 0;
            toTransfer += oldBalance;
        }

        startTime[msg.sender] = block.number;
        tokenReward.transfer(msg.sender, toTransfer);
        emit YieldWithdraw(msg.sender, toTransfer);
    }
	
	function checkYield() public view returns(uint256) {
        uint256 toTransfer = calculateYieldTotal(msg.sender);
		
        if(totalUserRewards[msg.sender] != 0){
            uint256 oldBalance = totalUserRewards[msg.sender];
            toTransfer += oldBalance;
        }
		
		return toTransfer;
    }
}