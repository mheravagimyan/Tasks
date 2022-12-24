const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Integral", function() {
  it("Integral", async function () {
    let owner;
    let int;

    [owner] = await ethers.getSigners();
    const Integral = await ethers.getContractFactory("Integral", owner);
    int = await Integral.deploy();
    await int.deployed();

    await int.calcIntegral([[1, 2], [3, 4]], 0, 4, 200);
    // expect(result).to.eq(128035);

    
    console.log("The answer is: ", await int.answer());
  });
});