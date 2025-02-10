//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Election} from "../src/VotingElection.sol";
import {ElectionTest} from "../test/testVotingElection.t.sol";

contract DeployVotingElectionContract is Script {
    Election election;

    function run() external {
        vm.startBroadcast();
        election = new Election();
        vm.stopBroadcast();
    }
}
