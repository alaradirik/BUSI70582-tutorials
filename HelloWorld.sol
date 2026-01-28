// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HelloWorld {
    // State variable to store a message
    string private message;
    
    // Constructor runs once when contract is deployed
    constructor() {
        message = "Hello, World!";
    }
    
    // Function to read the message (view = doesn't modify state)
    function getMessage() public view returns (string memory) {
        return message;
    }
    
    // Function to update the message (costs gas because it modifies state)
    function setMessage(string memory newMessage) public {
        message = newMessage;
    }
}