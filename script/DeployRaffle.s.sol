// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { script } from "forge-std/Script.sol";
import { Raffle } from "../src/Raffle.sol";

contract DeployFaffle is Script {
    function run() public {}

    function deployContract() public returns (Raffle, HelperConfig) {}
}
