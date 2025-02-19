//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Election} from "../src/VotingElection.sol";
import {HelperConfig} from "./DeployConfig.s.sol";

contract DeployVotingElectionContract is Script {
    
    function run() 
        external 
        returns(Election) {
            HelperConfig helperConfig = new HelperConfig();
            address configNetwork = helperConfig.networkconfig();
            
            vm.startBroadcast();
            Election election = new Election(configNetwork);
            vm.stopBroadcast();
            return election;

        }
}
