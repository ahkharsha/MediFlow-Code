// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {
    struct Permission {
        bool canRead;
        bool canWrite;
    }

    mapping(address => mapping(address => Permission)) public ehrPermissions;

    event AccessGranted(address indexed patient, address indexed doctor);
    event AccessRevoked(address indexed patient, address indexed doctor);

    function grantAccess(address _doctor) external {
        ehrPermissions[msg.sender][_doctor] = Permission(true, false);
        emit AccessGranted(msg.sender, _doctor);
    }

    function revokeAccess(address _doctor) external {
        delete ehrPermissions[msg.sender][_doctor];
        emit AccessRevoked(msg.sender, _doctor);
    }

    function hasAccess(address _patient, address _doctor) public view returns (bool) {
        return ehrPermissions[_patient][_doctor].canRead;
    }
}
