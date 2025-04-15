// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

/// @title A Counter Contract
/// @author Solidity Examples
/// @notice Demonstrates a simple counter with increment and decrement
/// @dev Shows basic state changes and input validation
contract Counter {
    // State Variables
    int256 private count;
    
    // Events
    event CountChanged(address indexed user, int256 newCount);
    
    // Custom Errors
    error InvalidDecrement();
    
    /// @notice Get the current count
    /// @return The current count value
    function getCount() public view returns (int256) {
        return count;
    }
    
    /// @notice Increment the counter by 1
    function increment() public {
        count += 1;
        emit CountChanged(msg.sender, count);
    }
    
    /// @notice Decrement the counter by 1
    /// @dev Includes check for minimum value
    function decrement() public {
        // Prevent underflow in case of int256.min
        if (count == type(int256).min) {
            revert InvalidDecrement();
        }
        count -= 1;
        emit CountChanged(msg.sender, count);
    }
    
    /// @notice Add a specific value to the counter
    /// @param value The value to add (can be negative)
    function add(int256 value) public {
        count += value;
        emit CountChanged(msg.sender, count);
    }
    
    /// @notice Reset the counter to zero
    function reset() public {
        count = 0;
        emit CountChanged(msg.sender, count);
    }
} 