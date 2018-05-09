var ProjectToken = artifacts.require("ProjectToken");
var ZipToken = artifacts.require("ZipToken");

contract('ProjectToken', function(accounts) {

    let projectToken
    let zipToken

    beforeEach('setup contract for each test', async function () {
        zipToken = await ZipToken.new()
        projectToken = await ProjectToken.new(zipToken.address, 100, "Project Jacob", "J")
    })

    it("should put 100 ProjectToken in the first account", async function() {
        assert.equal(await projectToken.balanceOf(accounts[0]), 100, "100 wasn't in the first account");
    })

    it("should have owner as the first address in addresses", async function() {
        assert.equal(await projectToken.getNthAddress(0), accounts[0], "Owner is not the first address");
    })

    it("should correctly distribute interests", async function() {
        projectToken.setCoinCashRate(100, {from: accounts[1]});
        projectToken.setCoinCashRate(100, {from: accounts[2]});
        projectToken.setCoinCashRate(50, {from: accounts[3]});
        projectToken.transfer(accounts[1], 50, {from: accounts[0]});
        projectToken.transfer(accounts[2], 30, {from: accounts[0]});
        projectToken.transfer(accounts[3], 20, {from: accounts[0]});

        assert.equal(await projectToken.balanceOf(accounts[1]), 50, "Account 1 should have 50 project tokens");
        assert.equal(await projectToken.balanceOf(accounts[2]), 30, "Account 2 should have 30 project tokens");
        assert.equal(await projectToken.balanceOf(accounts[3]), 20, "Account 3 should have 20 project tokens");

        assert.equal(await projectToken.getNthAddress(await projectToken.getIndex(accounts[1])), accounts[1], "Indexing should work correctly");
        assert.equal(await projectToken.getNthAddress(await projectToken.getIndex(accounts[2])), accounts[2], "Indexing should work correctly");
        assert.equal(await projectToken.getNthAddress(await projectToken.getIndex(accounts[3])), accounts[3], "Indexing should work correctly");

        await zipToken.approve(projectToken.address, 100, {from: accounts[0]});
        await projectToken.payInterestsInToken(100, {from: accounts[0]});
        assert.equal(await zipToken.balanceOf(accounts[1]), 50, "Account 1 must have received 50 ZIP as interests");
        assert.equal(await zipToken.balanceOf(accounts[2]), 30, "Account 2 must have received 30 ZIP as interests");
        assert.equal(await zipToken.balanceOf(accounts[3]), 10, "Account 3 must have received 10 ZIP as interests");
    })

});