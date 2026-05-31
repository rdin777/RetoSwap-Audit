// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {SecureVault} from "../src/SecureVault.sol";

contract SecureVaultTest is Test {
    SecureVault public vault;
    address public owner = address(1);
    address public arbiter = address(2);
    address public treasury = address(3); // Trusted Address
    address public hacker = address(0x1337);

    function setUp() public {
        vm.prank(owner);
        vault = new SecureVault();
        vm.deal(address(vault), 10 ether);

        // Arbiter Configuration
        vm.prank(owner);
        vault.registerArbiter(arbiter);

        // We are whitelisting only the Treasury.
        vm.prank(owner);
        vault.setAllowedAddress(treasury, true);
    }

    function testWithdrawalWhitelist() public {
        // 1. Successful withdrawal to a trusted address (on behalf of the arbitrator)
        vm.prank(arbiter);
        vault.withdraw(treasury, 5 ether);
        assertEq(treasury.balance, 5 ether);

        // 2. Attempting withdrawal to hacker's address (expecting an error)
        vm.startPrank(arbiter);
        vm.expectRevert("Address not allowed");
        vault.withdraw(hacker, 1 ether);
        vm.stopPrank();

        console.log("Whitelist protection verified!");
    }
}
