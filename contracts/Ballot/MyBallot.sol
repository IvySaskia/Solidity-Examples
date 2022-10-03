// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

// import "solidity-string-util/contracts/StringUtil.sol";

contract MyBallot {

    // using StringUtil for string;

    struct Voter {
        bool canVote;
        bool hasVoted;
    }

    struct Candidate {
        string name;
        string party;
        uint votesCount;
    }

    address public contractOwner;

    mapping(address => Voter) public voters;

    Candidate[] public candidates;

    constructor(string[] memory proposalCandidatesName, string[] memory proposalCandidatesParty) {
        
        contractOwner = msg.sender;

        for (uint index = 0; index < proposalCandidatesName.length; index++) {
            candidates.push(Candidate({
                name: proposalCandidatesName[index],
                party: proposalCandidatesParty[index],
                votesCount: 0
            }));
        }
    }

    function giveRightToVote(address voter) public {
        require(
            msg.sender == contractOwner,
            "Only the contract owner can give right to vote."
        );
        require(
            !voters[voter].hasVoted,
            "The voter already voted."
        );
        voters[voter].canVote = true;
    }

    function vote(string memory name) public {
        Voter storage sender = voters[msg.sender];
        
        require(sender.canVote, "Has no right to vote");
        require(!sender.hasVoted, "Already voted.");

        for (uint index = 0; index < candidates.length; index++) {
            if(keccak256(abi.encode(candidates[index].name)) == keccak256(abi.encode(name)))
                candidates[index].votesCount ++;
                sender.hasVoted = true;
        }
    }

    function getWinningProposal() public view returns (uint winningProposal)
    {
        uint winningVoteCount;

        for (uint indexCandidate = 0; indexCandidate < candidates.length; indexCandidate++) {
            if (candidates[indexCandidate].votesCount > winningVoteCount) {
                winningVoteCount = candidates[indexCandidate].votesCount;
                winningProposal = indexCandidate;
            }
        }
    }

    function getWinnerName() public view returns (string memory winnerName)
    {
        winnerName = candidates[getWinningProposal()].name;
    }

    function getCandidatesList() public view returns (Candidate[] memory) {
        return candidates;
    }

    function getContractAddress() public view returns (address) {
        return address(this);
    }

    function calculateAmountOfTotalVotes() public view returns (uint total) {
                
        for (uint index = 0; index < candidates.length; index++) {
            total += candidates[index].votesCount;
        }
    }
}