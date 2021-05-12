pragma solidity ^0.5.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange {
	using SafeMath for uint;
    ERC20 public rDAO;
    address private owner;
	uint[] domainid;
	
    struct Swap {
        uint rate;
		ERC20 eshToken;
		uint rdaoAmount;
    }

    mapping(uint => Swap) public exchange;
    uint public swapCount;
	
    constructor(address _rdao) public {
        rDAO = ERC20(_rdao);
        owner = msg.sender;
    }
    
    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }
    
	function transferFund(uint amount, address token) public isOwner {
		ERC20(token).transfer(owner, amount);
	}
    
    function create(uint _id, uint _rate, address _eshToken) public isOwner {
		require(_id>0);
		swapCount++;
        exchange[_id] = Swap(_rate, ERC20(_eshToken), 0);
		domainid.push(_id);
    }
    
    function enter(uint _id, uint _amount) public {
        Swap storage _ex = exchange[_id];
		require(_id>0 && _ex.rate>0);
		
        require(rDAO.transferFrom(msg.sender, address(this), _amount));
		_ex.rdaoAmount = _ex.rdaoAmount.add(_amount);
		
		_amount = (_amount * 10**18);
		
		uint256 lastEx = _amount.div(_ex.rate);
		
		_ex.eshToken.transfer(msg.sender, lastEx);
    }
	
	function setRate(uint _id, uint _rate) public isOwner {
        Swap storage _ex = exchange[_id];
		require(_ex.rate>0 && _rate>0);
		_ex.rate = _rate;
    }
	
	function setEshToken(uint _id, address _eshToken) public isOwner {
        Swap storage _ex = exchange[_id];
		require(_ex.rate>0);
		_ex.eshToken = ERC20(_eshToken);
    }
	
	function getEshToken(uint _id) public view returns(ERC20) {
		Swap storage _ex = exchange[_id];
		return _ex.eshToken;	
	}
	
	function getRate(uint _id) public view returns(uint) {
        Swap storage _ex = exchange[_id];
        return _ex.rate;
    }
	
	function getRDAO(uint _id) public view returns(uint) {
        Swap storage _ex = exchange[_id];
        return _ex.rdaoAmount;
    }
	
	function getDomains() public view returns(uint[] memory) {
        return domainid;
    }
	
}