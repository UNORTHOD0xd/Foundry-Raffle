// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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

contract Raffle {

    /* Errors */
    error Raffle__SendMoreToEnterRaffle();

    /* State Variables */
    uint256 private immutable I_ENTRANCEFEE;
    address payable[] private s_players;

    /* Events */
    event RaffleEntered(address indexed s_players);


    constructor(uint256 enteranceFee) {
        I_ENTRANCEFEE = enteranceFee;
    }

    function enterRaffle() public payable{
        // require(msg.value >= I_ENTRANCEFEE, "Not enough ETH sent!");
        // require(msg.value >= I_ENTRANCEFEE, SendMoreToEnterRaffle());
        if (msg.value < I_ENTRANCEFEE) {
            revert Raffle__SendMoreToEnterRaffle();
        } // Most gas efficient error
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() public {}

    /**
     * Getter Functions
     */
    function getEntranceFee() external view returns (uint256) {
        return I_ENTRANCEFEE;
    }
}