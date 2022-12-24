const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Staking",function() {
    let owner;
    let sender;
    let stake;
    let lpToken;
    let yvnToken;
    beforeEach(async function() {
        [owner, sender] = await ethers.getSigners();

        const YVNToken = await ethers.getContractFactory("YVNToken", owner);
        yvnToken = await YVNToken.deploy("YVN Token", "YVN", 1000000000000000);
        await yvnToken.deployed();

        const XToken = await ethers.getContractFactory("XToken", owner);
        lpToken = await XToken.deploy();
        await lpToken.deployed();

        const Staking = await ethers.getContractFactory("Staking", owner);
        stake = await Staking.deploy(yvnToken.address, lpToken.address, 3);
        await stake.deployed();

        await lpToken.mint(stake.address, 10000000000);
    });

    describe("Initialization", function() {
        it("Should be deployed with correct args!", async function() {
            expect(await stake.owner()).to.eq(owner.address);
            expect(await stake.yvnToken()).to.eq(yvnToken.address);
            expect(await stake.lpToken()).to.eq(lpToken.address);
            expect(await stake.fee()).to.eq(3);
            expect(await lpToken.balanceOf(stake.address)).to.eq(10000000000);
        });
    });

    describe("Deposit", async function() {
        it("Should be possible to deposit", async function() {
            const amount = 10;
            await yvnToken.mint(sender.address, 100);
            await yvnToken.connect(sender).approve(stake.address, amount);
            const tx = await stake.connect(sender).deposit(amount);
            
            await expect(tx).to.changeTokenBalances(yvnToken, [sender, stake], [-amount, amount]);
            await expect(tx).to.changeTokenBalances(lpToken, [sender, stake], [amount, -amount]);
        });

        it("Should fill user data with correct args!", async function() {
            const amount = 10;
            await yvnToken.mint(sender.address, 100);
            await yvnToken.connect(sender).approve(stake.address, amount);
            await stake.connect(sender).deposit(amount);
            const time1 = (await ethers.provider.getBlock(ethers.provider.getBlockNumber())).timestamp;
            const [time2, tokenAmount, deposits, withdraws] = await stake.getUserData(sender.address);
            
            expect(time2).to.eq(time1);
            expect(tokenAmount).to.eq(amount);
            expect(deposits).to.eq(1);
            expect(withdraws).to.eq(0);

        });

        it("Sould emited with correct args", async function() {
            const amount = 10;
            await yvnToken.mint(sender.address, 100);
            await yvnToken.connect(sender).approve(stake.address, amount);
            const tx = await stake.connect(sender).deposit(amount);
            // const time = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            const [time,,,] = await stake.getUserData(sender.address);
            await expect(tx)
                .to.emit(stake, "Deposit")
                .withArgs(sender.address, amount, time);
        });

        it("Should be reverted with 'Staking: Incorrect amount!'", async function() {
            const tx = stake.connect(sender).deposit(0);
            
            await expect(tx)
                .to.revertedWith("Staking: Incorrect amount!");
        });
        
        it("Should be reverted with 'Staking: Not enough funds on your balance!'", async function() {
            const amount = 10;
            const tx = stake.connect(sender).deposit(amount);
            
            await expect(tx)
                .to.revertedWith("Staking: Not enough funds on your balance!");
        });

        it("Should be reverted with 'Staking: Not enough allowance!'", async function() {
            const amount = 10;
            await yvnToken.mint(sender.address, 100);
            const tx = stake.connect(sender).deposit(amount);
            
            await expect(tx)
                .to.revertedWith("Staking: Not enough allowance!");
        });

        it("Should be reverted with 'Staking: Not enough funds on contracat!'", async function() {
            const amount = 10;
            await yvnToken.mint(sender.address, 100);
            await yvnToken.connect(sender).approve(stake.address, amount);
            await lpToken.burn(stake.address, 10000000000);
            const tx = stake.connect(sender).deposit(amount);
            
            await expect(tx)
                .to.revertedWith("Staking: Not enough funds on contracat!");
        });
    });

    describe("Withdraw", function() {
        it("Should be possible to withdraw funds", async function() {
            const amount = 1000;
            const mintAmount = 100;
            await yvnToken.mint(sender.address, 10000);
            await yvnToken.connect(sender).approve(stake.address, amount);
            await stake.connect(sender).deposit(amount);
            await yvnToken.mint(stake.address, mintAmount);
            await lpToken.connect(sender).approve(stake.address, 500);
            const tx = await stake.connect(sender).withdraw(500);

            await expect(tx).to.changeTokenBalances(yvnToken, [owner, sender, stake], [16, 534, -550]);
            await expect(tx).to.changeTokenBalances(lpToken, [sender, stake], [-500, 500]);
        });

        it("Should fill user data with correct args", async function() {
            const amount = 1000;
            const mintAmount = 100;
            await yvnToken.mint(sender.address, 10000);
            await yvnToken.connect(sender).approve(stake.address, amount);
            await stake.connect(sender).deposit(amount);
            const [, tokenAmountBefore, depositsBefore, withdrawsBefore] = await stake.getUserData(sender.address);
            await yvnToken.mint(stake.address, mintAmount);
            await lpToken.connect(sender).approve(stake.address, 500);
            await stake.connect(sender).withdraw(500);
            const time = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            const [timeAfter, tokenAmountAfter, depositsAfter, withdrawsAfter] = await stake.getUserData(sender.address);
            
            expect(timeAfter).to.eq(time);
            expect(tokenAmountAfter).to.eq(tokenAmountBefore - 500);
            expect(depositsAfter).to.eq(depositsBefore);
            expect(withdrawsAfter).to.eq(withdrawsBefore + 1);
        });

        it("Should emited with correct args", async function() {
            const amount = 1000;
            const mintAmount = 100;
            await yvnToken.mint(sender.address, 10000);
            await yvnToken.connect(sender).approve(stake.address, amount);
            await stake.connect(sender).deposit(amount);
            await yvnToken.mint(stake.address, mintAmount);
            await lpToken.connect(sender).approve(stake.address, 500);
            const tx = await stake.connect(sender).withdraw(500);
            const [time,,,] = await stake.getUserData(sender.address);

            await expect(tx)
                .to.emit(stake, 'Withdraw')
                .withArgs(sender.address, 534, time);
        });

        it("Should reverted with 'Staking: Not enough funds!'", async function() {
            const tx = stake.connect(sender).withdraw(500);

            await expect(tx)
                .to.revertedWith('Staking: Not enough funds!');
        });

        it("Should reverted with 'Staking: Not enough allowance!'", async function() {
            const amount = 1000;
            const mintAmount = 100;
            await yvnToken.mint(sender.address, 10000);
            await yvnToken.connect(sender).approve(stake.address, amount);
            await stake.connect(sender).deposit(amount);
            await yvnToken.mint(stake.address, mintAmount);
            const tx = stake.connect(sender).withdraw(500);

            await expect(tx)
                .to.revertedWith('Staking: Not enough allowance!');
        });
    });

});