pragma solidity ^0.6.2;

/**
 * @dev Interface of the DAO standard as defined in the EIP.
 * REALTYDAO DAO contract, 10/09/2020
 * RealtyDao.com
 * SPDX-License-Identifier: MIT license
 */

contract owned {
    address public owner;

    constructor() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
		require (msg.sender == owner);
		_;
	}

    function transferOwnership(address newOwner) onlyOwner public  {
        owner = newOwner;
    }
}

contract tokenRecipient {
    event receivedEther(address sender, uint amount);
    event receivedTokens(address _from, uint256 _value, address _token, bytes _extraData);

    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public{
        Token t = Token(_token);
        require (t.transferFrom(_from, address(this), _value));
        emit receivedTokens(_from, _value, _token, _extraData);
    }

    receive() external payable {
            emit receivedEther(msg.sender, msg.value);
        }
    
    
}

interface Token {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ContribData{
	function set(bytes32 key, address recipient, uint amount, bytes32 desc, address token, bool executed, bool cancelled) public returns(bool success) {
	}
	
	function execute(bytes32 key) public pure  {
		key = key;
	}
	function cancel(bytes32 key) public pure  {
		key = key;
	}

	function isData(bytes32 key) public  returns(bool yes) {
	}
	
	function getRecipient(bytes32 key) public  returns(address _recipient){
	}
	function getAmount(bytes32 key) public  returns(uint _amount){
	}

	function getExecuted(bytes32 key) public  returns(bool _executed){
	}
	function getCancelled(bytes32 key) public  returns(bool _cancelled){
	}
	function getToken(bytes32 key) public  returns(address _token){
	}
	
	function isMember(address targetMember) public  returns(bool _success) {
	}
}

contract ContribDao is owned, tokenRecipient {
/* Contract Variables and events */
	string public name;
	ContribData private contribData;
	address public addressOfContribData;
	
    event ContributionAdded(bytes32 key, address recipient, uint amount, bytes32 desc, address token);
    event ContributionTallied(bytes32 key);
	
/* First time setup */
    constructor(
		string memory brandname,
		address _addressOfContribData
		
    ) payable public {
		name = brandname;
		UpdateContribData(_addressOfContribData);
    }
	
	function UpdateContribData(address _addressOfContribData) public{
		addressOfContribData = _addressOfContribData;
		contribData = ContribData(addressOfContribData);
	}
		
/* Function to create a new contribution */
    function create(
		bytes32 key,
        address beneficiary,
        uint amount,
        bytes32 desc,
		address tokenAddress
    )
		onlyOwner public 
        returns (bool success)
    {	
		require(contribData.isMember(beneficiary) && !contribData.isData(key));

		contribData.set(key, beneficiary, amount, desc, tokenAddress, false, false);
		
		emit ContributionAdded(key, beneficiary, amount, desc, tokenAddress);
        return true;
    }
	
	function execute(bytes32 key) onlyOwner public  returns (bool success){
        require(contribData.isData(key) && contribData.isMember(contribData.getRecipient(key)));
		
		require(!contribData.getExecuted(key) && !contribData.getCancelled(key));
       
		if(contribData.getToken(key)==address(0)){
            (bool reward, ) = address(contribData.getRecipient(key)).call{value:contribData.getAmount(key) * 1 ether}("f");
            
			require(reward);
		}else{
			Token t = Token(contribData.getToken(key)); 
			t.transfer(contribData.getRecipient(key), contribData.getAmount(key));
		}
		
		contribData.execute(key);
		// Fire Events
		emit ContributionTallied(key);
		return true;
    }
	
	function createExecute(
		bytes32 key,
        address beneficiary,
        uint amount,
        bytes32 desc,
		address tokenAddress
    )
		onlyOwner public 
        returns (bool success)
    {	
		if(create(key, beneficiary, amount, desc, tokenAddress))
			execute(key);
		return true;
	}
	
	function cancel(bytes32 key) onlyOwner public  {
		require(contribData.isData(key));
	
		contribData.cancel(key);
	}
}