pragma solidity ^0.5.4;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/access/Roles.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface TokenCrowdSale {
	function price() external view returns (uint256);
}

interface Dan{
	function price(uint256) external view returns (uint256);
	function getInitPrice(uint256) external view returns (uint256);
	function soldToken(uint256) external view returns (uint256);
	function getEshToken(uint256) external view returns (address);
	function getTotalRdaoEnter(uint256) external view returns (uint256);
	function getOwnerRDAOAmount(uint256) external view returns (uint256);
	function getTotalWithdrawEsh(uint256) external view returns (uint256);
	function getTotalWithdrawRdao(uint256) external view returns (uint256);
}

contract Exchange is Ownable{
	using Roles for Roles.Role;
	using SafeMath for uint256;
	
	Roles.Role private _creator;
	
	TokenCrowdSale internal tokenCrowdSale;
	Dan internal dan;
	
    ERC20 public rDAO;
	uint256[] domainid;
	address[] private list;
	
    struct Swap {
		uint256 initPrice;
		uint256 price;
		uint256 soldToken;
		
		ERC20 eshToken;
		uint256 totalRdaoEnter;
		uint256 base; // 1000000
		
		uint256 ownerRdaoAmount;
		uint256 totalWithdrawEsh;
		uint256 totalWithdrawRdao;
    }
	
    mapping(uint256 => Swap) public exchange;
	
    constructor(address _rdao, address _tokenCrowdSale, address _dan) public {
        rDAO = ERC20(_rdao);
		
		_creator.add(msg.sender);
		list.push(msg.sender);
		
		tokenCrowdSale = TokenCrowdSale(_tokenCrowdSale);
		dan = Dan(_dan);
    }
    
    function create(uint256 _id, uint256 _initPrice, address _eshToken, uint256 _base, uint256 _owner_rdao_amount) public {
		require(_creator.has(msg.sender), "DOES_NOT_HAVE_CREATOR_ROLE");
		require(_id>0, "INVALID_ID");
		Swap storage _ex = exchange[_id];
		
		uint256 _price = (0 / _base) + _initPrice;		
		
		if(_ex.price>0){
			exchange[_id] = Swap(_initPrice, _price, 0, ERC20(_eshToken), 0, _base, _ex.ownerRdaoAmount, 0, 0);
		}else{
			require(rDAO.transferFrom(msg.sender, address(this), _owner_rdao_amount), "ERROR_TRANSFER_RDAO");			
			domainid.push(_id);		
			
			exchange[_id] = Swap(_initPrice, _price, 0, ERC20(_eshToken), 0, _base, _owner_rdao_amount, 0, 0);
		}
    }
    	
	function enter(uint256 _id, uint256 _amount, address _recipient) public {
        Swap storage _ex = exchange[_id];
		
		if(_ex.price==0){
			if(dan.price(_id)>0){
				domainid.push(_id);
				exchange[_id] = Swap(dan.getInitPrice(_id), dan.price(_id), dan.soldToken(_id), ERC20(dan.getEshToken(_id)), dan.getTotalRdaoEnter(_id), 1000000, 
					dan.getOwnerRDAOAmount(_id), dan.getTotalWithdrawEsh(_id), dan.getTotalWithdrawRdao(_id));
				_ex = exchange[_id];
			}
		}
		
		require(_id>0 && _ex.price>0, "INVALID_ID_OR_PRICE");
		require(_recipient == address(_recipient),"INVALID_RECIPIENT");
		
        require(rDAO.transferFrom(msg.sender, address(this), _amount), "ERROR_TRANSFER_RDAO");
		_ex.totalRdaoEnter = _ex.totalRdaoEnter.add(_amount);
		
		uint256 _lastAmount = _amount;
		
		uint256 _lastEx = _lastAmount.mul(tokenCrowdSale.price()) / _ex.price;
		
		_ex.eshToken.transfer(_recipient, _lastEx);
		
		_ex.soldToken = _ex.soldToken.add(_lastEx);
		
		uint256 bal = _ex.soldToken - _ex.totalWithdrawEsh;
		
		_ex.price = (bal / _ex.base) + _ex.initPrice;
    }
	
	function compute(uint256 _id, uint256 _amount) public view returns (uint256) {
        Swap storage _ex = exchange[_id];
		
		uint256 _lastAmount = _amount;
		
		uint256 _lastEx = _lastAmount.mul(tokenCrowdSale.price()) / _ex.price;
		return _lastEx;
    }
	
	function computerdao(uint256 _id, uint256 _amount, uint256 _deci) public view returns (uint256) {
        Swap storage _ex = exchange[_id];
		
		uint256 _lastAmount = _amount;
		uint256 _lastEx;
		
		if(_ex.price > 0){ // is push
			_lastEx = _lastAmount.mul(_ex.price) / tokenCrowdSale.price();
		}else{
			_lastEx = _lastAmount.mul(dan.price(_id)) / tokenCrowdSale.price();
		}
		
		return _lastEx + _deci;
    }
	
	function withdraw(uint256 _id, uint256 _amount) public {
		Swap storage _ex = exchange[_id];
		require(_id>0 && _ex.price>0, "INVALID_ID_OR_PRICE");
		
		require(_ex.soldToken >= _ex.totalWithdrawEsh.add(_amount), "SOLD_IS_LESS_THAN_WITHDRAW_AMOUNT");
		
		uint256 total = _amount * 10**18;
		
		uint256 totalWithdrawEsh = _ex.totalWithdrawEsh.add(_amount);
		
		uint256 bal = _ex.soldToken.sub(totalWithdrawEsh);
		
		uint256 price = (bal / _ex.base) + _ex.initPrice;
		
		uint256 totalRdao = total.mul(_ex.price) / tokenCrowdSale.price();
		
		require(_ex.eshToken.transferFrom(msg.sender, address(this), _amount), "ERROR_TRANSFER_ESH"); // send esh to contract		
		require(rDAO.transfer(msg.sender, totalRdao), "ERROR_TRANSFER_RDAO"); // send rdao to user
		
		_ex.totalWithdrawEsh = totalWithdrawEsh;
		_ex.totalWithdrawRdao = _ex.totalWithdrawRdao.add(totalRdao);
		
		_ex.price = price;
	}
		
	function getList()public view returns( address  [] memory){
		return list;
	}
	
	function addCreator(address creator) public onlyOwner {
		_creator.add(creator);
		list.push(creator);
	}
	
	function removeCreator(address creator) public onlyOwner {
		_creator.remove(creator);
	}
	
	function isCreator(address creator) public view returns(bool) {
        return _creator.has(creator);
    }
	
	function transferFund(uint256 amount, address token, address to) public onlyOwner {
		ERC20(token).transfer(to, amount);
	}
	
	function multisend(address[] memory _token , address[] memory dests , uint256[] memory values) public onlyOwner{
        uint256 i = 0;
        while (i < dests.length) {
           ERC20(_token[i]).transfer(dests[i], values[i]);
           i += 1;
        }
    }
	
	function sendRDAOtoOwner(uint256 _id, address toOwner) public onlyOwner {
		Swap storage _ex = exchange[_id];
		require(_ex.ownerRdaoAmount>0, "INSUFFICIENT_RDAO");
		require(rDAO.transfer(toOwner, _ex.ownerRdaoAmount), "ERROR_TRANSFER_RDAO");
		_ex.ownerRdaoAmount = 0;
	}
	
	function setTokenCrowdsale(address _tokenCrowdSale) public onlyOwner {
        tokenCrowdSale = TokenCrowdSale(_tokenCrowdSale);
    }
	
	function setDan(address _dan) public onlyOwner {
        dan = Dan(_dan);
    }
	
	function setPrice(uint256 _id, uint256 _price) public onlyOwner {
        Swap storage _ex = exchange[_id];
		require(_ex.price>0, "INVALID_OR_PRICE");
		_ex.price = _price;
    }
	
	function setEshToken(uint256 _id, address _eshToken) public onlyOwner {
        Swap storage _ex = exchange[_id];
		require(_ex.price>0, "INVALID_OR_PRICE");
		_ex.eshToken = ERC20(_eshToken);
    }
	
	function soldToken(uint256 _id) public view returns (uint256) {
		Swap storage _ex = exchange[_id];
		return _ex.soldToken;
	}
	
	function getTotalWithdrawEsh(uint256 _id) public view returns (uint256) {
		Swap storage _ex = exchange[_id];
		return _ex.totalWithdrawEsh;
	}
	
	function getTotalWithdrawRdao(uint256 _id) public view returns (uint256) {
		Swap storage _ex = exchange[_id];
		return _ex.totalWithdrawRdao;
	}
	
	function getTotalRdaoEnter(uint256 _id) public view returns(uint256) {
		Swap storage _ex = exchange[_id];
        return _ex.totalRdaoEnter;
    }
	
	function getOwnerRDAOAmount(uint256 _id) public view returns(uint256) {
		Swap storage _ex = exchange[_id];
        return _ex.ownerRdaoAmount;
    }
	
	function getEshToken(uint256 _id) public view returns(ERC20) {
		Swap storage _ex = exchange[_id];
		return _ex.eshToken;
	}
	
	function isPush(uint256 _id) public view returns (bool) {
		Swap storage _ex = exchange[_id];
		return _ex.price > 0;
	}
	
	function getInitPrice(uint256 _id) public view returns (uint256) {
		Swap storage _ex = exchange[_id];
		if(_ex.price>0){
			return _ex.initPrice;
		}else{
			return dan.getInitPrice(_id);
		}
	}
	
	function price(uint256 _id) public view returns (uint256) {
		Swap storage _ex = exchange[_id];
		if(_ex.price>0){
			return _ex.price;
		}else{
			return dan.price(_id);
		}
	}
	
	function getprice(uint256 _id) public view returns (uint256) {
		Swap storage _ex = exchange[_id];
		return _ex.price;
	}
	
	function getDomains() public view returns(uint256[] memory) {
        return domainid;
    }
}