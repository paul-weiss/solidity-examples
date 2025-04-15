// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

/// @title Safe Remote Purchase
/// @author Solidity Examples
/// @notice Implements a safe way to purchase goods remotely
/// @dev Uses value locking to ensure both parties act honestly
contract SafeRemotePurchase {
    uint256 public value;
    address payable public seller;
    address payable public buyer;
    
    enum State { Created, Locked, Release, Inactive }
    State public state;
    
    // Events
    event PurchaseConfirmed(address buyer);
    event ItemReceived();
    event SellerRefunded();
    
    // Errors
    error InvalidState();
    error InvalidValue();
    error OnlyBuyer();
    error OnlySeller();
    
    modifier condition(bool _condition) {
        require(_condition);
        _;
    }
    
    modifier onlyBuyer() {
        if (msg.sender != buyer) {
            revert OnlyBuyer();
        }
        _;
    }
    
    modifier onlySeller() {
        if (msg.sender != seller) {
            revert OnlySeller();
        }
        _;
    }
    
    modifier inState(State _state) {
        if (state != _state) {
            revert InvalidState();
        }
        _;
    }
    
    /// @notice Create a new purchase contract
    /// @dev Value is set to twice the deposit to ensure both parties commit
    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
        if (value == 0) {
            revert InvalidValue();
        }
        state = State.Created;
    }
    
    /// @notice Get the contract balance
    /// @return The current balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    /// @notice Confirm the purchase as buyer
    /// @dev Requires payment of twice the item value
    function confirmPurchase()
        public
        payable
        inState(State.Created)
        condition(msg.value == (2 * value))
    {
        buyer = payable(msg.sender);
        state = State.Locked;
        emit PurchaseConfirmed(msg.sender);
    }
    
    /// @notice Confirm item received and release funds to seller
    /// @dev Can only be called by the buyer
    function confirmReceived()
        public
        onlyBuyer
        inState(State.Locked)
    {
        state = State.Release;
        buyer.transfer(value); // Return deposit to buyer
        emit ItemReceived();
    }
    
    /// @notice Refund the seller
    /// @dev Can only be called by the seller
    function refundSeller()
        public
        onlySeller
        inState(State.Release)
    {
        state = State.Inactive;
        seller.transfer(3 * value); // Transfer payment and seller's deposit
        emit SellerRefunded();
    }
    
    /// @notice Abort the purchase
    /// @dev Can only be called by the seller before purchase is confirmed
    function abort()
        public
        onlySeller
        inState(State.Created)
    {
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }
} 