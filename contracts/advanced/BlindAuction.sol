// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.29;

/// @title Blind Auction Contract
/// @author Solidity Examples
/// @notice Implements a blind auction where bids are not visible until reveal
/// @dev Uses commitment scheme to hide bids during bidding period
contract BlindAuction {
    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }
    
    // State variables
    address payable public beneficiary;
    uint256 public biddingEnd;
    uint256 public revealEnd;
    bool public ended;
    
    mapping(address => Bid[]) public bids;
    address public highestBidder;
    uint256 public highestBid;
    
    // Allowed withdrawals of previous bids
    mapping(address => uint256) public pendingReturns;
    
    // Events
    event BidPlaced(address indexed bidder, uint256 deposit);
    event BidRevealed(address indexed bidder, uint256 value, bool success);
    event AuctionEnded(address winner, uint256 highestBid);
    
    // Errors
    error TooEarly(uint256 time);
    error TooLate(uint256 time);
    error AuctionEndAlreadyCalled();
    
    /// @notice Create a new blind auction
    /// @param _biddingTime Duration of bidding period in seconds
    /// @param _revealTime Duration of reveal period in seconds
    /// @param _beneficiary Address to receive auction proceeds
    constructor(
        uint256 _biddingTime,
        uint256 _revealTime,
        address payable _beneficiary
    ) {
        beneficiary = _beneficiary;
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }
    
    /// @notice Place a blinded bid
    /// @param _blindedBid Hashed bid value
    function bid(bytes32 _blindedBid) public payable {
        if (block.timestamp >= biddingEnd) {
            revert TooLate(block.timestamp);
        }
        
        bids[msg.sender].push(Bid({
            blindedBid: _blindedBid,
            deposit: msg.value
        }));
        
        emit BidPlaced(msg.sender, msg.value);
    }
    
    /// @notice Reveal your blinded bids
    /// @param _values Array of bid values
    /// @param _secrets Array of secret values used in bid hashing
    function reveal(
        uint256[] memory _values,
        bytes32[] memory _secrets
    ) public {
        if (block.timestamp <= biddingEnd) {
            revert TooEarly(block.timestamp);
        }
        if (block.timestamp >= revealEnd) {
            revert TooLate(block.timestamp);
        }
        
        uint256 length = bids[msg.sender].length;
        require(_values.length == length, "Invalid array length");
        require(_secrets.length == length, "Invalid array length");
        
        uint256 refund;
        for (uint256 i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];
            (uint256 value, bytes32 secret) = (_values[i], _secrets[i]);
            
            if (bidToCheck.blindedBid == keccak256(abi.encodePacked(value, secret))) {
                refund += bidToCheck.deposit;
                if (value > highestBid && bidToCheck.deposit >= value) {
                    if (highestBidder != address(0)) {
                        // Return funds to previous highest bidder
                        pendingReturns[highestBidder] += highestBid;
                    }
                    highestBid = value;
                    highestBidder = msg.sender;
                }
                emit BidRevealed(msg.sender, value, true);
            } else {
                emit BidRevealed(msg.sender, value, false);
            }
            // Make it impossible to re-claim
            bidToCheck.blindedBid = bytes32(0);
        }
        
        if (refund > 0) {
            pendingReturns[msg.sender] += refund;
        }
    }
    
    /// @notice Withdraw a previously refunded bid
    /// @return success True if the withdrawal was successful
    function withdraw() public returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            
            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }
    
    /// @notice End the auction and send the highest bid to the beneficiary
    function auctionEnd() public {
        if (block.timestamp <= revealEnd) {
            revert TooEarly(block.timestamp);
        }
        if (ended) {
            revert AuctionEndAlreadyCalled();
        }
        
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        
        beneficiary.transfer(highestBid);
    }
    
    /// @notice Helper function to create a blinded bid
    /// @param _value The actual bid value
    /// @param _secret A random value to blind the bid
    /// @return The hashed bid
    function generateBlindedBid(
        uint256 _value,
        bytes32 _secret
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_value, _secret));
    }
} 