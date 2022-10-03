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

    uint public totalVotes; // alternative for calculateAmountOfTotalVotes

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

    // modifiers

    modifier isContractOwnerRightToVote() {
        require(
            areYouContractOwner(),
            "Only the contract owner can give right to vote."
        );
        _;
    }

    modifier isVoterVote(address voter) {
        require(
            !voters[voter].hasVoted,
            "Voter already voted."
        );
        _;
    }

    modifier hasRightToVote() {
        require(areYouHaveRigthToVote(), "You have not right to vote");
        _;
    }


    // functions

    function giveRightToVote(address voter) public isContractOwnerRightToVote() isVoterVote(voter) {
        voters[voter].canVote = true;
    }

    function vote(string memory name) public isVoterVote(msg.sender) hasRightToVote(){
        Voter storage sender = voters[msg.sender]; // this is to show the usage of storage | I could use directly voters[msg.sender].hasVoted
        
        for (uint index = 0; index < candidates.length; index++) {
            if (keccak256(abi.encode(candidates[index].name)) == keccak256(abi.encode(name)))
                candidates[index].votesCount++;
                sender.hasVoted = true;
                totalVotes++;
        }
    }

    function getWinnerName() public view returns (string memory winnerName) {
        winnerName = candidates[getWinningCandidate()].name;
    }

    function getWinningCandidate() public view returns (uint winningProposal) {
        uint winningVoteCount;

        for (uint indexCandidate = 0; indexCandidate < candidates.length; indexCandidate++) {
            if (candidates[indexCandidate].votesCount > winningVoteCount) {
                winningVoteCount = candidates[indexCandidate].votesCount;
                winningProposal = indexCandidate;
            }
        }
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

    function areYouContractOwner() public view returns (bool) {
        return msg.sender == contractOwner;
    }

    function areYouHaveRigthToVote() public view returns (bool) {
        return isAnyoneHaveRigthToVote(msg.sender);
    }

    function isAnyoneHaveRigthToVote(address voter) public view returns (bool) {
        return voters[voter].canVote;
    }
}