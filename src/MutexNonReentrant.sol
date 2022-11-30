// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract VulnerableContract {
    mapping(address => uint256) public balance;
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function deposit(uint256 _amount) public payable {
        balance[msg.sender] += amount;
    }

    function withdraw(uint256 _amount) public noReentrant {
        require(balance[msg.sender] > 0, "Nothing to withdraw.");
        (bool success, ) = msg.sender.call{value: _amount}("");
        balance[msg.sender] -= amount;
    }
}
