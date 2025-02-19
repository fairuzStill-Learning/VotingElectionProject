//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error Election__notOwner();

contract Election {
    bool private s_electionActive;
    Candidate[] private s_candidates;
    address private immutable i_owner;
    AggregatorV3Interface private immutable i_priceFeed;
    mapping(address => bool) private s_hasVoted;

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    constructor(address priceFeed) {
        i_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    //startElection
    function startElection() 
        public 
        onlyOwner {
        s_electionActive = true;
    }

    //endElection
    function endElection() 
        public 
        onlyOwner {
        s_electionActive = false;
    }

    //addCandidate
    function addCandidate(string memory _name) 
        public 
        onlyOwner {
        s_candidates.push(Candidate(_name, 0));
    }

    //getCandidate
    function getCandidate() 
        public 
        view   
        returns (Candidate[] memory) {
        return s_candidates;
    }

    //getOwner
    function getOwner()
        public
        view
        returns(address) {
            return i_owner;
        }

    function getAddressHasVoted(address voter)
        public
        view
        returns(bool) {
            return s_hasVoted[voter];
        }

    //voteCandidate
    function voteCandidate(uint256 _candidateIndex) 
        public 
        onlyDuringElection 
        onlyVoteOnce {
            uint256 candidatesLength = s_candidates.length;
            require(_candidateIndex < candidatesLength, "invalid candidate index");
            s_candidates[_candidateIndex].voteCount++;
            s_hasVoted[msg.sender] = true;
    }

    //modifier onlyOwner
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert Election__notOwner();
        _;
    }

    //modifier onlyDuringElection
    modifier onlyDuringElection() {
        if (!s_electionActive) revert("Election is not started yet");
        _;
    }

    //modifier onlyVoteOnce
    modifier onlyVoteOnce() {
        if (s_hasVoted[msg.sender]) revert("you've already voted");
        _;
    }
}
