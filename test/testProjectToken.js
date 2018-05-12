var ProjectToken = artifacts.require("ProjectToken");
var ZipToken = artifacts.require("ZipToken");

contract('ProjectToken', function(accounts) {

    let projectToken
    let zipToken

    beforeEach('setup contract for each test', async function () {
        zipToken = await ZipToken.new()
        projectToken = await ProjectToken.new(zipToken.address, 100, "Project Jacob", "J", 80)
        console.log(projectToken.address)
    })

    it("should put 100 ProjectToken in the first account and have owner as the first address in addresses", async function() {
        assert.equal(await projectToken.balanceOf(accounts[0]), 100, "100 wasn't in the first account");
        assert.equal(await projectToken.getNthAddress(0), accounts[0], "Owner is not the first address");
    })

    it("should correctly distribute interests", async function() {
        projectToken.setCoinCashRate(100, {from: accounts[1]});
        projectToken.setCoinCashRate(100, {from: accounts[2]});
        projectToken.setCoinCashRate(50, {from: accounts[3]});
        await projectToken.transfer(accounts[1], 50, {from: accounts[0]});
        await projectToken.transfer(accounts[2], 30, {from: accounts[0]});
        await projectToken.transfer(accounts[3], 20, {from: accounts[0]});

        assert.equal(await projectToken.balanceOf(accounts[1]), 50, "Account 1 should have 50 project tokens");
        assert.equal(await projectToken.balanceOf(accounts[2]), 30, "Account 2 should have 30 project tokens");
        assert.equal(await projectToken.balanceOf(accounts[3]), 20, "Account 3 should have 20 project tokens");

        assert.equal(await projectToken.getNthAddress(await projectToken.getIndex(accounts[1])), accounts[1], "Indexing should work correctly");
        assert.equal(await projectToken.getNthAddress(await projectToken.getIndex(accounts[2])), accounts[2], "Indexing should work correctly");
        assert.equal(await projectToken.getNthAddress(await projectToken.getIndex(accounts[3])), accounts[3], "Indexing should work correctly");

        await zipToken.approve(projectToken.address, 100, {from: accounts[0]});
        try {
            await projectToken.payInterestsInToken(100, 1000, {from: accounts[0]});
        } catch(err) {
            console.error("Paying Interests failed since the contract is not in suspension period!");
        }

        try {
            await projectToken.setSuspension(10, {from: accounts[1]});
        } catch(err) {
            console.error("setSuspension function should be called by the owner!");
        }

        await projectToken.setSuspension(10, {from: accounts[0]});
        try {
            await projectToken.setCoinCashRate(50, {from: accounts[1]});;
        } catch (err) {
            console.error("During suspension period, coin cash rate will not be changed!");
        }

        // During suspension period, paying interest is possible.
        await projectToken.payInterestsInToken(100, 1000, {from: accounts[0]}).then(function(result) {
            assert.equal(result.logs[1]['args']['coinValue'], 50);
            assert.equal(result.logs[1]['args']['cashValue'], 0);
            assert.equal(result.logs[1]['args']['price'], 1000);
            assert.equal(result.logs[3]['args']['coinValue'], 30);
            assert.equal(result.logs[3]['args']['cashValue'], 0);
            assert.equal(result.logs[5]['args']['coinValue'], 10);
            assert.equal(result.logs[5]['args']['cashValue'], 8);
            console.log(result.logs[1]['args']);
        });


        assert.equal(await zipToken.balanceOf(accounts[1]), 50, "Account 1 must have received 50 ZIP as interests");
        assert.equal(await zipToken.balanceOf(accounts[2]), 30, "Account 2 must have received 30 ZIP as interests");
        assert.equal(await zipToken.balanceOf(accounts[3]), 10, "Account 3 must have received 10 ZIP as interests");
    })

});