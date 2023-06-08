const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const hre = require("hardhat");

describe("PandaNFT", function () {
  const MAX_SUPPLY = 100;
  const MINT_FEE = hre.ethers.utils.parseEther("0.001");
  const MINT_FEE_INCREMENT = hre.ethers.utils.parseEther("0.0001");

  async function deployFixture() {
    const [deploymentAccount, otherAccount] = await ethers.getSigners();
    const PandaNFT = await ethers.getContractFactory("PandaNFT");
    const pandaNFT = await PandaNFT.deploy(deploymentAccount.address);
    return { pandaNFT, deploymentAccount, otherAccount };
  }

  describe("Deployment", function () {
    it("should set the right owner", async function () {
      const { pandaNFT, deploymentAccount } = await loadFixture(deployFixture);
      expect(await pandaNFT.owner()).to.equal(deploymentAccount.address);
    });

    it("should set the right max supply", async function () {
      const { pandaNFT } = await loadFixture(deployFixture);
      expect(await pandaNFT.MAX_SUPPLY()).to.equal(MAX_SUPPLY);
    });

    it("should set the right mint fee", async function () {
      const { pandaNFT } = await loadFixture(deployFixture);
      expect(await pandaNFT.MINT_FEE()).to.equal(MINT_FEE);
    });

    it("should set the right mint fee incremnet", async function () {
      const { pandaNFT } = await loadFixture(deployFixture);
      expect(await pandaNFT.MINT_FEE_INCREMENT()).to.equal(MINT_FEE_INCREMENT);
    });
  });

  describe("Increase Mint Fee", function () {
    it("should allow owner to increase mint fee", async function () {
      const { pandaNFT } = await loadFixture(deployFixture);
      const newMintFee = hre.ethers.utils.parseEther("0.0011");

      expect(await pandaNFT.MINT_FEE()).to.equal(MINT_FEE);
      expect(await pandaNFT.increaseMintFee()).not.to.be.reverted;
      expect(await pandaNFT.MINT_FEE()).to.equal(newMintFee);
    });
  });

  it("should not allow other account to increase mint fee", async function () {
    const { pandaNFT, otherAccount } = await loadFixture(deployFixture);

    expect(await pandaNFT.MINT_FEE()).to.equal(MINT_FEE);
    await expect(
      pandaNFT.connect(otherAccount).increaseMintFee()
    ).to.be.revertedWith("You are not permitted to increase the mint fee");
    expect(await pandaNFT.MINT_FEE()).to.equal(MINT_FEE);
  });

  it("should not allow other account to setWhiteListAddress", async function () {
    const { pandaNFT, otherAccount } = await loadFixture(deployFixture);

    expect(
      await pandaNFT
        .connect(otherAccount)
        .whiteListAddress(otherAccount.address)
    ).to.equal(false);
    await expect(
      pandaNFT
        .connect(otherAccount)
        .setWhiteListAddress(otherAccount.address, true)
    ).to.be.reverted;
    expect(
      await pandaNFT
        .connect(otherAccount)
        .whiteListAddress(otherAccount.address)
    ).to.equal(false);
  });

  it("should allow owner to setWhiteListAddress", async function () {
    const { pandaNFT, otherAccount } = await loadFixture(deployFixture);

    expect(await pandaNFT.whiteListAddress(otherAccount.address)).to.equal(
      false
    );
    await expect(pandaNFT.setWhiteListAddress(otherAccount.address, true)).not
      .to.be.reverted;
    expect(await pandaNFT.whiteListAddress(otherAccount.address)).to.equal(
      true
    );
  });

  it("should allow other account to increase mint fee if the account is whitelisted", async function () {
    const { pandaNFT, otherAccount } = await loadFixture(deployFixture);
    const newMintFee = hre.ethers.utils.parseEther("0.0011");

    expect(await pandaNFT.MINT_FEE()).to.equal(MINT_FEE);
    await expect(pandaNFT.setWhiteListAddress(otherAccount.address, true)).not
      .to.be.reverted;
    await expect(pandaNFT.connect(otherAccount).increaseMintFee()).not.to.be
      .reverted;
    expect(await pandaNFT.MINT_FEE()).to.equal(newMintFee);
  });
});
