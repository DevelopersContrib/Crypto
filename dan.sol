pragma solidity >=0.4.22 <0.6.0;

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

    function () payable external {
        emit receivedEther(msg.sender, msg.value);
    }
}

contract Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
	function transfer(address receiver, uint amount) public {
		receiver = receiver;
		amount = amount;		
	}
}

contract ContribData{
	function set(bytes32 key, address recipient, uint amount, bytes32 desc, address token, bool executed, bool cancelled) public returns(bool success) {
	}
	
	function execute(bytes32 key) public {
		key = key;
	}
	function cancel(bytes32 key) public{
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
            (bool reward, ) = address(contribData.getRecipient(key)).call.value(contribData.getAmount(key) * 1 ether)("f");
            
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