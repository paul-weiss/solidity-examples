// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

/// @title A Simple Storage Contract
/// @author Solidity Examples
/// @notice Demonstrates basic storage and retrieval in Solidity
/// @dev A basic example showing state variables, functions, and events
contract SimpleStorage {
    // State Variables
    uint256 private storedData;
    address public owner;
    
    // Events
    event DataStored(address indexed storer, uint256 newValue);
    event DataRetrieved(address indexed retriever, uint256 value);
    
    // Custom Errors
    error UnauthorizedAccess(address caller);
    
    // Constructor
    constructor() {
        owner = msg.sender;
    }
    
    // Modifier for owner-only functions
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert UnauthorizedAccess(msg.sender);
        }
        _;
    }
    
    /// @notice Store a new value in the contract
    /// @param x Value to store
    /// @dev Emits DataStored event
    function store(uint256 x) public {
        storedData = x;
        emit DataStored(msg.sender, x);
    }
    
    /// @notice Retrieve the stored value
    /// @return The value stored
    /// @dev Emits DataRetrieved event
    function retrieve() public returns (uint256) {
        emit DataRetrieved(msg.sender, storedData);
        return storedData;
    }
    
    /// @notice Clear the stored data
    /// @dev Can only be called by the owner
    function clear() public onlyOwner {
        storedData = 0;
        emit DataStored(msg.sender, 0);
    }
} 