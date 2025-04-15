// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

/// @title Token Contract
/// @notice A simple ERC20-like token contract
contract Token {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    address public owner;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _owner
    ) {
        name = _name;
        symbol = _symbol;
        totalSupply = _initialSupply;
        balanceOf[_owner] = _initialSupply;
        owner = _owner;
        emit Transfer(address(0), _owner, _initialSupply);
    }
}

/// @title Token Factory
/// @author Solidity Examples
/// @notice Demonstrates the Factory pattern for creating new token contracts
/// @dev Shows how to create and track child contracts
contract TokenFactory {
    // Event emitted when a new token is created
    event TokenCreated(address indexed tokenAddress, string name, string symbol);
    
    // Array to store all created tokens
    Token[] public tokens;
    
    // Mapping from token address to boolean indicating if it was created by this factory
    mapping(address => bool) public isTokenCreatedHere;
    
    /// @notice Creates a new token contract
    /// @param name The name of the token
    /// @param symbol The symbol of the token
    /// @param initialSupply The initial supply of tokens
    /// @return tokenAddress The address of the newly created token
    function createToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) external returns (address tokenAddress) {
        // Create new token contract
        Token token = new Token(
            name,
            symbol,
            initialSupply,
            msg.sender
        );
        
        // Store token information
        tokens.push(token);
        isTokenCreatedHere[address(token)] = true;
        
        // Emit event
        emit TokenCreated(address(token), name, symbol);
        
        return address(token);
    }
    
    /// @notice Get the number of tokens created by this factory
    /// @return The number of tokens
    function getTokenCount() external view returns (uint256) {
        return tokens.length;
    }
    
    /// @notice Get token information by index
    /// @param index The index of the token in the tokens array
    /// @return tokenAddress The address of the token
    /// @return name The name of the token
    /// @return symbol The symbol of the token
    /// @return totalSupply The total supply of the token
    function getTokenInfo(uint256 index)
        external
        view
        returns (
            address tokenAddress,
            string memory name,
            string memory symbol,
            uint256 totalSupply
        )
    {
        require(index < tokens.length, "Token index out of bounds");
        Token token = tokens[index];
        return (
            address(token),
            token.name(),
            token.symbol(),
            token.totalSupply()
        );
    }
} 