const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers, upgrades } = require("hardhat");

describe("stablecoin staking", () => {
  let owner;
  let addr1;
  let addr2;

  let token;
  let TOKEN;

  let STAKING;
  let staking;
  const DAIPerUSD = "0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa";
  const USDCPerUSD = "0xa24de01df22b63d23Ebc1882a5E3d4ec0d907bFB";
  beforeEach(async () => {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // Deploy the Token contract.
    TOKEN = await ethers.getContractFactory("MyTokenUpgradeable");
    token = await upgrades.deployProxy(TOKEN, { kind: "uups" });
    await token.deployed();

    // Deploy the  contract.
    STAKING = await ethers.getContractFactory("staking");
    staking = await upgrades.deployProxy(STAKING, [token.address], {
      kind: "uups",
    });
    await staking.deployed();

    //distribute tokens
    await token.transfer(staking.address, 10000);
    await token.transfer(owner.address, 10000);
    await token.transfer(addr1.address, 10000);
    await token.approve(staking.address, 5000);
    await token.connect(addr1).approve(staking.address, 5000);

    await token.approve(owner.address, 5000);
  });

  it("owner should be able to add & remove stablecoins ", async function () {
    await staking.addNewStableCoin(DAIPerUSD, 1);

    await staking.addNewStableCoin(USDCPerUSD, 1);
    //  await staking.addNewStableCoin(DAI_Contract, 1);
  });
});
