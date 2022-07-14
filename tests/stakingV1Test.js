const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers, upgrades } = require("hardhat");

describe("stablecoin staking", () => {
  let owner;
  let addr1;
  let addr2;
  let dai;
  let DAI;
  const daiPricefeed = "0x2bA49Aaa16E6afD2a993473cfB70Fa8559B523cF";
  let chainlinkaggregator;
  let aggregator;

  let token;
  let TOKEN;

  let STAKING;
  let staking;
  const DAIPerUSD = "0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735";
  const USDCPerUSD = "0xa24de01df22b63d23Ebc1882a5E3d4ec0d907bFB";
  beforeEach(async () => {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // Deploy the Token contract.
    TOKEN = await ethers.getContractFactory("MyTokenUpgradeable");
    token = await upgrades.deployProxy(TOKEN, { kind: "uups" });
    await token.deployed();

    chainlinkaggregator = await ethers.getContractFactory(
      "chainlinkAggregator"
    );
    aggregator = await chainlinkaggregator.deploy();
    await aggregator.deployed();
    // Deploy the  contract.
    STAKING = await ethers.getContractFactory("staking");
    staking = await upgrades.deployProxy(
      STAKING,
      [token.address, aggregator.address],
      {
        kind: "uups",
      }
    );
    await staking.deployed();

    //distribute tokens
    await token.transfer(staking.address, 10000);
    await token.transfer(owner.address, 10000);

    await token.approve(staking.address, 5000);
    await token.connect(addr1).approve(staking.address, 5000);

    await token.approve(owner.address, 5000);

    DAI = await ethers.getContractFactory("Dai");
    dai = await DAI.attach(DAIPerUSD);

    // gib stakingV1 contract allowance for Dai tokens.
    dai.connect(addr1).approve(staking.address, 101);
    dai.connect(addr2).approve(staking.address, 101);
    //add dai stablecoin support
    await staking.addNewStableCoin(DAIPerUSD, daiPricefeed, 1);
  });

  it("owner should not be able to add multiple stablecoin for the same id ", async function () {
    await expect(
      staking.addNewStableCoin(DAIPerUSD, daiPricefeed, 1)
    ).to.be.revertedWith(
      "addNewStableCoin: stablecoin with this Id or address already exists"
    );
  });
  it("owner should be able to remove stablecoin", async function () {
    await staking.removeStablecoin(DAIPerUSD, 1);
    await expect(staking.connect(addr1).stakeCoin(1, 100)).to.be.revertedWith(
      "addNewStableCoin: stablecoin with this Id does not exist"
    );
  });

  it("user should be able to stake stablecoin ", async function () {
    await staking.connect(addr1).stakeCoin(1, 100);
    const contractbalance = await dai.balanceOf(staking.address);
    //see if the transfer was succesful
    expect(contractbalance).to.equal(100);
  });

  it("user should be able to unstake stakecoin ", async function () {
    await staking.connect(addr1).stakeCoin(1, 101);
    const balanceBeforeStaking = await token.balanceOf(addr1.address);
    expect(balanceBeforeStaking).to.equal(0);
    // stake 100 tokens for 6 months
    await ethers.provider.send("evm_increaseTime", [2629743 * 6]);

    // cannot withdraw more tokens than staked
    await expect(staking.connect(addr1).unStakeCoin(1, 150)).to.be.revertedWith(
      "UnstakeCoin: you do not have enough staked tokens"
    );
    const daiBalancebefore = await dai.balanceOf(addr1.address);

    await staking.connect(addr1).unStakeCoin(1, 101);
    const balanceafterStaking = await token.balanceOf(addr1.address);
    expect(balanceBeforeStaking).to.not.equal(balanceafterStaking);

    //100 tokens staked for 6 months at 10percent apr + 2 percent perks effective apr=12 should receive 6 tokens
    expect(balanceafterStaking).to.equal(6);
    const daiBalanceAfter = await dai.balanceOf(addr1.address);

    // user gets back his staked stablecoin
    const diff = daiBalanceAfter - daiBalancebefore;
    expect(diff).to.equal(101);
  });
});
