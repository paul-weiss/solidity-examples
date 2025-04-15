// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

/// @title Withdrawal Pattern
/// @author Solidity Examples
/// @notice Demonstrates the withdrawal pattern for secure payments
/// @dev Shows how to handle payments safely avoiding reentrancy
contract Withdrawal {
    // State variables
    address public owner;
    mapping(address => uint256) public payments;
    uint256 public totalPayments;
    
    // Events
    event PaymentReceived(address indexed from, uint256 amount);
    event PaymentWithdrawn(address indexed to, uint256 amount);
    event EmergencyWithdraw(address indexed owner, uint256 amount);
    
    // Errors
    error InsufficientBalance();
    error WithdrawalFailed();
    error OnlyOwner();
    error ZeroAddress();
    
    /// @notice Contract constructor
    constructor() {
        owner = msg.sender;
    }
    
    /// @notice Modifier to restrict access to owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }
    
    /// @notice Allow users to deposit funds
    /// @dev Funds are tracked in the payments mapping
    function deposit() public payable {
        require(msg.value > 0, "Must send ETH");
        payments[msg.sender] += msg.value;
        totalPayments += msg.value;
        emit PaymentReceived(msg.sender, msg.value);
    }
    
    /// @notice Allow users to withdraw their funds
    /// @param _amount Amount to withdraw
    function withdraw(uint256 _amount) public {
        if (_amount > payments[msg.sender]) {
            revert InsufficientBalance();
        }
        
        // Update state before transfer
        payments[msg.sender] -= _amount;
        totalPayments -= _amount;
        
        // Transfer funds
        (bool success, ) = msg.sender.call{value: _amount}("");
        if (!success) {
            revert WithdrawalFailed();
        }
        
        emit PaymentWithdrawn(msg.sender, _amount);
    }
    
    /// @notice Allow users to check their balance
    /// @return The balance of the caller
    function getBalance() public view returns (uint256) {
        return payments[msg.sender];
    }
    
    /// @notice Transfer ownership of the contract
    /// @param _newOwner Address of the new owner
    function transferOwnership(address _newOwner) public onlyOwner {
        if (_newOwner == address(0)) {
            revert ZeroAddress();
        }
        owner = _newOwner;
    }
    
    /// @notice Emergency withdraw function for owner
    /// @dev Only to be used in emergency situations
    function emergencyWithdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        // Reset all balances
        totalPayments = 0;
        
        // Transfer all funds to owner
        (bool success, ) = owner.call{value: balance}("");
        if (!success) {
            revert WithdrawalFailed();
        }
        
        emit EmergencyWithdraw(owner, balance);
    }
    
    /// @notice Get contract balance
    /// @return The balance of the contract
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    /// @notice Allow contract to receive ETH
    receive() external payable {
        deposit();
    }
    
    /// @notice Fallback function
    fallback() external payable {
        deposit();
    }
} 