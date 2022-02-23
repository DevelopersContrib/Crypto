pragma solidity ^0.5.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Voting {
	
    ERC20 public token;
	uint256[] domainid;
	address[] private list;
	
	struct Voter {
		bool vote;
		bool voted;
	}
	
	struct Domain {
		uint256 voteCount;		
		mapping (address => Voter) voter;		
		address[] voters;
    }
	
    mapping(uint256 => Domain) private domain;
	
    constructor() public {
		
    }
	
    function castVote(uint256 _id, bool _vote) public {
		require(_id>0, "INVALID_ID");
        
		Domain storage _domain = domain[_id];
		
		if(_domain.voteCount==0){
			domainid.push(_id);
		}
		
		if(!_domain.voter[msg.sender].voted){
			_domain.voters.push(msg.sender);
		}
		
		_domain.voter[msg.sender].voted = true;
		_domain.voter[msg.sender].vote = _vote;
		
		_domain.voteCount += 1;
    }
	
	function getVote(uint256 _id, address _account) public view returns (bool) {
		Domain storage _domain = domain[_id];	
		return _domain.voter[_account].vote;
	}
	
	function voted(uint256 _id, address _account) public view returns(bool) {
		Domain storage _domain = domain[_id];
		return _domain.voter[_account].voted;
	}
	
	function getVoteCount(uint256 _id) public view returns (uint256) {
		Domain storage _domain = domain[_id];	
		return _domain.voteCount;
	}
	
	function getVoters(uint256 _id) public view returns(address[] memory) {
		Domain storage _domain = domain[_id];
        return _domain.voters;
    }
	
	function getDomains() public view returns(uint256[] memory) {
        return domainid;
    }
}