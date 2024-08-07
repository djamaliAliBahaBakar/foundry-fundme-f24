// Deploy mock when we are in local chain
// 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.t.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_ANSWERS= 300e8; 


    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig= getOrCreateAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory)  {
        //Price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed : 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public  returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();

        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMAL, INITIAL_ANSWERS);

        vm.stopBroadcast();

        NetworkConfig memory anvilNetworkConfig = NetworkConfig({priceFeed : address(mockPriceFeed)});
        return anvilNetworkConfig;

    }

}