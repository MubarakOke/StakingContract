import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
  import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
  import { expect, assert } from "chai";
  import { ethers } from "hardhat";
  
  
  describe("Staking Contract Test", function () {
    async function deployStaking(){
      const ERC20 = await ethers.getContractFactory("ERC20");
      const erc20 = await ERC20.deploy();

      const rewardPool= 100000
      const ONE_MINUTE_IN_SECS = 60 * 60;
      const unlockTime = (await time.latest()) + ONE_MINUTE_IN_SECS;

      const Staking = await ethers.getContractFactory("Staking");
      const staking = await Staking.deploy(erc20.target, unlockTime, rewardPool);
      
      const [account1, account2] = await ethers.getSigners();
      const amountToStake = 100;

      approveERC20(account1.address, staking.target, rewardPool)
      return { erc20, staking, account1, account2, amountToStake };
    };

    async function approveERC20(account: any, address: any, amount: any){
      const { erc20 } = await loadFixture(deployStaking);
      const address2Signer= await ethers.getSigner(account.address);
      await erc20.connect(address2Signer).approve(address, amount);
    };
  
  
    describe("Contract", async () => {
        it("can stake successfully", async () => {
            const { staking, account1, amountToStake} = await loadFixture(deployStaking);
            await approveERC20(account1, staking.target, amountToStake)
            await staking.stake(amountToStake)

            const stakedBalance= await staking.checkUserStakedBalance(account1.address)
            expect(stakedBalance).to.equal(amountToStake);
        });
    })     
           
  });

