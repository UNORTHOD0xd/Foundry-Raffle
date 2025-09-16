// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

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
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();

    /* Type Declarations */
    enum RaffleState {
        OPEN, // 0
        CALCULATING // 1
    }

    /* State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGaslimit;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;


    /* Events */
    event RaffleEntered(address indexed s_players);
    event WinnerPicked(address indexed s_recentWinner);


constructor(uint256 enteranceFee, 
            uint256 interval, 
            address vrfcoordinatorV2,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGaslimit)
        VRFConsumerBaseV2Plus(vrfcoordinator) {
        i_entranceFee = enteranceFee;
        i_interval = interval;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGaslimit = callbackGaslimit;
        
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable{
        // require(msg.value >= i_entranceFee, "Not enough ETH sent!");
        // require(msg.value >= i_entranceFee, SendMoreToEnterRaffle());
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        } // Most gas efficient error
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    // 1. Get a random number
    // 2. Use random number to pick a player
    // 3. Be automatically called
    function pickWinner() external {
        // check to see if enough time has passed.
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }

        s_raffleState = RaffleState.CALCULATING;
         // Will revert if subscription is not set and funded.
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest(
            {
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGaslimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    //Set native payment to true to pay for VRF requests with Sepolia ETH instead
                    VRFV2PlusClient.ExtraArgsV1((nativePayments: false))
                )
            }
        );
        uint256 requestId = s_vrfcoordinator.requestRandomWords(request);  
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] calldata randomWords) internal override 
    {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0); // Reset the players array
        s_lastTimeStamp = block.timestamp; // Update the timestamp
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        } // Most gas efficient error
        emit WinnerPicked(s_recentWinner);
    } // Funuction called by the VRF Coordinator to return the random number

    /**
     * Getter Functions
     */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}