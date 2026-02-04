// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint public goal;
    uint public deadline;
    uint public totalFunds;
    
    mapping(address => uint) public contributions;
    
    constructor(uint _goal, uint _durationDays) {
        owner = msg.sender;  // Creator becomes owner
        goal = _goal;
        deadline = block.timestamp + (_durationDays * 1 days);
    }
    
    function contribute() public payable {
        require(block.timestamp < deadline, "Campaign ended");
        require(msg.value > 0, "Must send ETH");
        
        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;
    }
    
    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(block.timestamp >= deadline, "Campaign still active");
        require(totalFunds >= goal, "Goal not reached");
        
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
    function refund() public {
        require(block.timestamp >= deadline, "Campaign still active");
        require(totalFunds < goal, "Goal was reached");
        
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contribution found");
        
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
    
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
