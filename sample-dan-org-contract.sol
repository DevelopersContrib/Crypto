 
Sample dao contract : 
 
Shareholders contract
Multisig contract
pragma solidity ^0.4.2;
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
}

contract Congress is owned, tokenRecipient {

    /* Contract Variables and events */
    uint public minimumQuorum;
    uint public debatingPeriodInMinutes;
    int public majorityMargin;
    Proposal[] public proposals;
    uint public numProposals;
    mapping (address => uint) public memberId;
    Member[] public members;

    event ProposalAdded(uint proposalID, address recipient, uint amount, string description);
    event Voted(uint proposalID, bool position, address voter, string justification);
    event ProposalTallied(uint proposalID, int result, uint quorum, bool active);
    event MembershipChanged(address member, bool isMember);
    event ChangeOfRules(uint minimumQuorum, uint debatingPeriodInMinutes, int majorityMargin);

    struct Proposal {
        address recipient;
        uint amount;
        string description;
        uint votingDeadline;
        bool executed;
        bool proposalPassed;
        uint numberOfVotes;
        int currentResult;
        bytes32 proposalHash;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Member {
        address member;
        string name;
        uint memberSince;
    }

    struct Vote {
        bool inSupport;
        address voter;
        string justification;
    }

    /* modifier that allows only shareholders to vote and create new proposals */
    modifier onlyMembers {
        if (memberId[msg.sender] == 0)
        throw;
        _;
    }

    /* First time setup */
    function Congress(
        uint minimumQuorumForProposals,
        uint minutesForDebate,
        int marginOfVotesForMajority, address congressLeader
    ) payable {
        changeVotingRules(minimumQuorumForProposals, minutesForDebate, marginOfVotesForMajority);
        if (congressLeader != 0) owner = congressLeader;
        // It’s necessary to add an empty first member
        addMember(0, ''); 
        // and let's add the founder, to save a step later       
        addMember(owner, 'founder');        
    }

    /*make member*/
    function addMember(address targetMember, string memberName) onlyOwner {
        uint id;
        if (memberId[targetMember] == 0) {
           memberId[targetMember] = members.length;
           id = members.length++;
           members[id] = Member({member: targetMember, memberSince: now, name: memberName});
        } else {
            id = memberId[targetMember];
            Member m = members[id];
        }

        MembershipChanged(targetMember, true);
    }

    function removeMember(address targetMember) onlyOwner {
        if (memberId[targetMember] == 0) throw;

        for (uint i = memberId[targetMember]; i<members.length-1; i++){
            members[i] = members[i+1];
        }
        delete members[members.length-1];
        members.length--;
    }

    /*change rules*/
    function changeVotingRules(
        uint minimumQuorumForProposals,
        uint minutesForDebate,
        int marginOfVotesForMajority
    ) onlyOwner {
        minimumQuorum = minimumQuorumForProposals;
        debatingPeriodInMinutes = minutesForDebate;
        majorityMargin = marginOfVotesForMajority;

        ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, majorityMargin);
    }

    /* Function to create a new proposal */
    function newProposal(
        address beneficiary,
        uint etherAmount,
        string JobDescription,
        bytes transactionBytecode
    )
        onlyMembers
        returns (uint proposalID)
    {
        proposalID = proposals.length++;
        Proposal p = proposals[proposalID];
        p.recipient = beneficiary;
        p.amount = etherAmount;
        p.description = JobDescription;
        p.proposalHash = sha3(beneficiary, etherAmount, transactionBytecode);
        p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
        p.executed = false;
        p.proposalPassed = false;
        p.numberOfVotes = 0;
        ProposalAdded(proposalID, beneficiary, etherAmount, JobDescription);
        numProposals = proposalID+1;

        return proposalID;
    }

    /* function to check if a proposal code matches */
    function checkProposalCode(
        uint proposalNumber,
        address beneficiary,
        uint etherAmount,
        bytes transactionBytecode
    )
        constant
        returns (bool codeChecksOut)
    {
        Proposal p = proposals[proposalNumber];
        return p.proposalHash == sha3(beneficiary, etherAmount, transactionBytecode);
    }

    function vote(
        uint proposalNumber,
        bool supportsProposal,
        string justificationText
    )
        onlyMembers
        returns (uint voteID)
    {
        Proposal p = proposals[proposalNumber];         // Get the proposal
        if (p.voted[msg.sender] == true) throw;         // If has already voted, cancel
        p.voted[msg.sender] = true;                     // Set this voter as having voted
        p.numberOfVotes++;                              // Increase the number of votes
        if (supportsProposal) {                         // If they support the proposal
            p.currentResult++;                          // Increase score
        } else {                                        // If they don't
            p.currentResult--;                          // Decrease the score
        }
        // Create a log of this event
        Voted(proposalNumber,  supportsProposal, msg.sender, justificationText);
        return p.numberOfVotes;
    }

    function executeProposal(uint proposalNumber, bytes transactionBytecode) {
        Proposal p = proposals[proposalNumber];
        /* Check if the proposal can be executed:
           - Has the voting deadline arrived?
           - Has it been already executed or is it being executed?
           - Does the transaction code match the proposal?
           - Has a minimum quorum?
        */

        if (now < p.votingDeadline
            || p.executed
            || p.proposalHash != sha3(p.recipient, p.amount, transactionBytecode)
            || p.numberOfVotes < minimumQuorum)
            throw;

        /* execute result */
        /* If difference between support and opposition is larger than margin */
        if (p.currentResult > majorityMargin) {
            // Avoid recursive calling

            p.executed = true;
            if (!p.recipient.call.value(p.amount * 1 ether)(transactionBytecode)) {
                throw;
            }

            p.proposalPassed = true;
        } else {
            p.proposalPassed = false;
        }
        // Fire Events
        ProposalTallied(proposalNumber, p.currentResult, p.numberOfVotes, p.proposalPassed);
    }
}
