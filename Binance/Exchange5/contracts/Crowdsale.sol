pragma solidity ^0.5.4;

contract Crowdsale {
	uint256 current_price;
	
    constructor(uint256 _price) public {
        current_price = _price;
    }
    
	function price() public view returns (uint256) {
		return current_price;
	}
	
	function setPrice(uint256 _price) public {
        current_price = _price;
    }
}