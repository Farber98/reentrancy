// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MutexNonReentrant {
    mapping(address => uint256) public balance;
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }

    function withdraw() public noReentrant {
        uint256 bal = balance[msg.sender];
        require(bal > 0, "Nothing to withdraw.");
        (bool success, ) = msg.sender.call{value: bal}("");
        require(success, "withdraw failed.");
        balance[msg.sender] = 0;
    }
}
