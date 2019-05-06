const test = artifacts.require("test");
contract('EtherStore', async (accounts) => {
    const owner = accounts[0];
    let instance;
    before('setup contract for each test', async () => {
        instance = await test.new({from: accounts[0]});
        console.log("contract_name:test:" + instance.address)
    });
    it('test 0', async () => {
        await instance.test1({from: accounts[0], value: web3.utils.toWei(web3.utils.toBN(1))});
        await instance.test1({from: accounts[1], value: web3.utils.toWei(web3.utils.toBN(1))});
        await instance.test1({from: accounts[2], value: web3.utils.toWei(web3.utils.toBN(1))});
        await instance.test1({from: accounts[3], value: web3.utils.toWei(web3.utils.toBN(1))});
        await instance.test1({from: accounts[4], value: web3.utils.toWei(web3.utils.toBN(1))});
        await instance.test1({from: accounts[5], value: web3.utils.toWei(web3.utils.toBN(1))});
        await instance.test1({from: accounts[6], value: web3.utils.toWei(web3.utils.toBN(1))});
        await instance.test1({from: accounts[3], value: web3.utils.toWei(web3.utils.toBN(2))});

        await instance.test3(100,{from: accounts[3]});
    });
});
