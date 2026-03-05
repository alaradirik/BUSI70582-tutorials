// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimplePoll {

    string public question;
    address public creator;
    bool public pollOpen;

    // Tracks vote count for each option (0 or 1)
    mapping(uint256 => uint256) public votesFor;

    // Records whether an address has already voted
    mapping(address => bool) public hasVoted;

    // Logs every vote cast
    event VoteCast(address indexed voter, uint256 option);

    // Logs when the poll is closed
    event PollClosed(uint256 votesOption0, uint256 votesOption1);

    // Runs once when the contract is deployed
    constructor(string memory _question) {
        creator = msg.sender;
        question = _question;
        pollOpen = true;
    }

    // Cast a vote for option 0 or option 1
    function vote(uint256 option) external {
        require(pollOpen, "Poll is closed.");
        require(option == 0 || option == 1,
            "Invalid option. Choose 0 or 1.");
        require(!hasVoted[msg.sender],
            "You have already voted.");

        hasVoted[msg.sender] = true;
        votesFor[option] += 1;

        emit VoteCast(msg.sender, option);
    }

    // Only the creator can close the poll
    function closePoll() external {
        require(msg.sender == creator,
            "Only creator can close the poll.");
        require(pollOpen, "Poll is already closed.");

        pollOpen = false;

        emit PollClosed(votesFor[0], votesFor[1]);
    }

    // Returns the leading option (or 2 if tied)
    function leading() external view returns (uint256) {
        ...
    }
}
