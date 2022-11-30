// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract VulnerableContract {
    mapping(address => uint256) public balance;

    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 bal = balance[msg.sender];
        require(bal > 0, "Nothing to withdraw.");
        (bool success, ) = msg.sender.call{value: bal}("");
        require(success, "withdraw failed.");
        balance[msg.sender] = 0;
    }
}
