const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MediFlow Benchmark – Gas and Latency", function () {
  let ehrContract, daoContract;
  let patient, doctor, admin;
  const N = 100; // runs per function

  before(async function () {
    [patient, doctor, admin] = await ethers.getSigners();

    // Deploy EHRMetadata
    const EHRMetadata = await ethers.getContractFactory("EHRMetadata");
    ehrContract = await EHRMetadata.deploy();
    await ehrContract.deployed();

    // Deploy DAOProposal
    const DAOProposal = await ethers.getContractFactory("DAOProposal");
    daoContract = await DAOProposal.deploy();
    await daoContract.deployed();
  });

  async function benchmark(label, action) {
    let totalGas = ethers.BigNumber.from(0);
    let totalLatency = 0;

    for (let i = 0; i < N; i++) {
      const start = Date.now();
      const tx = await action(i);
      const receipt = await tx.wait();
      const end = Date.now();

      totalGas = totalGas.add(receipt.gasUsed);
      totalLatency += (end - start) / 1000; // ms → s
    }

    const avgGas = totalGas.div(N);
    const avgLatency = totalLatency / N;
    console.log(`${label} → Avg Gas: ${avgGas.toString()}, Avg Latency: ${avgLatency.toFixed(2)}s`);
  }

  it("Benchmark Core Operations", async function () {
    // 1) EHR Upload
    await benchmark("EHR Upload", async (i) => {
      const dummyHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("dummy" + i));
      return ehrContract.connect(patient).createRecord(dummyHash);
    });

    // 2) Record Retrieval
    await benchmark("Record Retrieval", async (i) => {
      return ehrContract.connect(patient).getRecord(patient.address);
    });

    // 3) DAO Proposal Submission
    await benchmark("DAO Proposal Submission", async (i) => {
      return daoContract.connect(admin).submitProposal(`Proposal #${i}`, ethers.utils.parseEther("1"));
    });

    // 4) Token-Weighted Voting
    await benchmark("Token-Weighted Voting", async (i) => {
      return daoContract.connect(admin).voteProposal(i, true);
    });
  });
});
