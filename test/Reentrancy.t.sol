// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/VulnerableContract.sol";
import "../src/MutexNonReentrant.sol";
import "../src/UpdateFirstNonReentrant.sol";
import "../src/MaliciousContract.sol";

contract Reentrancy is Test {
    MaliciousContract malicious;
    VulnerableContract vulnerable;
    UpdateFirstNonReentrant updateFirst;
    MutexNonReentrant mutex;

    address payable vulnerableContractDeployer1 = payable(address(0x1));
    address payable maliciousContractDeployer2 = payable(address(0x2));
    address payable victim3 = payable(address(0x3));
    address payable victim4 = payable(address(0x4));

    function setUp() public {
        vm.startPrank(vulnerableContractDeployer1);
        vulnerable = new VulnerableContract();
        vm.stopPrank();

        vm.startPrank(vulnerableContractDeployer1);
        malicious = new MaliciousContract(payable(address(vulnerable)));
        vm.stopPrank();
    }

    function testVulnerableContractWithoutReentrancy() public {
        vm.startPrank(victim3);
        vm.deal(victim3, 20 ether);
        assertEq(victim3.balance, 20 ether);
        assertEq(vulnerable.balance(victim3), 0 ether);
        vulnerable.deposit{value: 15 ether}();
        assertEq(vulnerable.balance(victim3), 15 ether);
        assertEq(victim3.balance, 5 ether);
    }
}
