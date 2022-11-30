// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract VulnerableContract {
    mapping(address => uint256) public balance;

    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public {
        require(balance[msg.sender] > 0, "Nothing to withdraw.");
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "withdraw failed.");
        balance[msg.sender] -= _amount;
    }
}
