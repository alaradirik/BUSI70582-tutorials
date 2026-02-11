// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint public goal;
    uint public deadline;
    uint public totalFunds;
    
    // mapping or dictionary of contributors and their contributions
    mapping(address => uint) public contributions; 

    // array of contributor addresses
    address[] public contributors;
    mapping(address => bool) private isContributor;
    
    // we will share a Google Form URL with contributors for reward fulfillment
    string public rewardFormUrl;
    
    // Same rewards for everyone, but we can track tiers based on contribution amount
    enum RewardTier { None, Bronze, Silver, Gold }
    mapping(address => RewardTier) public rewardTiers;
    
    event ContributionReceived(address contributor, uint amount, uint timestamp, uint gasPrice);
    event RewardTierAssigned(address contributor, RewardTier tier);
    
    constructor(uint _goal, uint _durationDays) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationDays * 1 days);
    }
    
    // allow all nodes to contribute and track contributions and reward tiers
    function contribute() public payable {
        require(block.timestamp < deadline, "Campaign ended");
        require(msg.value > 0, "Must send ETH");
        
        if (!isContributor[msg.sender]) {
            contributors.push(msg.sender);
            isContributor[msg.sender] = true;
        }
        
        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;
        
        _updateRewardTier(msg.sender);
        
        emit ContributionReceived(msg.sender, msg.value, block.timestamp, tx.gasprice);
    }
    
    // allow owner to withdraw funds if goal is met
    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(block.timestamp >= deadline, "Campaign still active");
        require(totalFunds >= goal, "Goal not reached");
        
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
    
    // allow contributors to get refunds if goal is not met
    function refund() public {
        require(block.timestamp >= deadline, "Campaign still active");
        require(totalFunds < goal, "Goal was reached");
        
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contribution found");
        
        contributions[msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Refund failed");
    }
    
    // allow owner to refund all contributors at once if goal is not met
    function refundAll() public {
        require(msg.sender == owner, "Only owner can refund");
        require(block.timestamp >= deadline, "Campaign still active");
        require(totalFunds < goal, "Goal was reached");
        
        for (uint i = 0; i < contributors.length; i++) {
            address contributor = contributors[i];
            uint amount = contributions[contributor];
            
            if (amount > 0) {
                contributions[contributor] = 0;
                (bool success, ) = payable(contributor).call{value: amount}("");
                require(success, "Refund failed");
            }
        }
    }

    // private function to update reward tier based on total contribution
    function _updateRewardTier(address contributor) private {
        uint total = contributions[contributor];
        RewardTier newTier;
        
        if (total >= 0.02 ether) {
            newTier = RewardTier.Gold;
        } else if (total >= 0.01 ether) {
            newTier = RewardTier.Silver;
        } else if (total >= 0.005 ether) {
            newTier = RewardTier.Bronze;
        } else {
            newTier = RewardTier.None;
        }
        
        if (rewardTiers[contributor] != newTier) {
            rewardTiers[contributor] = newTier;
            emit RewardTierAssigned(contributor, newTier);
        }
    }

    // allow owner to set the reward form URL
    function setRewardFormUrl(string memory _url) public {
        require(msg.sender == owner, "Only owner can set URL");
        rewardFormUrl = _url;
    }
    
    function getRewardFormUrl() public view returns (string memory) {
        require(rewardTiers[msg.sender] != RewardTier.None, "No reward tier");
        return rewardFormUrl;
    }
    
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function getContributorsCount() public view returns (uint) {
        return contributors.length;
    }
    
    function getTopContributors(uint count) public view returns (address[] memory, uint[] memory) {
        uint len = contributors.length < count ? contributors.length : count;
        address[] memory topAddresses = new address[](len);
        uint[] memory topAmounts = new uint[](len);
        
        for (uint i = 0; i < contributors.length; i++) {
            address addr = contributors[i];
            uint amount = contributions[addr];
            
            for (uint j = 0; j < len; j++) {
                if (amount > topAmounts[j]) {
                    for (uint k = len - 1; k > j; k--) {
                        topAddresses[k] = topAddresses[k-1];
                        topAmounts[k] = topAmounts[k-1];
                    }
                    topAddresses[j] = addr;
                    topAmounts[j] = amount;
                    break;
                }
            }
        }
        
        return (topAddresses, topAmounts);
    }
}
