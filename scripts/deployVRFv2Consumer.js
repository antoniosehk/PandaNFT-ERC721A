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
      subscriptionId: 2601,
      vrfCoordinatorAddress: "0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625",
      keyHash:
        "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c",
    },
    goerli: {
      subscriptionId: 12521,
      vrfCoordinatorAddress: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
      keyHash:
        "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
    },
  };

  const [deployer] = await ethers.getSigners();

  console.log(
    `Deploying contracts with the account: ${deployer.address} in ${networkName}`
  );

  const VRFv2Consumer = await hre.ethers.getContractFactory("VRFv2Consumer");
  const vRFv2Consumer = await VRFv2Consumer.deploy(
    owner,
    deployment[networkName].subscriptionId,
    deployment[networkName].vrfCoordinatorAddress,
    deployment[networkName].keyHash
  );

  await vRFv2Consumer.deployed();

  console.log(`VRFv2Consumer was deployed to ${vRFv2Consumer.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
