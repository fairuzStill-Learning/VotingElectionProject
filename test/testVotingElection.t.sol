//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Election} from "../src/VotingElection.sol";
import {DeployVotingElectionContract} from "../script/DeployVotingElectionContract.s.sol";

contract ElectionTest is Test {
    Election election;
    // address owner = address(this);
    address public constant VOTER1 = address(1);
    address public constant VOTER2 = address(2);

    //setUp for testing the Election
    function setUp() external {
        DeployVotingElectionContract deployVotingElectionContract = new DeployVotingElectionContract();
        election = deployVotingElectionContract.run();
        
        //owner start the election
        vm.prank(election.getOwner());
        election.startElection();

        vm.startPrank(election.getOwner());
        election.addCandidate("ruz");
        election.addCandidate("jon");
        vm.stopPrank();
    }

    //test function addCandidate
    function testAddCandidate() public {
        //owner add candidate for election
        vm.startPrank(election.getOwner());
        election.addCandidate("ruz");
        election.addCandidate("jon");
        vm.stopPrank();
        console.log("berhasil menambahkan candidate");
    }

    //test function getCandidate
    function testGetCandidate() public view {
        Election.Candidate[] memory candidates = election.getCandidate(); //getCandidate inside arrays in contract Election
        assertEq(candidates.length, 2); //set candidate 2 cuz i add 2 candidate in this testing contract

        //convert string(nameCandidate) to keccak256 hash cuz,In Solidity, strings cannot be compared directly with ==
        assertEq(keccak256(bytes(candidates[0].name)), keccak256(bytes("ruz")));
        assertEq(keccak256(bytes(candidates[1].name)), keccak256(bytes("jon")));

        //set voteCount Candidate to 0
        assertEq(candidates[0].voteCount, 0);
        assertEq(candidates[1].voteCount, 0);
    }

    //test function voteCandidate(success)
    function testVoteCandidateSuccess() public {
        vm.prank(VOTER1); //VOTER1 voted to
        election.voteCandidate(0); //index 0 "ruz"
        bool hasVoted = election.getAddressHasVoted(VOTER1);
        assertEq(hasVoted, true);
        console.log(hasVoted, "1");
    }

    //test function voteCandidate when voterVoteTwice(Fail)
    function testVoterVoteTwiceFail() public {
        //VOTER1 voted to candidate 1 "jon"
        vm.prank(VOTER1);
        election.voteCandidate(1);

        vm.expectRevert();

        //and he voted again to candidate 0 "ruz"
        vm.prank(VOTER1);
        election.voteCandidate(0);
    }

    //test function voteCandidate when election not started yet/end(Fail)
    function testVoterVoteWhenElectionEnd() public {
        //owner make election end
        vm.prank(election.getOwner());
        election.endElection();

        //and voter2 try to vote when election end
        vm.prank(VOTER2);
        vm.expectRevert();
        election.voteCandidate(1);
    }

    //test function voteCandidate when voterVoteToInvalidCandidate(Fail)
    function testVoterVoteToInvalidCandidate() public {
        //VOTER1 vote to unkwon candidate
        vm.prank(VOTER1);
        vm.expectRevert();
        election.voteCandidate(99);
    }
}
