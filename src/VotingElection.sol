//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

error Election__notOwner();

contract Election {
    bool electionActive;
    Candidate[] public candidates;
    address owner;
    mapping(address => bool) hasVoted;
    mapping(address => bool) addressVoted;

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    constructor() {
        owner = msg.sender;
    }

    //startElection
    function startElection() public onlyOwner {
        electionActive = true;
    }

    //endElection
    function endElection() public onlyOwner {
        electionActive = false;
    }

    //addCandidate
    function addCandidate(string memory _name) public onlyOwner {
        candidates.push(Candidate(_name, 0));
    }

    //getCandidate
    function getCandidate() public view returns (Candidate[] memory) {
        return candidates;
    }

    //voteCandidate
    function voteCandidate(uint256 _candidateIndex) public onlyDuringElection onlyVoteOnce {
        require(_candidateIndex < candidates.length, "invalid candidate index");
        candidates[_candidateIndex].voteCount++;
        hasVoted[msg.sender] = true;
    }

    //modifier onlyOwner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Election__notOwner();
        }
        _;
    }

    //modifier onlyDuringElection
    modifier onlyDuringElection() {
        if (!electionActive) {
            revert("Election is not started yet");
        }
        _;
    }

    //modifier onlyVoteOnce
    modifier onlyVoteOnce() {
        if (hasVoted[msg.sender]) {
            revert("you've already voted");
        }
        _;
    }
}
