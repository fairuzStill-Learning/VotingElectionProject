//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Election} from "../src/VotingElection.sol";

contract ElectionTest is Test {
    Election election;
    // address owner = address(this);
    address voter1 = address(0x123);
    address voter2 = address(0x456);

    //setUp for testing the Election
    function setUp() external {
        //make new Election for this contract
        election = new Election();

        //owner start the election
        vm.prank(election.getOwner());
        election.startElection();

        election.addCandidate("ruz");
        election.addCandidate("jon");
    }

    //test function addCandidate
    function testAddCandidate() public {
        //owner add candidate for election
        vm.prank(election.getOwner());
        election.addCandidate("ruz");
        election.addCandidate("jon");
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
        vm.prank(voter1); //voter1 voted to
        election.voteCandidate(0); //index 0 "ruz"
        bool hasVoted = election.getAddressHasVoted(voter1);
        assertEq(hasVoted, true);
        console.log(hasVoted, "1");
    }

    //test function voteCandidate when voterVoteTwice(Fail)
    function testVoterVoteTwiceFail() public {
        //voter1 voted to candidate 1 "jon"
        vm.prank(voter1);
        election.voteCandidate(1);

        vm.expectRevert();

        //and he voted again to candidate 0 "ruz"
        vm.prank(voter1);
        election.voteCandidate(0);
    }

    //test function voteCandidate when election not started yet/end(Fail)
    function testVoterVoteWhenElectionEnd() public {
        //owner make election end
        vm.prank(election.getOwner());
        election.endElection();

        //and voter2 try to vote when election end
        vm.prank(voter2);
        vm.expectRevert();
        election.voteCandidate(1);
    }

    //test function voteCandidate when voterVoteToInvalidCandidate(Fail)
    function testVoterVoteToInvalidCandidate() public {
        //voter1 vote to unkwon candidate
        vm.prank(voter1);
        vm.expectRevert();
        election.voteCandidate(99);
    }
}
