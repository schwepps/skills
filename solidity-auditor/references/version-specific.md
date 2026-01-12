# Solidity Version-Specific Considerations

Security and feature differences across Solidity versions. Critical for auditing legacy and modern contracts.

## Version Overview

| Version Range | Status | Key Security Features |
|--------------|--------|----------------------|
| < 0.5.0 | Legacy | No default visibility, var keyword |
| 0.5.x | Legacy | Explicit visibility required |
| 0.6.x | Legacy | try/catch, immutable introduced |
| 0.7.x | Legacy | Better calldata handling |
| 0.8.0+ | Current | Built-in overflow checks |
| 0.8.4+ | Current | Custom errors |
| 0.8.20+ | Current | Paris/Shanghai EVM features |

---

## Pre-0.8.0: Critical Vulnerabilities

### Integer Overflow/Underflow

**CRITICAL**: Pre-0.8.0 has NO overflow protection.

```solidity
// VULNERABLE (pre-0.8.0)
pragma solidity ^0.7.0;

contract Vulnerable {
    mapping(address => uint256) public balances;
    
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] - amount >= 0); // ALWAYS TRUE for uint!
        balances[msg.sender] -= amount; // Can underflow to MAX_UINT
        payable(msg.sender).transfer(amount);
    }
}
```

**Audit Action**: Verify SafeMath used for ALL arithmetic:

```solidity
// SECURE (pre-0.8.0)
pragma solidity ^0.7.0;
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Secure {
    using SafeMath for uint256;
    mapping(address => uint256) public balances;
    
    function withdraw(uint256 amount) external {
        balances[msg.sender] = balances[msg.sender].sub(amount); // Reverts on underflow
        payable(msg.sender).transfer(amount);
    }
}
```

### Checklist for Pre-0.8.0
- [ ] SafeMath used for ALL uint operations
- [ ] SignedSafeMath used for int operations
- [ ] No direct +, -, *, / on integers without SafeMath
- [ ] Type casting checked manually

---

## Pre-0.5.0: Legacy Vulnerabilities

### Default Visibility

**CRITICAL**: Functions defaulted to `public` before 0.5.0.

```solidity
// VULNERABLE (pre-0.5.0)
pragma solidity ^0.4.24;

contract Vulnerable {
    function internalLogic() { // DEFAULT PUBLIC - anyone can call!
        // sensitive operation
    }
}
```

**Audit Action**: Check ALL function visibility declarations.

### var Keyword

```solidity
// VULNERABLE: var infers type
var i = 0; // Inferred as uint8, overflows at 255!
for (var i = 0; i < array.length; i++) { // Can infinite loop
```

### Checklist for Pre-0.5.0
- [ ] All functions have explicit visibility
- [ ] No `var` keyword used
- [ ] Constructor uses `constructor()` not function name

---

## 0.8.0 Breaking Changes

### Arithmetic Overflow Protection

Default behavior change - arithmetic reverts on overflow.

```solidity
// 0.8.0+ behavior
uint8 x = 255;
x += 1; // REVERTS with Panic(0x11)

// To bypass (use carefully!)
unchecked {
    x += 1; // Wraps to 0
}
```

**Audit `unchecked` blocks carefully:**
- [ ] Mathematical proof of no overflow
- [ ] Bounded loop counters only
- [ ] No user-controlled values

### Type Changes

```solidity
// Pre-0.8.0
address(this).balance; // OK
msg.sender.transfer(amount); // OK

// 0.8.0+
address(this).balance; // OK
msg.sender.transfer(amount); // ERROR: msg.sender is address, not address payable
payable(msg.sender).transfer(amount); // OK
```

### ABI Coder v2 Default

```solidity
// Pre-0.8.0: ABI coder v1 default
// 0.8.0+: ABI coder v2 default

// Affects:
// - Nested arrays
// - Structs in function signatures
// - Dynamic types in external functions
```

### Error Handling

```solidity
// Pre-0.8.0: assert() uses invalid opcode (consumes all gas)
// 0.8.0+: assert() uses revert (returns remaining gas)

// Panic codes:
// 0x01: assert(false)
// 0x11: arithmetic overflow/underflow
// 0x12: division by zero
// 0x21: invalid enum conversion
// 0x22: storage array out of bounds
// 0x31: pop() on empty array
// 0x32: array index out of bounds
// 0x41: memory allocation failure
// 0x51: internal function pointer error
```

---

## 0.8.4+: Custom Errors

```solidity
// Old style (expensive)
require(balance >= amount, "Insufficient balance");

// New style (cheaper)
error InsufficientBalance(uint256 available, uint256 required);

function withdraw(uint256 amount) external {
    if (balance < amount) {
        revert InsufficientBalance(balance, amount);
    }
    // ...
}
```

**Audit Action**: Recommend upgrade for gas savings (~50 gas per revert).

---

## 0.8.18+: Shanghai/Paris Features

### PUSH0 Opcode (0.8.20+)

New opcode for pushing zero to stack. Enables gas savings.

**Note**: May not work on all chains (check L2 compatibility).

```solidity
// Compiler setting for backwards compatibility
settings: {
    evmVersion: "paris" // or "london" for older chains
}
```

### Block.prevrandao (0.8.18+)

```solidity
// Deprecated (returns prevrandao post-merge)
block.difficulty

// New (post-merge)
block.prevrandao
```

**NEITHER is suitable for secure randomness** - use Chainlink VRF.

---

## 0.8.24+: Cancun Features

### Transient Storage (EIP-1153)

```solidity
// New opcodes: TSTORE, TLOAD
// Storage that clears after transaction

assembly {
    tstore(0, 1) // Transient store
    let val := tload(0) // Transient load
}
```

**Use cases**: Reentrancy locks, callback context.

---

## Version Migration Checklist

### Migrating from Pre-0.8.0 to 0.8.0+

- [ ] Remove SafeMath imports and usage
- [ ] Convert `address` to `address payable` where needed
- [ ] Update constructor syntax if needed
- [ ] Review all arithmetic for intended behavior
- [ ] Add `unchecked` blocks only where proven safe
- [ ] Test all arithmetic edge cases
- [ ] Verify ABI compatibility with integrations

### Migrating from 0.8.x to Latest

- [ ] Enable custom errors for gas savings
- [ ] Update `block.difficulty` to `block.prevrandao`
- [ ] Consider EVM version for deployment chain
- [ ] Review optimizer settings
- [ ] Check L2 opcode compatibility

---

## Chain-Specific Considerations

| Chain | Recommended EVM | Notes |
|-------|-----------------|-------|
| Ethereum Mainnet | prague (0.8.30+) | Full feature support |
| Arbitrum | cancun | Check blob support |
| Optimism | cancun | Check blob support |
| Base | cancun | Check blob support |
| Polygon | paris | Some newer features limited |
| BSC | paris | Conservative version |

---

## Audit Summary by Version

**Pre-0.5.0 Audit Focus:**
1. Function visibility (critical)
2. Constructor naming
3. SafeMath usage
4. var keyword absence

**0.5.x - 0.7.x Audit Focus:**
1. SafeMath on all arithmetic
2. Proper type casting
3. ABI coder considerations

**0.8.0+ Audit Focus:**
1. `unchecked` block safety
2. Custom error usage (0.8.4+)
3. Address payable conversions
4. EVM version compatibility

**Latest (0.8.20+) Audit Focus:**
1. Chain compatibility
2. New opcode usage
3. Transient storage (if used)
4. Optimizer settings
