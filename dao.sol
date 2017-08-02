pragma solidity ^0.4.11;
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
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
        if (!t.transferFrom(_from, this, _value)) throw;
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
	Token public ctbToken;
    /* Contract Variables and events */
    uint public minimumQuorum;
    int public majorityMargin;
    Contribution[] public contributions;
    uint public numContributions;
    mapping (address => uint) public memberId;
    Member[] public members;

    event ContributionAdded(uint contributionID, address recipient, uint amount, string description);
    event Voted(uint contributionID, bool position, address voter, string justification);
    event ContributionTallied(uint contributionID, int result, uint quorum, bool active);
    event MembershipChanged(address member, bool isMember);
    event ChangeOfRules(uint minimumQuorum, int majorityMargin);
	
		
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

    /* modifier that allows only shareholders to vote and create new contributions */
    modifier onlyMembers {
        if (memberId[msg.sender] == 0)
        throw;
        _;
    }

    /* First time setup */
    function Congress(
		string brandname,
        uint minimumQuorumForContributions,
        int marginOfVotesForMajority, address congressLeader, Token addressOfCTBToken
		
    ) payable {
		name = brandname;
        changeVotingRules(minimumQuorumForContributions, marginOfVotesForMajority);
        if (congressLeader != 0) owner = congressLeader;
        // It’s necessary to add an empty first member
        addMember(0, '', '', false); 
        // and let's add the founder, to save a step later       
        addMember(owner, 'founder', 'founder',true);
		ctbToken = Token(addressOfCTBToken);
    }

    /*make member*/

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
            Member m = members[id];
			m.name = memberName;
			m.role = memberRole;
			m.canVote = memberCanVote;
			MembershipChanged(targetMember, true);
		}
	}

    function removeMember(address targetMember) onlyOwner {
        if (memberId[targetMember] == 0) throw;

        for (uint i = memberId[targetMember]; i<members.length-1; i++){
            members[i] = members[i+1];
        }
        delete members[members.length-1];
        members.length--;
    }
	
	function getMembersCount() public constant returns(uint) {
        return members.length;
    }

    /*change rules*/
    function changeVotingRules(
        uint minimumQuorumForContributions,
        int marginOfVotesForMajority
    ) onlyOwner {
        minimumQuorum = minimumQuorumForContributions;
        majorityMargin = marginOfVotesForMajority;

        ChangeOfRules(minimumQuorum, majorityMargin);
    }

    /* Function to create a new contribution */
    function newContribution(
        address beneficiary,
        uint amount,
        string JobDescription,
        bytes transactionBytecode
    )
        onlyMembers
        returns (uint contributionID)
    {
        contributionID = contributions.length++;
        Contribution p = contributions[contributionID];
        p.recipient = beneficiary;		
        p.amount = amount;
        p.description = JobDescription;
        p.contributionHash = sha3(beneficiary, amount, transactionBytecode);
        p.dateCreated = now;
        p.executed = false;
        p.contributionPassed = false;
        p.numberOfVotes = 0;
		p.createdBy = msg.sender;
        ContributionAdded(contributionID, beneficiary, amount, JobDescription);
        numContributions = contributionID+1;

        return contributionID;
    }
	
	function getContributionCount() public constant returns(uint) {
        return contributions.length;
    }

    /* function to check if a contribution code matches */
    function checkContributionCode(
        uint contributionNumber,
        address beneficiary,
        uint amount,
        bytes transactionBytecode
    )
        constant
        returns (bool codeChecksOut)
    {
        Contribution p = contributions[contributionNumber];
        return p.contributionHash == sha3(beneficiary, amount, transactionBytecode);
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
		if(!members[id].canVote) throw;
		
        Contribution p = contributions[contributionNumber];         // Get the contribution
        if (p.voted[msg.sender] == true || p.executed) throw;         // If has already voted or executed, cancel
        p.voted[msg.sender] = true;                     // Set this voter as having voted
        p.numberOfVotes++;                              // Increase the number of votes
        if (supportsContribution) {                         // If they support the contribution
            p.currentResult++;                          // Increase score
        } else {                                        // If they don't
            p.currentResult--;                          // Decrease the score
        }
        // Create a log of this event
        Voted(contributionNumber,  supportsContribution, msg.sender, justificationText);
        return p.numberOfVotes;
    }

    function executeContribution(uint contributionNumber, bytes transactionBytecode) onlyOwner {
        Contribution p = contributions[contributionNumber];
        /* Check if the contribution can be executed:
           - Has the voting deadline arrived?
           - Has it been already executed or is it being executed?
           - Does the transaction code match the contribution?
           - Has a minimum quorum?
        */
		
		
        if (p.executed
            || p.contributionHash != sha3(p.recipient, p.amount, transactionBytecode)
            || p.numberOfVotes < minimumQuorum)
            throw;

        /* execute result */
        /* If difference between support and opposition is larger than margin */
        if (p.currentResult > majorityMargin) {
            // Avoid recursive calling

            p.executed = true;
			ctbToken.transfer(p.recipient, p.amount);
            
            p.contributionPassed = true;
        } else {
            p.contributionPassed = false;
        }
        // Fire Events
        ContributionTallied(contributionNumber, p.currentResult, p.numberOfVotes, p.contributionPassed);
    }
}
