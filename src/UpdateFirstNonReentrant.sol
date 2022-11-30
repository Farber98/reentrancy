// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract UpdateFirstNonReentrant {
    mapping(address => uint256) public balance;

    function deposit(uint256 _amount) public payable {
        balance[msg.sender] += _amount;
    }

    function withdraw(uint256 _amount) public {
        require(balance[msg.sender] > 0, "Nothing to withdraw.");
        balance[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "withdraw failed.");
    }
}
