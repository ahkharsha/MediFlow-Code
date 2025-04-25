const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MediFlow Benchmark - Gas and Latency", function () {
  let ehrContract;
  let daoContract;
  let patient;
  let doctor;
  const N = 100; // Number of runs per function

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
      totalLatency += (end - start) / 1000; // Convert ms to seconds
    }

    const avgGas = totalGas.div(N);
    const avgLatency = totalLatency / N;

    console.log(`${label} -> Avg Gas: ${avgGas.toString()}, Avg Latency: ${avgLatency.toFixed(2)}s`);
  }

  it("Benchmark Core Operations", async function () {
    // Benchmarks EHR Upload
    await benchmark("EHR Upload", async (i) => {
      const dummyHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("dummy" + i));
      return ehrContract.connect(patient).createRecord(dummyHash);
    });

    // Benchmarks Record Retrieval
    await benchmark("Record Retrieval", async (i) => {
      return ehrContract.connect(patient).getRecord(patient.address);
    });

    // Benchmarks DAO Proposal Submission
    await benchmark("DAO Proposal Submission", async (i) => {
      return daoContract.connect(admin).submitProposal(`Proposal #${i}`, ethers.utils.parseEther("1"));
    });

    // Benchmarks Token-Weighted Voting
    await benchmark("Token-Weighted Voting", async (i) => {
      return daoContract.connect(admin).voteProposal(i, true);
    });
  });
});
