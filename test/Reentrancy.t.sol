// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/VulnerableContract.sol";
import "../src/MutexNonReentrant.sol";
import "../src/UpdateFirstNonReentrant.sol";
import "../src/MaliciousContract.sol";

contract Reentrancy is Test {
    VulnerableContract vulnerable;
    MaliciousContract maliciousVulnerable;
    MaliciousContract maliciousUpdateFirst;
    MaliciousContract maliciousMutex;
    UpdateFirstNonReentrant updateFirst;
    MutexNonReentrant mutex;

    address payable vulnerableContractDeployer1 = payable(address(0x1));
    address payable maliciousContractDeployer2 = payable(address(0x2));
    address payable victim3 = payable(address(0x3));
    address payable victim4 = payable(address(0x4));
    uint256 victimValue = 3 ether;
    uint256 attackerValue = 1 ether;

    function setUp() public {
        vm.startPrank(vulnerableContractDeployer1);
        vulnerable = new VulnerableContract();
        vm.stopPrank();

        vm.startPrank(maliciousContractDeployer2);
        maliciousVulnerable = new MaliciousContract(
            payable(address(vulnerable))
        );
        vm.stopPrank();

        vm.startPrank(vulnerableContractDeployer1);
        updateFirst = new UpdateFirstNonReentrant();
        vm.stopPrank();

        vm.startPrank(maliciousContractDeployer2);
        maliciousUpdateFirst = new MaliciousContract(
            payable(address(updateFirst))
        );
        vm.stopPrank();

        vm.startPrank(vulnerableContractDeployer1);
        mutex = new MutexNonReentrant();
        vm.stopPrank();

        vm.startPrank(maliciousContractDeployer2);
        maliciousMutex = new MaliciousContract(payable(address(mutex)));
        vm.stopPrank();
    }

    function testFundContracts() public {
        vm.startPrank(victim3);
        vm.deal(victim3, victimValue);
        assertEq(victim3.balance, victimValue);
        assertEq(vulnerable.balance(victim3), 0 ether);
        vulnerable.deposit{value: victimValue}();
        assertEq(vulnerable.balance(victim3), victimValue);
        assertEq(victim3.balance, 0 ether);
        vm.stopPrank();

        vm.startPrank(victim3);
        vm.deal(victim3, victimValue);
        assertEq(victim3.balance, victimValue);
        assertEq(updateFirst.balance(victim3), 0 ether);
        updateFirst.deposit{value: victimValue}();
        assertEq(updateFirst.balance(victim3), victimValue);
        assertEq(victim3.balance, 0 ether);
        vm.stopPrank();

        vm.startPrank(victim3);
        vm.deal(victim3, victimValue);
        assertEq(victim3.balance, victimValue);
        assertEq(mutex.balance(victim3), 0 ether);
        mutex.deposit{value: victimValue}();
        assertEq(mutex.balance(victim3), victimValue);
        assertEq(victim3.balance, 0 ether);
        vm.stopPrank();
    }

    function testVulnerableContractWithReentrancy() public {
        testFundContracts();

        vm.startPrank(maliciousContractDeployer2);
        vm.deal(maliciousContractDeployer2, attackerValue); // puts only attacker value.
        assertEq(address(maliciousVulnerable).balance, 0 ether);
        maliciousVulnerable.attack{value: attackerValue}();
        assertEq(
            address(maliciousVulnerable).balance,
            victimValue + attackerValue
        ); // gets attacker value + victim value.
        maliciousVulnerable.claimAndRun(); // literally, claim and run before your eth become etc.
        assertEq(address(maliciousVulnerable).balance, 0);
        assertEq(
            maliciousContractDeployer2.balance,
            victimValue + attackerValue
        );
        vm.stopPrank();
    }

    function testUpdateFirstContractWithReentrancy() public {
        testFundContracts();

        vm.startPrank(maliciousContractDeployer2);
        vm.deal(maliciousContractDeployer2, attackerValue); // puts only attacker value.
        assertEq(address(maliciousUpdateFirst).balance, 0 ether);
        maliciousUpdateFirst.attack{value: attackerValue}();
        assertEq(address(maliciousUpdateFirst).balance, attackerValue); // gets attacker value only.
        maliciousUpdateFirst.claimAndRun(); // claims only his value - gas fee. attackern't.
        assertEq(address(maliciousUpdateFirst).balance, 0);
        assertEq(maliciousContractDeployer2.balance, attackerValue);
        vm.stopPrank();
    }

    function testMutexContractWithReentrancy() public {
        testFundContracts();

        vm.startPrank(maliciousContractDeployer2);
        vm.deal(maliciousContractDeployer2, attackerValue); // puts only attacker value.
        assertEq(address(maliciousMutex).balance, 0 ether);
        maliciousMutex.attack{value: attackerValue}();
        assertEq(address(maliciousMutex).balance, attackerValue); // gets attacker value only.
        maliciousMutex.claimAndRun(); // claims only his value - gas fee. attackern't.
        assertEq(address(maliciousMutex).balance, 0);
        assertEq(maliciousContractDeployer2.balance, attackerValue);
        vm.stopPrank();
    }
}
