const B2S = artifacts.require("B2S");

contract("B2S", (accounts) => {
  it("should initialize with empty capital", async () => {
    const instance = await B2S.deployed();
    const balance = await instance.ownerWithdraw.call(accounts[0], 10);

    assert.equal(balance.valueOf(), false, "10000 wasn't in the first account");
  });

  it("should be able to register and approve company", async () => {
    const instance = await B2S.deployed();

    const deposit = 1;
    const account = accounts[1];
    await instance.register({ from: account, value: deposit });
    const balance = await instance.getCompanyDeposit.call(account);
    assert.equal(
      balance.valueOf(),
      deposit,
      "The deposit was not in the company"
    );

    const defaultApproval = await instance.getCompanyApproval.call(account);
    assert.equal(
      defaultApproval.valueOf(),
      false,
      "The company is not rejected by default"
    );

    await instance.approve(account, true, { from: accounts[0] });

    const approval = await instance.getCompanyApproval.call(account);
    assert.equal(
      approval.valueOf(),
      true,
      "The company is not accepted by default"
    );

    const zero = await instance.getCompanyDeposit.call(account);
    assert.equal(zero.valueOf(), 0, "The deposit is not reseted by default");
  });
});
