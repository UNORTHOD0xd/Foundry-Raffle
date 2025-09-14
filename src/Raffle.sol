// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

// Imports
// Errors
// Interfaces, libraries, contracts
// Type Declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// Constructor
// Receive Function (if exists)
// Fallback Function (if exists)
// External 
// Public
// Internal
// Private 
// View & Pure Functions

/**
 * @title A simple Raffle contract
 * @author UNORTHOD0xd
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2.5
 */

contract Raffle is VRFConsumerBaseV2Plus {

    /* Errors */
    error Raffle__SendMoreToEnterRaffle();

    /* State Variables */
    uint256 private immutable I_ENTRANCEFEE;
    // @dev The duration of the lottery in seconds 
    uint256 private immutable I_INTERVAL;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    /* Events */
    event RaffleEntered(address indexed s_players);


constructor(uint256 enteranceFee, uint256 interval, address vrfcoordinatorV2)
        VRFConsumerBaseV2Plus(vrfcoordinatorV2) {
        I_ENTRANCEFEE = enteranceFee;
        I_INTERVAL = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable{
        // require(msg.value >= I_ENTRANCEFEE, "Not enough ETH sent!");
        // require(msg.value >= I_ENTRANCEFEE, SendMoreToEnterRaffle());
        if (msg.value < I_ENTRANCEFEE) {
            revert Raffle__SendMoreToEnterRaffle();
        } // Most gas efficient error
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    // 1. Get a random number
    // 2. Use random number to pick a player
    // 3. Be automatically called
    function pickWinner() external {
        // check to see if enough time has passed.
        if ((block.timestamp - s_lastTimeStamp) < I_INTERVAL) {
            revert();
        }
        /*requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGaslimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    //Set native payment to true to pay for VRF requests with Sepolia ETH instead
                    VRFV2PlusClient.ExtraArgsV1((nativePayments: false))
                )
            })
        ); */
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] calldata randomWords) internal override 
    {}

    /**
     * Getter Functions
     */
    function getEntranceFee() external view returns (uint256) {
        return I_ENTRANCEFEE;
    }
}