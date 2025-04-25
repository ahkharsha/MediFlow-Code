// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EHRMetadata {
    struct Record {
        string ipfsHash;
        address doctor;
        uint256 timestamp;
        bytes32 dataHash;
    }

    mapping(address => Record[]) public patientRecords;

    event RecordAdded(
        address indexed patient,
        address indexed doctor,
        string ipfsHash,
        bytes32 dataHash,
        uint256 timestamp
    );

    function addRecord(address patient, string memory ipfsHash, bytes32 dataHash) external {
        require(bytes(ipfsHash).length > 0, "Invalid IPFS hash");

        Record memory newRecord = Record({
            ipfsHash: ipfsHash,
            doctor: msg.sender,
            timestamp: block.timestamp,
            dataHash: dataHash
        });

        patientRecords[patient].push(newRecord);

        emit RecordAdded(patient, msg.sender, ipfsHash, dataHash, block.timestamp);
    }

    function getRecordCount(address patient) external view returns (uint256) {
        return patientRecords[patient].length;
    }

    function getRecordByIndex(address patient, uint256 index)
        external
        view
        returns (string memory ipfsHash, address doctor, bytes32 dataHash, uint256 timestamp)
    {
        require(index < patientRecords[patient].length, "Invalid index");
        Record memory rec = patientRecords[patient][index];
        return (rec.ipfsHash, rec.doctor, rec.dataHash, rec.timestamp);
    }

    function verifyRecord(
        address patient,
        uint256 index,
        bytes32 expectedHash
    ) external view returns (bool) {
        require(index < patientRecords[patient].length, "Invalid index");
        return patientRecords[patient][index].dataHash == expectedHash;
    }
}
