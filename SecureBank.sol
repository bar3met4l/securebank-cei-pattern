// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; // gives us the nonReentrant modifier

contract SecureBank is ReentrancyGuard {
    // Mapping to store user balances
    mapping(address => uint256) private balances;
    
    // Events for logging deposit and withdrawal actions
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // Custom error messages for better clarity
    error InsufficientBalance();
    error TransferFailed();

    // Deposit function to allow users to deposit Ether into the contract
    function deposit() external payable nonReentrant {
        balances[msg.sender] += msg.value; // Update the user's balance
        emit Deposited(msg.sender, msg.value); // Emit an event for the deposit
    }

    // Withdraw function with re-entrancy protection
    function withdraw(uint256 _amount) external nonReentrant {
        // Check if the user has sufficient balance and if the amount is greater than 0
        if (balances[msg.sender] < _amount || _amount == 0) revert InsufficientBalance();
        
        balances[msg.sender] -= _amount; // Update the user's balance first (Effects)
        
        // Transfer the requested amount to the user (Interaction)
         (bool success, ) = payable(msg.sender).call{value: _amount}(""); 
        if (!success) revert TransferFailed(); // Revert if the transfer fails
                emit Withdrawn(msg.sender, _amount); // Emit an event for the withdrawal
    }

    // View function to check the balance of a user
    function getBalance() external view returns (uint256) {
        return balances[msg.sender]; // Return the user's balance
    }
}