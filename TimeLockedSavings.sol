// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLockSavings {
    address public accountHolder;
    uint public unlockTime;
    uint public depositBlock;
    
    event Deposit(address depositor, uint amount, uint blockNumber, uint 
gasPrice);
    event Withdrawal(address withdrawer, uint amount, uint timestamp);
    
    constructor(uint _lockDurationDays) {
        accountHolder = msg.sender;
        unlockTime = block.timestamp + (_lockDurationDays * 1 days);
        depositBlock = block.number;
    }
    
    function deposit() public payable {
        require(msg.sender == accountHolder, "Only account holder can 
deposit");
        require(msg.value > 0, "Must deposit some ETH");
        
        emit Deposit(msg.sender, msg.value, block.number, tx.gasprice);
    }
    
    function withdraw(uint amount) public {
        require(msg.sender == accountHolder, "Only account holder can 
withdraw");
        require(tx.origin == msg.sender, "Direct calls only");
        require(block.timestamp >= unlockTime, "Funds still locked");
        require(amount <= address(this).balance, "Insufficient balance");
        
        payable(accountHolder).transfer(amount);
        
        emit Withdrawal(msg.sender, amount, block.timestamp);
    }
    
    function getAccountInfo() public view returns (
        uint balance,
        uint timeRemaining,
        uint blocksSinceDeposit,
        bool isUnlocked
    ) {
        uint remaining = 0;
        if (block.timestamp < unlockTime) {
            remaining = unlockTime - block.timestamp;
        }
        
        return (
            address(this).balance,
            remaining,
            block.number - depositBlock,
            block.timestamp >= unlockTime
        );
    }
}
