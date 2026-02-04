(async () => {
    try {
        console.log('Starting interaction...');
        
        // Get all accounts on blockchain
        const accounts = await web3.eth.getAccounts();
        console.log('Available accounts:', accounts.length);
        
        // Replace this with your smart contract address after deploying!
        const contractAddress = '0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47';
        
        // Get the contract ABI
        let metadata;
        metadata = JSON.parse(await remix.call('fileManager', 'getFile', 'artifacts/Crowdfunding.json'));

        
        // Create contract instance
        const crowdfunding = new web3.eth.Contract(metadata.abi, contractAddress);
        
        console.log('Current Contract State');
        console.log('Owner:', await crowdfunding.methods.owner().call());
        console.log('Goal:', web3.utils.fromWei(await crowdfunding.methods.goal().call(), 'ether'), 'ETH');
        console.log('Deadline:', new Date(parseInt(await crowdfunding.methods.deadline().call()) * 1000).toLocaleString());
        console.log('Total Funds:', web3.utils.fromWei(await crowdfunding.methods.totalFunds().call(), 'ether'), 'ETH');
        console.log('Contract Balance:', web3.utils.fromWei(await crowdfunding.methods.getContractBalance().call(), 'ether'), 'ETH');
        
        // Make contribution from account 1
        console.log('Contributing from account:', accounts[1]);
        
        const receipt = await crowdfunding.methods.contribute().send({
            from: accounts[1],
            value: web3.utils.toWei('1', 'ether'),
            gas: 3000000
        });
        
        console.log('Contribution successful!');
        console.log('Transaction hash:', receipt.transactionHash);
        
        console.log('Updated State:');
        console.log('New total funds:', web3.utils.fromWei(await crowdfunding.methods.totalFunds().call(), 'ether'), 'ETH');
        console.log('Account 1 contribution:', web3.utils.fromWei(await crowdfunding.methods.contributions(accounts[1]).call(), 'ether'), 'ETH');
        
    } catch (e) {
        console.error('Error:', e.message);
    }
})();