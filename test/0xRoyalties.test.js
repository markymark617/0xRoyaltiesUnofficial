const ERC721NFT = artifacts.require("ERC721Impl");
const Licensing = artifacts.require("TokenLicensing");

require("./utils");

const catchRevert = require("./exceptionsHelpers.js").catchRevert;

const getLastEvent = async (eventName, instance) => {
    const events = await instance.getPastEvents(eventName, {
        fromBlock: 0,
        toBlock: "latest"
    });
    return events.pop().returnValues;
};

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

contract("AccessController", ([owner, user1, user2]) => {
    let tokenLicensing;

    beforeEach(async () => {
        token = await ERC721NFT.new();
        tokenLicensing = await Licensing.new(token.address);
    });

  
    describe("Access Control", () => {
        it("correct owner address", async () => {
            const owner = await tokenLicensing.ownerAddress();
            assert.equal(owner, owner);

            const event = await getLastEvent("OwnerSet", tokenLicensing);
            assert.equal(event.newOwnerAddress, owner);
        });

     
    });

});
