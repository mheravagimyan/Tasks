const { expect } = require("chai");
const { ethers } = require("hardhat");

describe(" YVNToken", function() {
  let owner;
  let token;

  beforeEach(async function () {  

    [owner] = await ethers.getSigners();
    const  YVNToken = await ethers.getContractFactory("YVNToken", owner);
    token = await YVNToken.deploy("YVN Token", "YVN", 1000000000);
    await token.deployed();
  });

  it("Should be correct declaration!", async function () {
    expect(await token.name()).to.eq("YVN Token");
    expect(await token.symbol()).to.eq("YVN");
    expect(await token.maxSupply()).to.eq(1000000000);
    expect(await token.owner()).to.eq(owner.address);
  });
});