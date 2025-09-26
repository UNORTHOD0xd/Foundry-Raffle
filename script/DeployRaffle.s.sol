// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Script } from "forge-std/Script.sol";
import { Raffle } from "../src/Raffle.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { CreateSubscription, FundSubscription, AddConsumer } from "./Interactions.s.sol";

/**
 * @notice This script deploys the Raffle contract using network-specific configurations
 * @dev It retrieves configurations from HelperConfig and handles subscription creation and funding if necessary
 */
contract DeployRaffle is Script {
    function run() public {
        deployContract();
    }

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        // Retrieve the network configuration based on the current chain ID
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

         if (config.subscriptionId == 0) {
            // create subscriptionId logic
            CreateSubscription createSubscription = new CreateSubscription(); // Instantiate the CreateSubscription contract
            (config.subscriptionId, config.vrfCoordinator) = 
            createSubscription.createSubscription(config.vrfCoordinator, config.account); 

            // fund subscription logic
            FundSubscription fundSubscription = new FundSubscription(); // Instantiate the FundSubscription contract
            fundSubscription.fundSubscription(config.vrfCoordinator, config.subscriptionId, config.link, config.account);
        } 

        vm.startBroadcast(config.account); // Start broadcasting transactions from the specified account
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        // dont need to broadcast ...
        addConsumer.addConsumer(address(raffle), config.vrfCoordinator, config.subscriptionId, config.account);

        return (raffle, helperConfig);
    }
}
