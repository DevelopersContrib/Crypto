pragma solidity ^0.5.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Lottery {
	using SafeMath for uint;
    ERC20 public ERC20Token;
    address private owner;
    
    struct Lottery {
        uint price;
		uint totalPrice;
        address[] winners;
        address[] users;
		uint[] prices;
		ERC20 tokenReward;
    }

    mapping(uint => Lottery) public lotteries;
    uint public lotteriesCount;
    
    constructor(address _tokenAddress) public {
        ERC20Token = ERC20(_tokenAddress);
        owner = msg.sender;
    }
    
    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }
    
	function transferFund(uint amount) public isOwner {
		ERC20Token.transfer(owner, amount);
	}
    
    function create(uint _price,uint[] memory _prices, address _tokenAddress) public isOwner {
        lotteriesCount++;
        lotteries[lotteriesCount] = Lottery(_price, 0, new address[](0), new address[](0), _prices, ERC20(_tokenAddress));
    }
    
    function enter(uint _lotteryId, uint _entry) public {
        Lottery storage lottery = lotteries[_lotteryId];
		require(lottery.winners.length == 0 && lottery.price!=0 && _entry>0);
		
        require(ERC20Token.transferFrom(msg.sender, address(this), _entry.mul(lottery.price)));
		
		for (uint256 i = 0; i < _entry; i++) {
			lottery.totalPrice += lottery.price;
			lottery.users.push(msg.sender);
		}
    }
	
	function pickWinners(uint _lotteryId, bool _percent) public isOwner{
		Lottery storage lottery = lotteries[_lotteryId];
		require(lottery.winners.length == 0);
		
		for (uint256 i = 0; i < lottery.users.length; i++) {
			uint256 n = i + uint256(keccak256(abi.encodePacked(now))) % (lottery.users.length - i);
			address user = lottery.users[n];
			lottery.users[n] = lottery.users[i];
			lottery.users[i] = user;
			
			if(i==lottery.prices.length-1){
				break;
			}
		}
		
		for (uint256 i = 0; i < lottery.prices.length; i++) {
			lottery.winners.push(lottery.users[i]);
			
			if(_percent){
				lottery.tokenReward.transfer(lottery.users[i], lottery.totalPrice.div(lottery.prices[i]));
			}else{
				lottery.tokenReward.transfer(lottery.users[i], lottery.prices[i]);
			}
		}
    }
        
	function getUsers(uint _lotteryId) public view returns(address[] memory) {
        Lottery storage lottery = lotteries[_lotteryId];
        return lottery.users;
    }
	
	function getPrice(uint _lotteryId) public view returns(uint) {
        Lottery storage lottery = lotteries[_lotteryId];
        return lottery.price;
    }
	
	function getTotalPrice(uint _lotteryId) public view returns(uint) {
        Lottery storage lottery = lotteries[_lotteryId];
        return lottery.totalPrice;
    }
	
	function getPrices(uint _lotteryId) public view returns(uint[] memory) {
		Lottery storage lottery = lotteries[_lotteryId];
		return lottery.prices;	
	}
	
    function getWinners(uint _lotteryId) public view returns(address[] memory) {
		Lottery storage lottery = lotteries[_lotteryId];
		return lottery.winners;	
	}
	
	function getTokenReward(uint _lotteryId) public view returns(ERC20) {
		Lottery storage lottery = lotteries[_lotteryId];
		return lottery.tokenReward;	
	}
}