var  AuthenticationContract = artifacts.require("./AuthenticationContract.sol");
const user = artifacts.require("user");
const device = artifacts.require("device");
module.exports = function(deployer) {
  deployer.deploy(AuthenticationContract);
  deployer.deploy(user);
  deployer.deploy(device);
};
