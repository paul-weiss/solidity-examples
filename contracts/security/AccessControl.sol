// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

/// @title Role-Based Access Control
/// @author Solidity Examples
/// @notice Implements role-based access control with admin capabilities
/// @dev Demonstrates role management and permission checking
contract AccessControl {
    // Role definitions using bytes32 for gas efficiency
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    
    // Role => Account => HasRole
    mapping(bytes32 => mapping(address => bool)) private roles;
    
    // Role => RoleAdmin
    mapping(bytes32 => bytes32) private roleAdmins;
    
    // Events
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdmin, bytes32 indexed newAdmin);
    
    // Errors
    error MissingRole(bytes32 role, address account);
    error InvalidRole();
    
    /// @notice Contract constructor
    /// @dev Sets up initial admin role
    constructor() {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(MINTER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(BURNER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
    }
    
    /// @notice Modifier to restrict function access to role holders
    /// @param _role The role required to access the function
    modifier onlyRole(bytes32 _role) {
        if (!hasRole(_role, msg.sender)) {
            revert MissingRole(_role, msg.sender);
        }
        _;
    }
    
    /// @notice Check if an account has a specific role
    /// @param _role The role to check
    /// @param _account The account to check
    /// @return True if the account has the role
    function hasRole(bytes32 _role, address _account) public view returns (bool) {
        return roles[_role][_account];
    }
    
    /// @notice Get the admin role for a specific role
    /// @param _role The role to check
    /// @return The admin role
    function getRoleAdmin(bytes32 _role) public view returns (bytes32) {
        return roleAdmins[_role];
    }
    
    /// @notice Grant a role to an account
    /// @param _role The role to grant
    /// @param _account The account to receive the role
    function grantRole(bytes32 _role, address _account) public onlyRole(getRoleAdmin(_role)) {
        _grantRole(_role, _account);
    }
    
    /// @notice Revoke a role from an account
    /// @param _role The role to revoke
    /// @param _account The account to revoke the role from
    function revokeRole(bytes32 _role, address _account) public onlyRole(getRoleAdmin(_role)) {
        _revokeRole(_role, _account);
    }
    
    /// @notice Renounce a role
    /// @param _role The role to give up
    function renounceRole(bytes32 _role) public {
        _revokeRole(_role, msg.sender);
    }
    
    /// @notice Set the admin role for a role
    /// @param _role The role to set admin for
    /// @param _adminRole The new admin role
    function setRoleAdmin(bytes32 _role, bytes32 _adminRole) public onlyRole(ADMIN_ROLE) {
        _setRoleAdmin(_role, _adminRole);
    }
    
    // Internal functions
    
    function _setupRole(bytes32 _role, address _account) internal {
        _grantRole(_role, _account);
    }
    
    function _grantRole(bytes32 _role, address _account) internal {
        if (!hasRole(_role, _account)) {
            roles[_role][_account] = true;
            emit RoleGranted(_role, _account, msg.sender);
        }
    }
    
    function _revokeRole(bytes32 _role, address _account) internal {
        if (hasRole(_role, _account)) {
            roles[_role][_account] = false;
            emit RoleRevoked(_role, _account, msg.sender);
        }
    }
    
    function _setRoleAdmin(bytes32 _role, bytes32 _adminRole) internal {
        bytes32 previousAdmin = getRoleAdmin(_role);
        roleAdmins[_role] = _adminRole;
        emit RoleAdminChanged(_role, previousAdmin, _adminRole);
    }
} 