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

contract CTBBasic {
  uint public totalSupply;
  function balanceOf(address who) constant public returns (uint);
  function transfer(address to, uint value) public;
  event Transfer(address indexed from, address indexed to, uint value);
}
 
contract ERC20 is CTBBasic {
  function allowance(address owner, address spender) constant public returns (uint);
  function transferFrom(address from, address to, uint value) public;
  function approve(address spender, uint value) public;
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract CTBAirdropper is Ownable {

    function multisend(address _tokenAddr, address[] dests, uint256[] values)
    onlyOwner
    public returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
           ERC20(_tokenAddr).transfer(dests[i], values[i]);
           i += 1;
        }
        return(i);
    }
}
