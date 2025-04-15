// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

/// @title Proxy Pattern Implementation
/// @author Solidity Examples
/// @notice Demonstrates upgradeable contract pattern
/// @dev Shows implementation of transparent proxy pattern
contract Proxy {
    // Storage position of the address of the current implementation
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(
        keccak256("eip1967.proxy.implementation")) - 1
    );
    
    // Storage position of the admin
    bytes32 private constant ADMIN_SLOT = bytes32(uint256(
        keccak256("eip1967.proxy.admin")) - 1
    );
    
    // Events
    event Upgraded(address indexed implementation);
    event AdminChanged(address previousAdmin, address newAdmin);
    
    // Errors
    error NotAdmin();
    error InvalidImplementation();
    error SetupFailed();
    
    /// @notice Contract constructor
    /// @param _implementation Address of the initial implementation
    /// @param _admin Address of the proxy admin
    constructor(address _implementation, address _admin) {
        _setImplementation(_implementation);
        _setAdmin(_admin);
    }
    
    /// @notice Modifier to restrict access to admin
    modifier onlyAdmin() {
        if (msg.sender != _getAdmin()) {
            revert NotAdmin();
        }
        _;
    }
    
    /// @notice Upgrade to a new implementation
    /// @param _newImplementation Address of the new implementation
    function upgradeTo(address _newImplementation) external onlyAdmin {
        _setImplementation(_newImplementation);
    }
    
    /// @notice Change the admin of the proxy
    /// @param _newAdmin Address of the new admin
    function changeAdmin(address _newAdmin) external onlyAdmin {
        _setAdmin(_newAdmin);
    }
    
    /// @notice Get the current implementation address
    /// @return The implementation address
    function implementation() external view returns (address) {
        return _getImplementation();
    }
    
    /// @notice Get the admin address
    /// @return The admin address
    function admin() external view returns (address) {
        return _getAdmin();
    }
    
    // Internal functions
    
    function _setImplementation(address _newImplementation) private {
        if (_newImplementation == address(0)) {
            revert InvalidImplementation();
        }
        
        // We need to make sure the implementation is a contract
        if (_newImplementation.code.length == 0) {
            revert InvalidImplementation();
        }
        
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _newImplementation)
        }
        
        emit Upgraded(_newImplementation);
    }
    
    function _getImplementation() private view returns (address implementation_) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            implementation_ := sload(slot)
        }
    }
    
    function _setAdmin(address _newAdmin) private {
        address previousAdmin = _getAdmin();
        bytes32 slot = ADMIN_SLOT;
        assembly {
            sstore(slot, _newAdmin)
        }
        emit AdminChanged(previousAdmin, _newAdmin);
    }
    
    function _getAdmin() private view returns (address admin_) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            admin_ := sload(slot)
        }
    }
    
    /// @notice Fallback function to delegate calls to implementation
    fallback() external payable virtual {
        _delegate(_getImplementation());
    }
    
    /// @notice Receive function to accept ETH
    receive() external payable virtual {
        _delegate(_getImplementation());
    }
    
    /// @notice Delegate call to implementation
    /// @param _implementation Address of the implementation to delegate to
    function _delegate(address _implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())
            
            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)
            
            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())
            
            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}

/// @title Implementation Contract Interface
/// @notice Interface for implementation contracts
interface IImplementation {
    function initialize() external;
}

/// @title Example Implementation V1
/// @notice Example of an implementation contract
contract ImplementationV1 {
    uint256 private value;
    bool private initialized;
    
    event ValueChanged(uint256 newValue);
    
    modifier initializer() {
        require(!initialized, "Already initialized");
        _;
        initialized = true;
    }
    
    function initialize() external initializer {
        value = 42;
    }
    
    function getValue() external view returns (uint256) {
        return value;
    }
    
    function setValue(uint256 _value) external {
        value = _value;
        emit ValueChanged(_value);
    }
} 