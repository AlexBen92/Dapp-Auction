// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title Auction
 * @dev A decentralized auction contract allowing users to place bids on an item.
 */
contract Auction {
    address public owner;
    address public highestBidder;
    uint public highestBid;
    uint public auctionEndTime;
    bool ended;

    /// Mapping to track pending returns for users who were outbid.
    mapping(address => uint) pendingReturns;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint _biddingTime) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    /**
     * @notice Place a bid on the auction item.
     * @dev Refunds previous highest bidder if a higher bid is placed.
     */
    function bid() external payable {
        require(block.timestamp <= auctionEndTime, "Auction already ended.");
        require(msg.value > highestBid, "There already is a higher bid.");

        if (highestBid != 0) {
            // Refund previous highest bid.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /**
     * @notice Withdraws a bid that was outbid.
     */
    function withdraw() external {
        uint amount = pendingReturns[msg.sender];
        require(amount > 0, "No funds to withdraw.");
        pendingReturns[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    /**
     * @notice Ends the auction and transfers the highest bid to the owner.
     */
    function endAuction() external {
        require(msg.sender == owner, "Only the owner can end the auction.");
        require(block.timestamp >= auctionEndTime, "Auction not yet ended.");
        require(!ended, "Auction end already called.");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        payable(owner).transfer(highestBid);
    }
}

