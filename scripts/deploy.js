// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const networkName = hre.network.name;

  const owner = "0xcfC55DF43fB52CC8a6107AFb74798054Aa11f5c4";
  const deployment = {
    sepolia: {
      vRFv2Consumer: "0x8f9359a39D2e50Af4f5af5926bAaD8c19345CD2D",
    },
    goerli: {
      vRFv2Consumer: "0x86b80E6076fB5a2f8444dd927E501Ec934b4D4AF",
    },
  };
  const [deployer] = await ethers.getSigners();

  console.log(
    `Deploying contracts with the account: ${deployer.address} in ${networkName}`
  );
  const PandaNFT = await hre.ethers.getContractFactory("PandaNFT");
  const pandaNFT = await PandaNFT.deploy(
    owner,
    deployment[networkName].vRFv2Consumer
  );

  await pandaNFT.deployed();

  console.log(`PandaNFT was deployed to ${pandaNFT.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
