pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
contract Ownable {
  address public owner;

  function Ownable() public{
    owner = msg.sender;
  }
 
  modifier onlyOwner() {
    if (msg.sender != owner) {
      revert();
    }
    _;
  }
 
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

contract CTBToken {
	function transfer(address to, uint value) public;
}

contract CTBAirdropper is Ownable {

    function multisend(address _tokenAddr, address[] dests, uint256[] values)
    onlyOwner
    public returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
           CTBToken(_tokenAddr).transfer(dests[i], values[i]);
           i += 1;
        }
        return(i);
    }
}
