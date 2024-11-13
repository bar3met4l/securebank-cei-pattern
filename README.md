**Title: SecureBank: Implementing the Checks-Effects-Interactions Pattern for Ether Deposit and Withdrawal**

**Introduction**

This report presents a secure Ether deposit and withdrawal contract that prevents re-entrancy attacks using the Checks-Effects-Interactions (CEI) pattern. This approach ensures the contract's security while maintaining straightforward functionality for users.

**Smart Contract Implementation**

```solidity
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
```

**Explanation of Design Choices to Prevent Re-Entrancy**

The contract prevents re-entrancy attacks using the **Checks-Effects-Interactions (CEI)** pattern and the **nonReentrant** modifier from OpenZeppelin:

1. **Checks-Effects-Interactions Pattern**:

   - Update the user's balance before transferring Ether to prevent repeated calls.
   - This ensures any re-entrant call will fail due to insufficient balance.

2. **nonReentrant Modifier**:

   - The `nonReentrant` modifier blocks re-entrant calls during the execution of the `deposit` and `withdraw` functions, adding an extra layer of protection.

**Advantages of CEI Pattern**

- **Simplicity**: Fewer lines of code and fewer potential bugs compared to explicit locking mechanisms.
- **Gas Efficiency**: No additional storage operations, making the contract cheaper to use.
- **Logical Flow**: Easy to follow, improving code readability and maintainability.

**Implementation Best Practices**

- **Update state before external calls**: Ensures no external contract can exploit an inconsistent state.
- **Descriptive error messages**: Custom errors like `InsufficientBalance()` improve clarity.
- **Event logging**: Events (`Deposited` and `Withdrawn`) provide transparency.
- **Keep functions simple**: Ensures easy verification and understanding.

**Conclusion**

The Checks-Effects-Interactions pattern, combined with the `nonReentrant` modifier, effectively prevents re-entrancy attacks. Updating state variables before external interactions ensures consistent contract behavior, while the `nonReentrant` modifier provides an additional security layer. This approach offers a secure and efficient Ether management solution, aligning with best practices for smart contract security. Further enhancements, such as advanced access control and rate limiting, can improve the contract's versatility.

**References**

- Ethereum Smart Contract Best Practices Guide
- "Making Smart Contracts Smarter" - Research Paper on Re-entrancy
- Solidity Documentation on Security Considerations
- OpenZeppelin Documentation

