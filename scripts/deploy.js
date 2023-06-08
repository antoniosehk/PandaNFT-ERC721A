// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const OWNER = "0xcfC55DF43fB52CC8a6107AFb74798054Aa11f5c4";
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  const PandaNFT = await hre.ethers.getContractFactory("PandaNFT");
  const pandaNFT = await PandaNFT.deploy(OWNER);

  await pandaNFT.deployed();

  console.log(`PandaNFT was deployed to ${pandaNFT.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
