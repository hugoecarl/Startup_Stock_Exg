const Company = artifacts.require("Company");

contract("Company", (accounts) => {
  it("should be able to deposit and withdraw value", async () => {
    const instance = await Company.deployed();
    const account = accounts[2];
    const deposit = 10;

    await instance.deposit({ from: account, value: deposit });

    const balance = (
      await instance.balance.call({
        from: account,
      })
    ).toNumber();

    await instance.withdraw(balance, { from: account });
    const remainder = (
      await instance.balance.call({
        from: account,
      })
    ).toNumber();

    assert.equal(balance, deposit, "The balance does not match deposit");
    assert.equal(remainder, 0, "The balance should be zero");
  });

  it("should be able to create ipo", async () => {
    const instance = await Company.deployed();
    const account = accounts[0];
    const client = accounts[1];
    const price = 12;
    const amount = 30;

    await instance.ipo(price, amount, { from: account });

    await instance.deposit({ from: client, value: price * amount });
    await instance.bid(price, amount, {
      from: client,
    });

    const shares = (
      await instance.shares({
        from: client,
      })
    ).toNumber();

    assert.equal(
      shares,
      amount,
      "The client should have sufficient funds to create bid"
    );

    await instance.deposit({
      from: accounts[2],
      value: (price + 5) * (amount - 5),
    });

    await instance.bid(price + 5, amount - 5, {
      from: accounts[2],
    });

    await instance.ask(price + 5, amount - 5, {
      from: client,
    });

    const shares2 = (
      await instance.shares({
        from: accounts[2],
      })
    ).toNumber();

    assert.equal(
      shares2,
      amount - 5,
      "The client should have sufficient funds to create bid"
    );
  });
});
