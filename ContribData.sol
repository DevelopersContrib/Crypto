pragma solidity ^0.4.18;
contract owned {
    address public owner;

    function owned() public {
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

contract ContribData is owned {
	string public name;
	
	struct ContribStruct
	{
		address recipient;
        uint amount;
        bytes32 desc;
		uint date;
        bool executed;
        bool cancelled;
		address token;
		bool isData;
		address createdBy;
	}
	
	mapping(bytes32 => ContribStruct) records;
	bytes32[] recordList;
	
	event recordsaved(bytes32 key, address recipient, uint amount, bytes32 desc, address token);
	
	
	struct Member {
        address member;
        string name;
        uint memberSince;
		string role;
    }
	
	mapping (address => uint) public memberId;
	Member[] private members;
	
	event MembershipChanged(address member, bool isMember);
	
	modifier onlyMembers {
        require(memberId[msg.sender] != 0);
        _;
    }
		
	function isMember(address targetMember) public constant returns(bool success) {
		if(memberId[targetMember]!=0){
			return true;
		}else{
			return false;
		}
	}
	
	function getMemberAt(uint index) public constant returns(address member, string memberName, uint memberSince, string role) {
		require(index <= members.length);
		return(members[index].member, members[index].name,members[index].memberSince,members[index].role);
	}
	
	function getMember(address targetMember) public constant returns(address member, string memberName, uint memberSince, string role) {
		require(memberId[targetMember]!=0);
		return getMemberAt(memberId[targetMember]);
	}
		
	/**
     * Add member
     *
     * Make `targetMember` a member named `memberName`
     *
     * @param targetMember ethereum address to be added
     * @param memberName public name for that member
     */
    function saveMember(address targetMember, string memberName, string memberRole) onlyOwner public {
        uint id = memberId[targetMember];
        if (id == 0) {
            memberId[targetMember] = members.length;
            id = members.length++;
        }

        members[id] = Member({member: targetMember, memberSince: now, name: memberName, role: memberRole});
        MembershipChanged(targetMember, true);
    }

    /**
     * Remove member
     *
     * @notice Remove membership from `targetMember`
     *
     * @param targetMember ethereum address to be removed
     */
    function removeMember(address targetMember) onlyOwner public {
        require(memberId[targetMember] != 0);
		//if(memberId[targetMember]==0) throw;

        for (uint i = memberId[targetMember]; i<members.length-1; i++){
            members[i] = members[i+1];
        }
        delete members[members.length-1];
        members.length--;
    }
	
	function getMembersCount() public constant returns(uint) {
        return members.length;
    }
		
	function ContribData(string _name) public {
		name = _name;
		
		// It’s necessary to add an empty first member
        saveMember(0, "", "");
        // and let's add the founder, to save a step later
        saveMember(owner, 'founder', 'founder');
	}
	
	
	function set(
		bytes32 key, 
		address recipient, 
		uint amount, 
		bytes32 desc, 
		address token) public 
		onlyMembers
		returns(bool success) {
		
		records[key].recipient = recipient;
		records[key].amount = amount;
		records[key].desc = desc;
		records[key].date = now;
		records[key].executed = false;
		records[key].cancelled = false;
		records[key].token = token;
		records[key].isData = true;
		records[key].createdBy = msg.sender;
		recordList.push(key);
		recordsaved(key, recipient, amount, desc, token);
		
		return true;
	}
	
	function cancel(bytes32 key) public {
		require(records[key].createdBy == msg.sender);
		records[key].cancelled = true;
	}
	function execute(bytes32 key) public{
		require(records[key].createdBy == msg.sender);
		records[key].executed = true;
	}
	
	function getRecipient(bytes32 key) public constant returns(address recipient){
		return records[key].recipient;
	}
	
	function getAmount(bytes32 key) public constant returns(uint amount){
		return records[key].amount;
	}
	
	function getDescription(bytes32 key) public constant returns(bytes32 desc){
		return records[key].desc;
	}
	
	function getDate(bytes32 key) public constant returns(uint date){
		return records[key].date;
	}
	
	function getExecuted(bytes32 key) public constant returns(bool executed){
		return records[key].executed;
	}
	
	function getCancelled(bytes32 key) public constant returns(bool cancelled){
		return records[key].cancelled;
	}
	
	function getToken(bytes32 key) public constant returns(address token){
		return records[key].token;
	}
	
	function getCreatedBy(bytes32 key) public constant returns(address createdBy){
		return records[key].createdBy;
	}

	function get(bytes32 key) public constant returns(
		address recipient,
        uint amount,
        bytes32 desc,
		uint date,
        bool executed,
        bool cancelled,		
		address token) {
			return(records[key].recipient, 
				records[key].amount,
				records[key].desc,
				records[key].date,
				records[key].executed,
				records[key].cancelled,
				records[key].token
			);
	}
	
	function isData(bytes32 key) public constant returns(bool yes) {
		return records[key].isData;
	}
	
	function getKeyAt(uint row) public constant returns(bytes32 key) {
		return recordList[row];
	}
	
	function count() public	constant returns(uint recordCount) {
		return recordList.length;
	}
}
