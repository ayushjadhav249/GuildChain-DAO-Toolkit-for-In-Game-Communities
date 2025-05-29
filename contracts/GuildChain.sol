// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract GuildChain {
    struct Proposal {
        string description;
        uint256 voteDeadline;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
        mapping(address => bool) voters;
    }

    address public guildLeader;
    mapping(address => bool) public members;
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    event MemberAdded(address member);
    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, address voter, bool vote);
    event ProposalExecuted(uint256 proposalId, bool success);

    modifier onlyLeader() {
        require(msg.sender == guildLeader, "Only guild leader can perform this");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender], "Only guild members can vote");
        _;
    }

    constructor() {
        guildLeader = msg.sender;
        members[msg.sender] = true;
    }

    function addMember(address newMember) external onlyLeader {
        members[newMember] = true;
        emit MemberAdded(newMember);
    }

    function createProposal(string memory _description, uint256 _durationInSeconds) external onlyMember {
        Proposal storage p = proposals[proposalCount];
        p.description = _description;
        p.voteDeadline = block.timestamp + _durationInSeconds;

        emit ProposalCreated(proposalCount, _description);
        proposalCount++;
    }

    function voteOnProposal(uint256 proposalId, bool voteYes) external onlyMember {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp < p.voteDeadline, "Voting closed");
        require(!p.voters[msg.sender], "Already voted");

        if (voteYes) {
            p.yesVotes++;
        } else {
            p.noVotes++;
        }

        p.voters[msg.sender] = true;
        emit Voted(proposalId, msg.sender, voteYes);
    }

    function executeProposal(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp >= p.voteDeadline, "Voting still open");
        require(!p.executed, "Already executed");

        p.executed = true;
        bool success = p.yesVotes > p.noVotes;

        emit ProposalExecuted(proposalId, success);
    }
}
