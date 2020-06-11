const Company = artifacts.require("Company");
const B2S = artifacts.require("B2S");

module.exports = function (deployer) {
  deployer.deploy(Company);
  deployer.deploy(B2S);
};
