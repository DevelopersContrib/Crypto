pragma solidity >=0.4.22 <0.6.0;

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
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
        bytes32 name;
        uint memberSince;
		bytes32 role;
    }
	
	mapping (address => uint) public memberId;
	Member[] private members;
	
	event MembershipChanged(address member, bool isMember);
	
	modifier onlyMembers {
        require(memberId[msg.sender] != 0);
        _;
    }
		
	function isMember(address targetMember) public view returns(bool exist) {
		uint id = memberId[targetMember];
		return members[id].member==targetMember;
	}
		
	function getMemberAt(uint index) public view returns(address member, bytes32 memberName, uint memberSince, bytes32 role) {
		require(index <= members.length);
		return(members[index].member, members[index].name,members[index].memberSince,members[index].role);
	}
	
	function getMember(address targetMember) public view returns(address member, bytes32 memberName, uint memberSince, bytes32 role) {
		require(memberId[targetMember]!=0);
		return getMemberAt(memberId[targetMember]);
	}
		
	
    /* Add member
     * Make `targetMember` a member named `memberName`
     * @param targetMember ethereum address to be added
     * @param memberName public name for that member
     */
    function saveMember(address targetMember, bytes32 memberName, bytes32 memberRole) onlyOwner public {
        uint id = memberId[targetMember];
        if (id == 0) {
            memberId[targetMember] = members.length;
            id = members.length++;
        }

        members[id] = Member({member: targetMember, memberSince: now, name: memberName, role: memberRole});
        emit MembershipChanged(targetMember, true);
    }
	
	function saveMembers(address[] memory targetMembers, bytes32[] memory memberNames, bytes32[] memory memberRole) onlyOwner public returns (uint256) {
        uint256 i = 0;
        while (i < targetMembers.length) {
           saveMember(targetMembers[i], memberNames[i], memberRole[i]);
           i += 1;
        }
        return(i);
    }

    
    /* Remove member
     * @notice Remove membership from `targetMember`
     * @param targetMember ethereum address to be removed
     */
    function removeMember(address targetMember) onlyOwner public {
        require(memberId[targetMember] != 0);

        for (uint i = memberId[targetMember]; i<members.length-1; i++){
            members[i] = members[i+1];
        }
        delete members[members.length-1];
        members.length--;
    }
	
	function removeMembers(address[] memory targetMembers) onlyOwner public returns (uint256) {
        uint256 i = 0;
        while (i < targetMembers.length) {
           removeMember(targetMembers[i]);
           i += 1;
        }
        return(i);
    }
	
	function getMembersCount() public view returns(uint) {
        return members.length;
    }
		
	constructor(string memory _name) public {
		name = _name;
		
		// It’s necessary to add an empty first member
        saveMember(address(0), "", "");
        // and let's add the founder, to save a step later
        saveMember(owner, 'founder', 'founder');
	}
	
	
	function set(
		bytes32 _key, 
		address _recipient, 
		uint _amount, 
		bytes32 _desc, 
		address _token,
		bool _executed,
		bool _cancelled) public 
		onlyMembers
		returns(bool success) {
		
		records[_key].recipient = _recipient;
		records[_key].amount = _amount;
		records[_key].desc = _desc;
		records[_key].date = now;
		records[_key].executed = _executed;
		records[_key].cancelled = _cancelled;
		records[_key].token = _token;
		records[_key].isData = true;
		records[_key].createdBy = msg.sender;
		recordList.push(_key);
		emit recordsaved(_key, _recipient, _amount, _desc, _token);
		
		return true;
	}
	
	function bulkSet(
		bytes32[] memory _key,
		address[] memory _recipient,
		uint[] memory _amount,
		bytes32[] memory _desc,
		address[] memory _token,
		bool[] memory _executed,
		bool[] memory _cancelled) onlyOwner public returns (uint256) {
        uint256 i = 0;
        while (i < _key.length) {
           set(_key[i], _recipient[i], _amount[i], _desc[i], _token[i], _executed[i], _cancelled[i]);
           i += 1;
        }
        return(i);
    }
	
	function cancel(bytes32 key) public {
		require(records[key].createdBy == msg.sender);
		records[key].cancelled = true;
	}
	function bulkCancel(bytes32[] memory _key) public returns (uint256) {
		uint256 i = 0;
        while (i < _key.length) {
           cancel(_key[i]);
           i += 1;
        }
        return(i);
	}
	
	function execute(bytes32 key) public{
		require(records[key].createdBy == msg.sender);
		records[key].executed = true;
	}
	function bulkExecute(bytes32[] memory _key) public returns (uint256) {
		uint256 i = 0;
        while (i < _key.length) {
           execute(_key[i]);
           i += 1;
        }
        return(i);
	}
	
	function getRecipient(bytes32 key) public view returns(address _recipient){
		return records[key].recipient;
	}
	
	function getAmount(bytes32 key) public view returns(uint _amount){
		return records[key].amount;
	}
	
	function getDescription(bytes32 key) public view returns(bytes32 _desc){
		return records[key].desc;
	}
	
	function getDate(bytes32 key) public view returns(uint _date){
		return records[key].date;
	}
	
	function getExecuted(bytes32 key) public view returns(bool _executed){
		return records[key].executed;
	}
	
	function getCancelled(bytes32 key) public view returns(bool _cancelled){
		return records[key].cancelled;
	}
	
	function getToken(bytes32 key) public view returns(address _token){
		return records[key].token;
	}
	
	function getCreatedBy(bytes32 key) public view returns(address createdBy){
		return records[key].createdBy;
	}

	function get(bytes32 key) public view returns(
		address _recipient,
        uint _amount,
        bytes32 _desc,
		uint _date,
        bool _executed,
        bool _cancelled,		
		address _token) {
			return(records[key].recipient, 
				records[key].amount,
				records[key].desc,
				records[key].date,
				records[key].executed,
				records[key].cancelled,
				records[key].token
			);
	}
	
	function isData(bytes32 key) public view returns(bool yes) {
		return records[key].isData;
	}
	
	function getKeyAt(uint row) public view returns(bytes32 key) {
		return recordList[row];
	}
	
	function count() public	view returns(uint recordCount) {
		return recordList.length;
	}
}