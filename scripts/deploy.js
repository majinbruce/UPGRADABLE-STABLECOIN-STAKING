const { ethers } = require("hardhat");

async function main() {
  const [owner, addr1] = await ethers.getSigners();
  const daiPricefeed = "0x2bA49Aaa16E6afD2a993473cfB70Fa8559B523cF";
  const DAIPerUSD = "0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735";

  const TOKEN = await ethers.getContractFactory("MyTokenUpgradeable");
  const token = await upgrades.deployProxy(TOKEN, { kind: "uups" });
  await token.deployed();

  console.log("\n token deployed at", token.address);

  const chainlinkaggregator = await ethers.getContractFactory(
    "chainlinkAggregator"
  );
  const aggregator = await chainlinkaggregator.deploy();
  await aggregator.deployed();

  console.log("\n chainlinkaggregator deployed at", aggregator.address);
  // Deploy the  contract.
  const STAKING = await ethers.getContractFactory("staking");
  const staking = await upgrades.deployProxy(
    STAKING,
    [token.address, aggregator.address],
    {
      kind: "uups",
    }
  );
  await staking.deployed();
  console.log("\n staking deployed at", staking.address);

  //distribute tokens
  await token.mint(staking.address, 10000);
  await token.transfer(owner.address, 1000);

  await token.approve(staking.address, 5000);
  await token.connect(addr1).approve(staking.address, 5000);

  await token.approve(owner.address, 5000);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
