// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

/// @title Events Demonstration Contract
/// @author Solidity Examples
/// @notice Shows different types of events and their usage
/// @dev Demonstrates indexed parameters, anonymous events, and event filtering
contract Events {
    // Events with different parameter combinations
    event BasicEvent(string message);
    event IndexedEvent(address indexed sender, uint256 value);
    event MultipleIndexed(
        address indexed from,
        address indexed to,
        uint256 indexed id,
        uint256 value
    );
    event MixedParams(
        address indexed sender,
        string message,
        uint256 timestamp
    );
    
    // Anonymous event (cannot be filtered by name)
    event anonymous AnonymousEvent(address sender, uint256 value);
    
    // State variables
    uint256 private lastId;
    mapping(uint256 => string) private messages;
    
    /// @notice Emit a basic event with a message
    /// @param message The message to emit
    function emitBasicEvent(string calldata message) public {
        emit BasicEvent(message);
    }
    
    /// @notice Emit an event with an indexed parameter
    /// @param value The value to emit
    function emitIndexedEvent(uint256 value) public {
        emit IndexedEvent(msg.sender, value);
    }
    
    /// @notice Store a message and emit multiple indexed parameters
    /// @param to The recipient address
    /// @param message The message to store
    function sendMessage(address to, string calldata message) public {
        lastId++;
        messages[lastId] = message;
        
        emit MultipleIndexed(
            msg.sender,
            to,
            lastId,
            block.timestamp
        );
        
        emit MixedParams(
            msg.sender,
            message,
            block.timestamp
        );
    }
    
    /// @notice Emit an anonymous event
    /// @param value The value to emit
    function emitAnonymousEvent(uint256 value) public {
        emit AnonymousEvent(msg.sender, value);
    }
    
    /// @notice Get a stored message
    /// @param id The message ID
    /// @return The message content
    function getMessage(uint256 id) public view returns (string memory) {
        return messages[id];
    }
    
    /// @notice Get the last message ID
    /// @return The last message ID
    function getLastId() public view returns (uint256) {
        return lastId;
    }
} 