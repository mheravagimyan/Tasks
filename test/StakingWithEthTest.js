const { ethers } = require("hardhat");
const { expect } = require("chai");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe.only("Staking with ETH", function () {
    let owner;
    let sender1;
    let sender2;
    let token;
    let stake;

    beforeEach(async function () {
        [owner, sender1, sender2] = await ethers.getSigners();

        const YVNToken = await ethers.getContractFactory("YVNToken", owner);
        token = await YVNToken.deploy("YVN Token", "YVN", 100000000000000);
        await token.deployed();

        const SWE = await ethers.getContractFactory("StakingWithETH", owner);
        stake = await SWE.deploy(token.address, 5);
        await stake.deployed();

        await token.mint(stake.address, 10000000);
    });

    describe("Initialization", function () {
        it("Should be deployed with correct args!", async function () {
            expect(await stake.token()).to.eq(token.address);
            expect(await stake.x()).to.eq(5);
        });

        it("YVN Token should be deployed with correct args!", async function () {
            expect(await token.name()).to.eq("YVN Token");
            expect(await token.symbol()).to.eq("YVN");
            expect(await token.maxSupply()).to.eq(100000000000000);
        });
    });

    describe("Deposit", function () {
        it("Should be possible to deposit!", async function () {
            const amount = 1000;
            const tx1 = await stake.connect(sender1).deposit({ value: amount });
            const tx2 = await stake.connect(sender2).deposit({ value: 2 * amount });


            await expect(tx1)
                .to.changeEtherBalances([sender1, stake], [-amount, amount]);

            await expect(tx2)
                .to.changeEtherBalances([sender2, stake], [-2 * amount, 2 * amount]);

        });

        it("Should fill user data with correct args!(1 user)", async function () {
            const amount = 1000;
            await stake.connect(sender1).deposit({ value: amount });
            [ethBalance, reward] = await stake.getUserData(sender1.address);

            expect(ethBalance).to.eq(amount);
            expect(reward).to.eq(0);
        });

        it("Should fill user data with correct args!(2 user)", async function () {
            const amount = 1000;
            await stake.connect(sender1).deposit({ value: amount });
            const time1 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            await time.increase(2);
            await stake.connect(sender2).deposit({ value: 2 * amount });
            const time2 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            [ethBalance2, reward2] = await stake.getUserData(sender2.address);
            [ethBalance1, reward1] = await stake.getUserData(sender1.address);

            expect(ethBalance1).to.eq(amount);
            expect(reward1).to.eq((time2 - time1) * 5);
            expect(ethBalance2).to.eq(2 * amount);
            expect(reward2).to.eq(0);
        });

        it("Should reverted with 'StakingWithETH: Not enough funds on your balance!'", async function () {
            const tx = stake.connect(sender1).deposit();

            await expect(tx)
                .to.revertedWith('StakingWithETH: Not enough funds on your balance!');
        });

        it("Should emited with correct args!", async function () {
            const amount = 1000;
            const tx = await stake.connect(sender1).deposit({ value: amount });

            await expect(tx)
                .to.emit(stake, 'Deposit')
                .withArgs(sender1.address, amount);
        });
    });

    describe("Withdraw", function () {
        it("Should be possible to withdraw!", async function () {
            const amount = 1000;
            await stake.connect(sender1).deposit({ value: amount });
            await time.increase(2);
            await stake.connect(sender2).deposit({ value: 2 * amount });
            [ethBalance1, reward1] = await stake.getUserData(sender1.address);
            const time1 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            await time.increase(2);
            const tx = await stake.connect(sender1).withdraw();
            [, reward2] = await stake.getUserData(sender2.address);
            const time2 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            const rewardAmount1 = parseInt(reward1) + (time2 - time1) * 5 / 3;
            const rewardAmount2 = (time2 - time1) * 10 / 3;

            await expect(tx)
                .to.changeEtherBalances([stake, sender1], [-ethBalance1, ethBalance1]);
            await expect(tx)
                .to.changeTokenBalances(token, [stake, sender1], [-rewardAmount1, rewardAmount1]);
            expect(reward2)
                .to.eq(rewardAmount2);

        });

        it("Should fill user data with correct args!", async function () {
            const amount = 1000;
            await stake.connect(sender1).deposit({ value: amount });
            await time.increase(2);
            await stake.connect(sender2).deposit({ value: 2 * amount });
            const time1 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            await time.increase(2);
            await stake.connect(sender1).withdraw();
            const time2 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            [ethBalance1, reward1] = await stake.getUserData(sender1.address);
            [ethBalance2, reward2] = await stake.getUserData(sender2.address);
            const rewardAmount2 = (time2 - time1) * 10 / 3;

            expect(ethBalance1).to.eq(0);
            expect(reward1).to.eq(0);
            expect(ethBalance2).to.eq(2 * amount);
            expect(reward2).to.eq(rewardAmount2);
        });

        it("Should reverted with 'StakingWithETH: Have no deposit!'", async function () {
            const tx = stake.connect(sender1).withdraw();
            await expect(tx)
                .to.revertedWith('StakingWithETH: Have no deposit!');
        });

        it("Should emited with correct args!", async function () {
            const amount = 1000;
            await stake.connect(sender1).deposit({ value: amount });
            await time.increase(2);
            await stake.connect(sender2).deposit({ value: 2 * amount });
            [ethBalance1, reward1] = await stake.getUserData(sender1.address);
            const time1 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            await time.increase(2);
            const tx = await stake.connect(sender1).withdraw();
            const time2 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            const rewardAmount1 = parseInt(reward1) + (time2 - time1) * 5 / 3;

            await expect(tx)
                .to.emit(stake, 'Withdraw')
                .withArgs(sender1.address, ethBalance1, rewardAmount1);
        });
    });

    describe("Claim", function() {
        it("Should be possible to claim!", async function() {
            const amount = 1000;
            await stake.connect(sender1).deposit({ value: amount });
            await time.increase(2);
            await stake.connect(sender2).deposit({ value: 2 * amount });
            [ethBalance1, reward1] = await stake.getUserData(sender1.address);
            const time1 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            await time.increase(2);
            const tx = await stake.connect(sender1).claim();
            [, reward2] = await stake.getUserData(sender2.address);
            const time2 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            const rewardAmount1 = parseInt(reward1) + (time2 - time1) * 5 / 3;
            const rewardAmount2 = (time2 - time1) * 10 / 3;

            await expect(tx)
                .to.changeTokenBalances(token, [stake, sender1], [-rewardAmount1, rewardAmount1]);
            expect(reward2)
                .to.eq(rewardAmount2);
        });

        it("Should fill user data with correct args!", async function() {
            const amount = 1000;
            await stake.connect(sender1).deposit({ value: amount });
            await time.increase(2);
            await stake.connect(sender2).deposit({ value: 2 * amount });
            const time1 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            await time.increase(2);
            await stake.connect(sender1).claim();
            const time2 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            [ethBalance1, reward1] = await stake.getUserData(sender1.address);
            [ethBalance2, reward2] = await stake.getUserData(sender2.address);
            const rewardAmount2 = (time2 - time1) * 10 / 3;

            expect(ethBalance1).to.eq(amount);
            expect(reward1).to.eq(0);
            expect(ethBalance2).to.eq(2 * amount);
            expect(reward2).to.eq(rewardAmount2);
        });

        it("Should reverted with 'StakingWithETH: Have no deposit!'", async function () {
            const tx = stake.connect(sender1).claim();
            
            await expect(tx)
                .to.revertedWith('StakingWithETH: Have no deposit!');
        });

        it("Should emited with correct args!", async function () {
            const amount = 1000;
            await stake.connect(sender1).deposit({ value: amount });
            await time.increase(2);
            await stake.connect(sender2).deposit({ value: 2 * amount });
            [ethBalance1, reward1] = await stake.getUserData(sender1.address);
            const time1 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            await time.increase(2);
            const tx = await stake.connect(sender1).claim();
            const time2 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
            const rewardAmount1 = parseInt(reward1) + (time2 - time1) * 5 / 3;

            await expect(tx)
                .to.emit(stake, 'Claim')
                .withArgs(sender1.address, rewardAmount1);
        });        
    });

    describe("Check contract view functions!", function() {    
        describe("Get user data!", function() {
            it("Should return user data!", async function() {
                const amount = 1000;
                await stake.connect(sender1).deposit({ value: amount });
                const time1 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
                await time.increase(2);
                await stake.connect(sender2).deposit({ value: 2 * amount });
                const time2 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
                [ethBalance1, reward1] = await stake.getUserData(sender1.address);
                rewardAmount1 = (time2 - time1) * 5;

                expect(ethBalance1).to.eq(amount);
                expect(reward1).to.eq(rewardAmount1);
            });

            it("Should rewerted with 'StakingWithETH: Must be owner or get only own data!'", async function() {
                const tx = stake.connect(sender1).getUserData(sender2.address);

                await expect(tx)
                    .to.revertedWith('StakingWithETH: Must be owner or get only own data!');
            });
        });

        describe("Get current reward!", function() {
            it("Should return amount of token that accumulated!", async function() {
                const amount = 1000;
                await stake.connect(sender1).deposit({ value: amount });
                const time1 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
                await time.increase(10);
                const time2 = (await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp;
                const amountOfTokens = await stake.getCurrentReward();

                expect(amountOfTokens).to.eq((time2 - time1) * 5);
            });

            it("Should reverted with 'StakingWithETH: Not an owner!'", async function() {
                const tx =  stake.connect(sender1).getCurrentReward();

                await expect(tx)
                    .to.revertedWith('StakingWithETH: Not an owner!');
            });
        });
        
    });

});