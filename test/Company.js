const Company = artifacts.require("Company");

contract("Company", (accounts) => {
  it("should be able to register and approve company", async () => {
    const instance = await Company.deployed();
    const account = accounts[2];
    const deposit = 10;

    await instance.deposit.call({
      from: account,
      value: deposit,
    });

    const balance = (
      await instance.balance.call({
        from: account,
      })
    ).toNumber();

    assert.equal(balance, deposit, "The balance does not match deposit");
  });
});

// contract("B2S", (accounts) => {
//   it("should be able to register and approve company", async () => {
//     const instance = await B2S.deployed();
//     const deposit = 1;
//     const account = accounts[1];
//     const address = await instance.register.call({
//       from: account,
//       value: deposit,
//     });

//     console.log(address);
//     var placeholder = new web3.eth.Contract(
//       JSON.parse(CompanyABI)["abi"],
//       address
//     );

//     const result = await placeholder.methods
//       .dummy()
//       .call({ from: accounts[0] }, function (error, result) {
//         return result;
//       });
//   });
// });
