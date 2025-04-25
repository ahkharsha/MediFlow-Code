// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOProposal {
    struct Proposal {
        string description;
        address recipient;
        uint256 amount;
        int256 votes; // Can be positive or negative
        bool executed;
        uint256 deadline;
    }

    struct DAOMember {
        uint256 tokenBalance;
        bool isMember;
    }

    uint256 public daoVoteWeightPercentage = 100; // 100% by default
    uint256 public proposalDuration = 3 days;
    uint256 public quorum = 1000; // Minimum positive vote count to pass
    address public treasury;
    address public owner;

    Proposal[] public daoProposals;
    mapping(address => DAOMember) public daoMembers;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event ProposalSubmitted(uint256 indexed proposalId, string description, address proposer);
    event Voted(uint256 indexed proposalId, address voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId, address recipient, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyDAOMember() {
        require(daoMembers[msg.sender].isMember, "Not a DAO member");
        _;
    }

    constructor() {
        owner = msg.sender;
        treasury = address(this);
    }

    function addDAOMember(address member, uint256 balance) external onlyOwner {
        daoMembers[member] = DAOMember(balance, true);
    }

    function submitProposal(string memory description, address recipient, uint256 amount) external onlyDAOMember {
        Proposal memory newProposal = Proposal({
            description: description,
            recipient: recipient,
            amount: amount,
            votes: 0,
            executed: false,
            deadline: block.timestamp + proposalDuration
        });

        daoProposals.push(newProposal);
        emit ProposalSubmitted(daoProposals.length - 1, description, msg.sender);
    }

    function voteDAOProposal(uint256 _proposalId, bool _support) public onlyDAOMember {
        require(_proposalId < daoProposals.length, "Invalid proposal ID");
        require(block.timestamp <= daoProposals[_proposalId].deadline, "Voting period over");
        require(!hasVoted[_proposalId][msg.sender], "Already voted");

        uint256 voteWeight = (daoMembers[msg.sender].tokenBalance * daoVoteWeightPercentage) / 100;
        if (_support) {
            daoProposals[_proposalId].votes += int256(voteWeight);
        } else {
            daoProposals[_proposalId].votes -= int256(voteWeight);
        }

        hasVoted[_proposalId][msg.sender] = true;
        emit Voted(_proposalId, msg.sender, _support, voteWeight);
    }

    function executeDAOProposal(uint256 _proposalId) public onlyDAOMember {
        require(_proposalId < daoProposals.length, "Invalid proposal ID");
        Proposal storage prop = daoProposals[_proposalId];
        require(!prop.executed, "Already executed");
        require(block.timestamp > prop.deadline, "Voting still active");
        require(prop.votes > int256(quorum), "Insufficient support");

        prop.executed = true;
        payable(prop.recipient).transfer(prop.amount);

        emit ProposalExecuted(_proposalId, prop.recipient, prop.amount);
    }

    // Allow ETH deposits to DAO treasury
    receive() external payable {}

    function getProposalCount() external view returns (uint256) {
        return daoProposals.length;
    }

    function getProposal(uint256 id) external view returns (
        string memory description,
        address recipient,
        uint256 amount,
        int256 votes,
        bool executed,
        uint256 deadline
    ) {
        Proposal memory p = daoProposals[id];
        return (p.description, p.recipient, p.amount, p.votes, p.executed, p.deadline);
    }
}
