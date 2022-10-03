// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "solidity-string-util/contracts/StringUtil.sol";

contract MyBallot {

    using StringUtil for string;

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

    // CONSTRUCTOR

    constructor(Candidate[] memory _candidates) {
        
        contractOwner = msg.sender;

        for (uint index = 0; index < _candidates.length; index++) {
            candidates.push(Candidate({
                name: _candidates[index].name,
                party: _candidates[index].party,
                votesCount: 0
            }));
        }
    }

        // constructor 2 // overloading constructor is not allowed
    // constructor(string[] memory proposalCandidatesName, string[] memory proposalCandidatesParty) {
        
    //     contractOwner = msg.sender;

    //     for (uint index = 0; index < proposalCandidatesName.length; index++) {
    //         candidates.push(Candidate({
    //             name: proposalCandidatesName[index],
    //             party: proposalCandidatesParty[index],
    //             votesCount: 0
    //         }));
    //     }
    // }


    // MODIFIERS

    modifier isContractOwnerAddCandidate() {
        require(
            areYouContractOwner(),
            "Only the contract owner can add candidates."
        );
        _;
    }

    modifier giveRightToVoteModifier(address voterAddress) {
        require(
            areYouContractOwner(),
            "Only the contract owner can give right to vote."
        );
        getVoterVotedRequire(voterAddress);
        _;
    }

    modifier voteModifier(address voterAddress) {
        require(
            areYouHaveRigthToVote(), 
            "You have not right to vote"
        );
        getVoterVotedRequire(voterAddress);
        _;        
    }


    // REQUIRES

    function getVoterVotedRequire(address voterAddress) private view {
        return require(
            !getVoterVoter(voterAddress),
            "Voter already voted."
        );
    }


    // FUNCTIONS

    function addCandidateWithSpreadParameters(string memory name, string memory party) public isContractOwnerAddCandidate() {
        candidates.push(Candidate({
            name: name,
            party: party,
            votesCount: 0
        }));
    }

        // when is a struct as parameter, it expects tuple which is [parameters]. Ex: ["ivy","party",0]. When is an array is like this. Ex [["ivy","party",0],[],[]]
    function addCandidateAsStruct(Candidate memory newCandidate) public isContractOwnerAddCandidate() {
        candidates.push(newCandidate);
    }
    
    function giveRightToVote(address voterAddress) public giveRightToVoteModifier(voterAddress) {
        voters[voterAddress].canVote = true;
    }

    function vote(string memory name) public voteModifier(msg.sender) {
        Voter storage sender = voters[msg.sender]; // this is to show the usage of storage | I could use directly voters[msg.sender].hasVoted
        
        for (uint index = 0; index < candidates.length; index++) {
            if (StringUtil.equalTo(candidates[index].name,name)) {
                candidates[index].votesCount++;
                sender.hasVoted = true;
                totalVotes++;
            }
        }
    }

    function getWinnerName() public view returns (string memory winnerName) {
        (uint winningProposal, bool isTie) = getWinningCandidate();
        require(
            !isTie,
            "There is a tie on Ballot"
        );
        winnerName = candidates[winningProposal].name;
    }

    function getWinningCandidate() public view returns (uint winningProposal, bool isTie) {        
        uint winningVoteCount;

        for (uint indexCandidate = 0; indexCandidate < candidates.length; indexCandidate++) {
            if (candidates[indexCandidate].votesCount > winningVoteCount) {
                winningVoteCount = candidates[indexCandidate].votesCount;
                winningProposal = indexCandidate;
                isTie = false;
            } else if (candidates[indexCandidate].votesCount == winningVoteCount) {
                isTie = true;
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
        return getVoterRigthToVote(msg.sender);
    }

    function getVoterRigthToVote(address voterAddress) public view returns (bool) {
        return voters[voterAddress].canVote;
    }

    function areYouVoted() public view returns (bool) {
        return getVoterVoter(msg.sender);
    }

    function getVoterVoter(address voterAddress) public view returns (bool) {
        return voters[voterAddress].hasVoted;
    }

    // OTHER FUNCTIONS

    // function isSameString(string memory s1, string memory s2) internal pure returns (bool) {
    //     return StringUtil.toHash(s1) == StringUtil.toHash(s2);
    // }

    // function isSameString(string memory s1, string memory s2) internal pure returns (bool) {
    //     return keccak256(abi.encode(s1)) == keccak256(abi.encode(s2));
    // }
}