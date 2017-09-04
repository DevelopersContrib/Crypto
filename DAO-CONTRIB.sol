pragma solidity ^0.4.2;
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
		require (msg.sender == owner);
		_;
	}

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract tokenRecipient { 
    event receivedEther(address sender, uint amount);
    event receivedTokens(address _from, uint256 _value, address _token, bytes _extraData);

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData){
        Token t = Token(_token);
        require (!t.transferFrom(_from, this, _value));
        receivedTokens(_from, _value, _token, _extraData);
    }

    function () payable {
        receivedEther(msg.sender, msg.value);
    }
}

contract Token {
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
	function transfer(address receiver, uint amount){
		receiver = receiver;
		amount = amount;		
	}
}

contract Congress is owned, tokenRecipient {
	string public name;
    uint public minimumQuorum;
    int public majorityMargin;
    Contribution[] public contributions;
    uint public numContributions;
    mapping (address => uint) public memberId;
    Member[] public members;

    event ContributionAdded(uint contributionID, address recipient, uint amount, string description, address tokenaddress);
    event Voted(uint contributionID, bool position, address voter, string justification);
    event ContributionTallied(uint contributionID, int result, uint quorum, bool active);
    event MembershipChanged(address member, bool isMember);
    event ChangeOfRules(uint newMinimumQuorum, int newMajorityMargin);
	
		
    struct Contribution {
        address recipient;
        uint amount;
        string description;
        uint dateCreated;
        bool executed;
        bool contributionPassed;
        uint numberOfVotes;
        int currentResult;
        bytes32 contributionHash;
		address createdBy;
		address tokenaddress;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Member {
        address member;
        string name;
        uint memberSince;
		string role;
		bool canVote;
    }

    struct Vote {
        bool inSupport;
        address voter;
        string justification;
    }

    modifier onlyOwner {
		require (msg.sender == owner);
		_;
	}
	
	modifier onlyMembers {
        require(memberId[msg.sender] != 0);
        _;
    }

    function Congress(
		string brandname,
        uint minimumQuorumForContributions,
        int marginOfVotesForMajority, address congressLeader
		
    ) payable {
		name = brandname;
        changeVotingRules(minimumQuorumForContributions, marginOfVotesForMajority);
        if (congressLeader != 0) owner = congressLeader;
        addMember(0, '', '', false); 
        addMember(owner, 'founder', 'founder',true);
    }

	function addMember(address targetMember, string memberName, string memberRole, bool memberCanVote) onlyOwner {
		uint id;
		if (memberId[targetMember] == 0) {
			memberId[targetMember] = members.length;
			id = members.length++;
			members[id] = Member({member: targetMember, memberSince: now, name: memberName, role: memberRole, canVote: memberCanVote});
			MembershipChanged(targetMember, true);
		}
	}
	
	function updateMember(address targetMember, string memberName, string memberRole, bool memberCanVote) onlyOwner{
		if (memberId[targetMember] != 0) {
			uint id = memberId[targetMember];
            Member storage m = members[id];
			m.name = memberName;
			m.role = memberRole;
			m.canVote = memberCanVote;
			MembershipChanged(targetMember, true);
		}
	}

    function removeMember(address targetMember) onlyOwner {
        require (memberId[targetMember] != 0);
		
        for (uint i = memberId[targetMember]; i<members.length-1; i++){
            members[i] = members[i+1];
        }
        delete members[members.length-1];
        members.length--;
    }
	
	function getMembersCount() public constant returns(uint) {
        return members.length;
    }

    function changeVotingRules(
        uint minimumQuorumForContributions_,
        int marginOfVotesForMajority_
    ) onlyOwner {
        minimumQuorum = minimumQuorumForContributions_;
        majorityMargin = marginOfVotesForMajority_;

        ChangeOfRules(minimumQuorum, majorityMargin);
    }

    function newContribution(
        address beneficiary,
        uint amount,
        string JobDescription,
		address Tokenaddress
    )
        onlyMembers
        returns (uint contributionID)
    {
		require (memberId[beneficiary] != 0);
		
        contributionID = contributions.length++;
        Contribution storage p = contributions[contributionID];
        p.recipient = beneficiary;		
        p.amount = amount;
        p.description = JobDescription;
		p.contributionHash = sha3(beneficiary, amount);
        p.dateCreated = now;
        p.executed = false;
        p.contributionPassed = false;
		
		if(msg.sender != owner){
			p.numberOfVotes = 0;
		}else{
			p.voted[msg.sender] = true;
			p.numberOfVotes++;
			p.currentResult++;
		}
        
		p.createdBy = msg.sender;
		p.tokenaddress = Tokenaddress;
        ContributionAdded(contributionID, beneficiary, amount, JobDescription, Tokenaddress);
        numContributions = contributionID+1;

        return contributionID;
    }
	
	function getContributionCount() public constant returns(uint) {
        return contributions.length;
    }

    function checkContributionCode(
        uint contributionNumber,
        address beneficiary,
        uint amount
    )
        constant
        returns (bool codeChecksOut)
    {
        Contribution storage p = contributions[contributionNumber];
		return p.contributionHash == sha3(beneficiary, amount);
    }

    function vote(
        uint contributionNumber,
        bool supportsContribution,
        string justificationText
    )
        onlyMembers
        returns (uint voteID)
    {
		uint id = memberId[msg.sender];
		require(members[id].canVote);
		
        Contribution storage p = contributions[contributionNumber];
        require (!p.voted[msg.sender] && !p.executed);
        p.voted[msg.sender] = true;
        p.numberOfVotes++;
        if (supportsContribution) {
            p.currentResult++;
        } else { 
            p.currentResult--; 
        }
        
        Voted(contributionNumber,  supportsContribution, msg.sender, justificationText);
        return p.numberOfVotes;
    }

	function executeContribution(uint contributionNumber) onlyOwner {
        Contribution storage p = contributions[contributionNumber];
        
		require (!p.executed
              && p.contributionHash == sha3(p.recipient, p.amount)
              && p.numberOfVotes >= minimumQuorum);
        
        if (p.currentResult > majorityMargin) {
			if(p.tokenaddress==address(0)){
				require(p.recipient.call.value(p.amount * 1 ether)());
			}else{
				Token t = Token(p.tokenaddress); 
				t.transfer(p.recipient, p.amount);
			}
			p.executed = true;
            p.contributionPassed = true;
        } else {
            p.contributionPassed = false;
        }
       
        ContributionTallied(contributionNumber, p.currentResult, p.numberOfVotes, p.contributionPassed);
    }
}