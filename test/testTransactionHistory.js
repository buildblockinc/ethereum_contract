var TransactionHistory = artifacts.require("TransactionHistory");

contract('TransactionHistory', function(accounts) {

    let txHist

    beforeEach('Setup contract for each test', async function() {
        txHist = await TransactionHistory.new(100, "Project Jacob", "J");
        console.log(txHist.address);
    });

    it("should put 100 ProjectToken in the first account and have owner as the first address in addresses", async function() {
        assert.equal(await txHist.balanceOf(accounts[0]), 100, "100 wasn't in the first account");
    });

    it("only owner can write history", async function() {
        await txHist.transferFrom(accounts[0], accounts[1], 50, {from: accounts[0]});
        assert.equal(await txHist.balanceOf(accounts[0]), 50, "Owner must have 50 after transaction");
        assert.equal(await txHist.balanceOf(accounts[1]), 50, "Account 1 must have 50 after transaction");

        await txHist.transferFrom(accounts[1], accounts[0], 20, {from: accounts[0]});
        assert.equal(await txHist.balanceOf(accounts[0]), 70, "Owner must have 70 after transaction");
        assert.equal(await txHist.balanceOf(accounts[1]), 30, "Account 1 must have 30 after transaction");

        try {
            await txHist.transferFrom(accounts[0], accounts[1], 50, {from: accounts[1]});
        } catch(err) {
            console.error("Transaction History can be written by owner only!");
        }
        assert.equal(await txHist.balanceOf(accounts[1]), 30, "Account 1 still has 30");
    });

});