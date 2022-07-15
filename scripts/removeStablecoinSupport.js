const { ethers } = require("hardhat");

async function main() {
  const [owner, addr1] = await ethers.getSigners();
  const daiPricefeed = "0x2bA49Aaa16E6afD2a993473cfB70Fa8559B523cF";
  const DAIPerUSD = "0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735";

  const stakingV1ProxyContract = "0xDa9974d844F56c02Ae274E2Ce2E157fC225F4b57";
  const STAKING = await ethers.getContractFactory("staking");
  const staking = await STAKING.attach(stakingV1ProxyContract);

  //remove dai stablecoin support
  await staking.removeStablecoin(DAIPerUSD, 1); 
  console.log("\n stablecoin removed");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
