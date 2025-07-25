// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title A simple Raffle contract
 * @author UNORTHOD0xd
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2.5
 */

contract Raffle {
    uint256 private immutable I_ENTRANCEFEE;

    constructor(uint256 enteranceFee) {
        I_ENTRANCEFEE = enteranceFee;
    }

    function enterRaffle() public payable{}

    function pickWinner() public {}

    /**
     * Getter Functions
     */
    function getEntranceFee() external view returns (uint256) {
        return I_ENTRANCEFEE;
    }
}