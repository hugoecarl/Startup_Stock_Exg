const Web3 = require("web3");
const fs = require("fs");
const path = require("path");

const address = "0x9dB5e46442cB3ddFC902042EfaFb9027648053E9";

(async () => {
  const web3 = new Web3(Web3.givenProvider || "ws://localhost:7545");
  const accounts = await web3.eth.getAccounts();
  const CompanyABI = fs.readFileSync(
    path.resolve(__dirname, "..", "build", "contracts", "Company.json")
  );
  console.log(accounts);
  var placeholder = new web3.eth.Contract(JSON.parse(CompanyABI)["abi"]);
  placeholder.options.address = address;

  await placeholder.methods
    .getApproval()
    .call({ from: accounts[0] }, function (error, result) {
      console.log(error);
      console.log(result);
    });
  await web3.currentProvider.disconnect();
})();
