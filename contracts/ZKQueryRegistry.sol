// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ZKQueryRegistry {
    struct QueryProof {
        bytes32 queryHash;
        bytes zkProof;
        uint256 verifiedAt;
    }

    mapping(bytes32 => QueryProof) public verifiedQueries;

    event QueryVerified(
        bytes32 indexed queryHash,
        address indexed submittedBy,
        uint256 verifiedAt
    );

    function submitZKQuery(bytes32 queryHash, bytes memory zkProof) public {
        require(queryHash != 0x0, "Invalid query");
        require(zkProof.length > 32, "Insufficient proof length");

        // For real implementations, you'd integrate with a zkVerifier contract here
        bool isValid = verifyProofOffChain(queryHash, zkProof);
        require(isValid, "Invalid zk-SNARK proof");

        verifiedQueries[queryHash] = QueryProof({
            queryHash: queryHash,
            zkProof: zkProof,
            verifiedAt: block.timestamp
        });

        emit QueryVerified(queryHash, msg.sender, block.timestamp);
    }

    function getQueryStatus(bytes32 queryHash) external view returns (bool exists, uint256 verifiedAt) {
        QueryProof memory qp = verifiedQueries[queryHash];
        exists = qp.verifiedAt > 0;
        verifiedAt = qp.verifiedAt;
    }

    // Dummy proof verifier — replace with actual zkVerifier logic
    function verifyProofOffChain(bytes32 queryHash, bytes memory zkProof) internal pure returns (bool) {
        return zkProof.length > 32 && queryHash != 0x0;
    }
}
