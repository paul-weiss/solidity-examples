// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

/// @title Reentrancy Guard Example
/// @author Solidity Examples
/// @notice Demonstrates how to protect against reentrancy attacks
/// @dev Shows implementation of reentrancy guard and secure withdrawal pattern
contract ReentrancyGuard {
    // State variables
    mapping(address => uint256) private balances;
    bool private locked;
    
    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    
    // Custom errors
    error ReentrancyGuardLocked();
    error InsufficientBalance();
    error FailedToSendEther();

    // Modifier that prevents reentrancy
    modifier noReentrant() {
        if (locked) {
            revert ReentrancyGuardLocked();
        }
        locked = true;
        _;
        locked = false;
    }
    
    /// @notice Allows users to deposit ETH
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    
    /// @notice Allows users to check their balance
    /// @return The user's balance
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
    
    /// @notice Withdraws the entire balance for the caller
    /// @dev Protected against reentrancy attacks
    function withdraw() external noReentrant {
        uint256 amount = balances[msg.sender];
        if (amount == 0) {
            revert InsufficientBalance();
        }
        
        // Important: Update state before external call
        // This is the "Checks-Effects-Interactions" pattern
        balances[msg.sender] = 0;
        
        // Send the funds
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) {
            revert FailedToSendEther();
        }
        
        emit Withdrawn(msg.sender, amount);
    }
    
    /// @notice Get the contract's balance
    /// @return The contract's balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // Allow the contract to receive ETH
    receive() external payable {
        deposit();
    }
} 