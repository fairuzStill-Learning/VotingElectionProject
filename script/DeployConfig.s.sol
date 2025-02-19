//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public networkconfig;
    uint256 constant SEPOLIA_CHAIN_ID = 1155111;
    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig{
        address priceFeed;
    }

    constructor() {
        if(block.chainid == SEPOLIA_CHAIN_ID){
            networkconfig = configToSepolia();
        } else {
            networkconfig = configToAnvil();
        }
    }

    function configToSepolia()
        public
        pure
        returns(NetworkConfig memory) {
            NetworkConfig memory sepoliaNetwork = NetworkConfig(
                {priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
            return sepoliaNetwork;
        }

    function configToAnvil()
        public
        returns(NetworkConfig memory) {
            if(networkconfig.priceFeed != address(0)) {
                return networkconfig;
            }

            vm.startBroadcast();
            MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
            vm.stopBroadcast();

            NetworkConfig memory anvilNetwork = NetworkConfig({priceFeed: address(mockV3Aggregator)});
            return anvilNetwork;
            
        }
}