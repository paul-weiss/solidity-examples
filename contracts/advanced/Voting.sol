// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

/// @title A Voting Contract
/// @author Solidity Examples
/// @notice Implements a voting system with delegation
/// @dev Demonstrates structs, mappings, and complex logic
contract Voting {
    // Struct for a single voter
    struct Voter {
        uint256 weight;        // weight is accumulated by delegation
        bool voted;           // if true, that person already voted
        address delegate;     // person delegated to
        uint256 vote;         // index of the voted proposal
    }

    // Struct for a single proposal
    struct Proposal {
        bytes32 name;        // short name (up to 32 bytes)
        uint256 voteCount;   // number of accumulated votes
    }

    // State variables
    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    
    // Events
    event VoterRegistered(address indexed voter);
    event Voted(address indexed voter, uint256 proposal);
    event Delegated(address indexed from, address indexed to);
    
    // Custom errors
    error UnauthorizedAccess();
    error AlreadyVoted();
    error InvalidProposal();
    error InvalidDelegate();

    /// @notice Create a new ballot to choose one of `proposalNames`
    /// @param proposalNames names of proposals
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        // Create a new proposal for each name
        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    /// @notice Give `voter` the right to vote
    /// @param voter address of voter
    function giveRightToVote(address voter) external {
        if (msg.sender != chairperson) {
            revert UnauthorizedAccess();
        }
        if (voters[voter].voted) {
            revert AlreadyVoted();
        }
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
        emit VoterRegistered(voter);
    }

    /// @notice Delegate your vote to the voter `to`
    /// @param to address to delegate vote to
    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        if (sender.voted) {
            revert AlreadyVoted();
        }
        if (to == msg.sender) {
            revert InvalidDelegate();
        }

        // Forward the delegation as long as `to` also delegated
        while (voters[to].delegate != address(0) && voters[to].delegate != msg.sender) {
            to = voters[to].delegate;
        }

        // Delegation cycle check
        if (to == msg.sender) {
            revert InvalidDelegate();
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight
            delegate_.weight += sender.weight;
        }
        emit Delegated(msg.sender, to);
    }

    /// @notice Give your vote to proposal `proposal`
    /// @param proposal index of proposal in the proposals array
    function vote(uint256 proposal) external {
        Voter storage sender = voters[msg.sender];
        if (sender.voted) {
            revert AlreadyVoted();
        }
        if (proposal >= proposals.length) {
            revert InvalidProposal();
        }
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
        emit Voted(msg.sender, proposal);
    }

    /// @notice Computes the winning proposal
    /// @return winningProposal_ index of winning proposal
    function winningProposal() public view returns (uint256 winningProposal_) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    /// @notice Gets the name of the winning proposal
    /// @return winnerName_ name of the winner
    function winnerName() external view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
} 