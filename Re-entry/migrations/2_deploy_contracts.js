const FishToken = artifacts.require("FishToken");
const attacker = artifacts.require("attacker");

const timePeriodInSeconds = 3600
const from = Math.floor(new Date() / 1000)
const to = from + timePeriodInSeconds

module.exports = function(deployer,network,accounts) {
	deployer.deploy(FishToken,to);
	deployer.deploy(attacker,accounts[0]);
};