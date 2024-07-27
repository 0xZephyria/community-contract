// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingTransfer {
    address public predefinedAddress; // The address to receive the funds
    uint256 public voteCount; // Number of unique votes
    uint256 public totalAmount; // Total amount to be transferred
    uint256 public constant requiredVotes = 100000; // Number of required votes
    mapping(address => bool) public hasVoted; // Track if an address has voted

    event Voted(address indexed voter, uint256 amount);
    event Transferred(address indexed recipient, uint256 amount);

    constructor(address _predefinedAddress) {
        predefinedAddress = _predefinedAddress;
    }

    function vote(uint256 amount) external payable {
        require(!hasVoted[msg.sender], "You have already voted");
        require(msg.value == amount, "Sent value must match the vote amount");
        require(voteCount < requiredVotes, "Voting has already ended");

        hasVoted[msg.sender] = true;
        voteCount++;
        totalAmount += amount;

        emit Voted(msg.sender, amount);

        if (voteCount == requiredVotes) {
            transferFunds();
        }
    }

    function transferFunds() internal {
        require(voteCount >= requiredVotes, "Not enough votes");

        (bool success, ) = predefinedAddress.call{value: totalAmount}("");
        require(success, "Transfer failed");

        emit Transferred(predefinedAddress, totalAmount);

        // Reset the state for potential reuse
        voteCount = 0;
        totalAmount = 0;
    }

    // Fallback function to accept Ether directly
    receive() external payable {}
}
