const Company = artifacts.require("Company");
const B2S = artifacts.require("B2S");

contract("B2S", (accounts) => {
  it("should be able to register company", async () => {
    const company = await Company.new({ from: accounts[1] });
    const b2s = await B2S.new({ from: accounts[0] });
    await b2s.register(company.address, { from: accounts[1], value: 10 });

    var approved = await b2s.verify(company.address);
    assert.equal(approved, false, "Company should not be approved");

    const capital = await b2s.balance({ from: accounts[0] });
    assert.equal(capital, 0, "Company's capital should be 0");

    await b2s.approve(company.address, true, {
      from: accounts[0],
    });

    approved = await b2s.verify(company.address);
    assert.equal(approved, true, "Company should be approved");
  });

  it("should be able to get capital after company is rejected", async () => {
    const company = await Company.new({ from: accounts[1] });
    const b2s = await B2S.new({ from: accounts[0] });

    const deposit = 10;
    await b2s.register(company.address, {
      from: accounts[1],
      value: deposit,
    });

    var approved = await b2s.verify(company.address);
    assert.equal(approved, false, "Company should not be approved");

    var capital = (await b2s.balance({ from: accounts[0] })).toNumber();
    assert.equal(capital, 0, "Company's capital should be 0");

    a = await b2s.approve(company.address, false, {
      from: accounts[0],
    });

    approved = await b2s.verify(company.address);
    assert.equal(approved, false, "Company should be approved");

    capital = (await b2s.balance({ from: accounts[0] })).toNumber();
    assert.equal(
      capital,
      deposit,
      `Company's capital should be equal to ${deposit}`
    );
  });
});
