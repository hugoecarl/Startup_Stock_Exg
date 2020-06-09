const B2S = artifacts.require("B2S");
const Company = artifacts.require("Company");
const path = require("path");
const fs = require("fs");

const CompanyABI = fs.readFileSync(
  path.resolve(__dirname, "..", "build", "contracts", "Company.json")
);

contract("B2S", (accounts) => {
  it("should be able to register and approve company", async () => {
    const instance = await B2S.deployed();
    const deposit = 10;
    const account = accounts[1];
    const address = await instance.register.call({
      from: account,
      value: deposit,
    });

    console.log();
    var placeholder = new web3.eth.Contract(JSON.parse(CompanyABI)["abi"]);
    placeholder.options.address = address;

    await placeholder.methods
      .getApproval()
      .call({ from: accounts[0] }, function (error, result) {
        console.log(error);
        console.log(result);
      });
  });
});
