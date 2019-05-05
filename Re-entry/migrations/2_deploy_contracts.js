const test = artifacts.require("test");

module.exports = function(deployer,network,accounts) {
	deployer.deploy(test);
};