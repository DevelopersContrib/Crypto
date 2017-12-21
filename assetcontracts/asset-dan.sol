pragma solidity ^0.4.18;
contract owned {
    address public owner;

    function owned() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
		require (msg.sender == owner);
		_;
	}

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract tokenRecipient {
    event receivedEther(address sender, uint amount);
    event receivedTokens(address _from, uint256 _value, address _token, bytes _extraData);

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public{
        Token t = Token(_token);
        require (t.transferFrom(_from, this, _value));
        receivedTokens(_from, _value, _token, _extraData);
    }

    function () payable public {
        receivedEther(msg.sender, msg.value);
    }
}

contract Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
	function transfer(address receiver, uint amount) public pure {
		receiver = receiver;
		amount = amount;		
	}
}

contract ContribData{
	function set(bytes32 key, address recipient, uint amount, bytes32 desc, address token, bool executed, bool cancelled) public pure returns(bool success) {
	}
	
	function execute(bytes32 key) public pure{
		key = key;
	}
	function cancel(bytes32 key) public pure{
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
    function ContribDao(
		string brandname,
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
		public onlyOwner
        returns (bool success)
    {	
		require(contribData.isMember(beneficiary) && !contribData.isData(key));

		contribData.set(key, beneficiary, amount, desc, tokenAddress, false, false);
		
		ContributionAdded(key, beneficiary, amount, desc, tokenAddress);
        return true;
    }
	
	function execute(bytes32 key) public onlyOwner returns (bool success){
        require(contribData.isData(key) && contribData.isMember(contribData.getRecipient(key)));
		
		require(!contribData.getExecuted(key) && !contribData.getCancelled(key));
       
		if(contribData.getToken(key)==address(0)){
			require(contribData.getRecipient(key).call.value(contribData.getAmount(key) * 1 ether)());
			
		}else{
			Token t = Token(contribData.getToken(key)); 
			t.transfer(contribData.getRecipient(key), contribData.getAmount(key));
		}
		
		contribData.execute(key);
		// Fire Events
		ContributionTallied(key);
		return true;
    }
	
	function createExecute(
		bytes32 key,
        address beneficiary,
        uint amount,
        bytes32 desc,
		address tokenAddress
    )
		public onlyOwner
        returns (bool success)
    {	
		if(create(key, beneficiary, amount, desc, tokenAddress))
			execute(key);
		return true;
	}
	
	function cancel(bytes32 key) public onlyOwner {
		require(contribData.isData(key));
	
		contribData.cancel(key);
	}
}
