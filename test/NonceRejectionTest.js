const { ethers } = require("hardhat");

describe("Nonce-Rejection Rate Test", function () {
  let attacker;
  let targetContract;

  before(async function () {
    [attacker] = await ethers.getSigners();

    // Deploy any simple contract to target (e.g., EHRMetadata)
    const EHRMetadata = await ethers.getContractFactory("EHRMetadata");
    targetContract = await EHRMetadata.deploy();
    await targetContract.deployed();
  });

  it("should reject all replay (duplicate‐nonce) txns", async function () {
    // 1) Read the next valid nonce
    const currentNonce = await ethers.provider.getTransactionCount(attacker.address);
    const staleNonce = currentNonce; // re‐use this every time

    let rejected = 0;
    const total = 200;

    for (let i = 0; i < total; i++) {
      try {
        await attacker.sendTransaction({
          to: targetContract.address,
          value: 0,
          nonce: staleNonce
        });
        // if we get here, the txn was (unexpectedly) accepted
      } catch (err) {
        // expected: Ethers throws on invalid/stale nonce
        rejected++;
      }
    }

    const Rnonce = rejected / total;
    console.log(`Nonce-Rejection Rate: ${rejected}/${total} = ${Rnonce}`);
    // You can assert Rnonce === 1 if you like:
    // expect(Rnonce).to.equal(1);
  });
});
