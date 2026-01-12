# Gas Optimization Techniques

Comprehensive guide to reducing gas costs in Solidity smart contracts. Techniques sorted by impact.

## High Impact Optimizations

### 1. Storage vs Memory vs Calldata

Storage is the most expensive operation (~20,000 gas for SSTORE).

```solidity
// EXPENSIVE: Multiple storage reads
function badExample() external {
    for (uint i = 0; i < users.length; i++) {
        total += balances[users[i]]; // Storage read each iteration
    }
}

// OPTIMIZED: Cache in memory
function goodExample() external {
    uint256 _total = total; // Single storage read
    address[] memory _users = users; // Cache array
    for (uint i = 0; i < _users.length; i++) {
        _total += balances[_users[i]];
    }
    total = _total; // Single storage write
}
```

**Guidelines:**
- Cache storage variables in memory/stack for multiple reads
- Use `calldata` for external function array/struct parameters (read-only)
- Use `memory` for internal function parameters
- Minimize storage writes (batch updates)

### 2. Variable Packing

EVM operates on 32-byte slots. Pack smaller types together.

```solidity
// EXPENSIVE: 3 storage slots
contract Bad {
    uint8 a;      // Slot 0 (wastes 31 bytes)
    uint256 b;    // Slot 1
    uint8 c;      // Slot 2 (wastes 31 bytes)
}

// OPTIMIZED: 2 storage slots
contract Good {
    uint8 a;      // Slot 0
    uint8 c;      // Slot 0 (packed with a)
    uint256 b;    // Slot 1
}
```

**Packing Rules:**
- Declare smaller types consecutively
- Structs follow same packing rules
- Mappings/arrays always start new slot
- Pack to fill 32 bytes when possible

### 3. Use Mappings Over Arrays

Mappings are generally cheaper for key-value lookups.

```solidity
// EXPENSIVE: Array iteration O(n)
address[] public whitelist;
function isWhitelisted(address user) public view returns (bool) {
    for (uint i = 0; i < whitelist.length; i++) {
        if (whitelist[i] == user) return true;
    }
    return false;
}

// OPTIMIZED: Mapping O(1)
mapping(address => bool) public whitelist;
function isWhitelisted(address user) public view returns (bool) {
    return whitelist[user];
}
```

**When to use arrays:** When iteration is required or packing small types.

### 4. Short-Circuit Evaluation

Order conditions by failure probability and cost.

```solidity
// EXPENSIVE: Expensive check first
require(expensiveComputation() && simpleCheck, "Failed");

// OPTIMIZED: Cheap check first (short-circuits)
require(simpleCheck && expensiveComputation(), "Failed");
```

### 5. Use Constants and Immutables

```solidity
// EXPENSIVE: Regular storage
uint256 public fee = 100;

// OPTIMIZED: Constant (compile-time, no storage)
uint256 public constant FEE = 100;

// OPTIMIZED: Immutable (set once in constructor, no storage read)
uint256 public immutable deployTime;
constructor() {
    deployTime = block.timestamp;
}
```

---

## Medium Impact Optimizations

### 6. Function Visibility

`external` is cheaper than `public` for external calls.

```solidity
// EXPENSIVE: public copies calldata to memory
function transfer(address to, uint256 amount) public { }

// OPTIMIZED: external reads directly from calldata
function transfer(address to, uint256 amount) external { }
```

**Guideline:** Use `external` unless function is called internally.

### 7. Unchecked Arithmetic (0.8.0+)

When overflow is impossible, skip checks to save ~30-40 gas per operation.

```solidity
// STANDARD: Overflow checks (safe but costly)
for (uint256 i = 0; i < length; i++) { }

// OPTIMIZED: Safe because i < length prevents overflow
for (uint256 i = 0; i < length;) {
    // ... loop body
    unchecked { ++i; }
}
```

**Use unchecked when:**
- Loop counters with known bounds
- Math where overflow is mathematically impossible
- Post-validation arithmetic

**Never use unchecked for:**
- User input arithmetic
- Token balance operations without prior validation

### 8. Custom Errors (0.8.4+)

```solidity
// EXPENSIVE: String error messages
require(balance >= amount, "Insufficient balance");

// OPTIMIZED: Custom errors
error InsufficientBalance(uint256 available, uint256 required);
if (balance < amount) revert InsufficientBalance(balance, amount);
```

Saves ~50 gas per revert and reduces deployment cost.

### 9. Pre-increment vs Post-increment

```solidity
// SLIGHTLY MORE EXPENSIVE
i++;  // Creates temporary copy

// OPTIMIZED
++i;  // Direct increment
```

~5 gas savings per operation. Significant in loops.

### 10. Use bytes32 Over string

```solidity
// EXPENSIVE: Dynamic string
string public name = "MyToken";

// OPTIMIZED: Fixed bytes32
bytes32 public constant NAME = "MyToken";
```

---

## Low Impact but Good Practice

### 11. Optimizer Settings

Enable Solidity optimizer in compiler settings:

```javascript
// hardhat.config.js
solidity: {
  version: "0.8.20",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200  // Optimize for deployment (low) vs runtime (high)
    }
  }
}
```

- Low runs (200): Smaller deployment cost
- High runs (10000): Lower runtime cost

### 12. Event Indexing

Index only fields that need filtering. Each indexed field costs extra.

```solidity
// Over-indexed (wastes gas)
event Transfer(address indexed from, address indexed to, uint256 indexed amount);

// Appropriately indexed
event Transfer(address indexed from, address indexed to, uint256 amount);
```

### 13. Avoid Zero to Non-Zero Storage

First write to storage slot costs 20,000 gas. Subsequent: 5,000.

```solidity
// EXPENSIVE: Zero to non-zero
mapping(address => uint256) balances;
balances[user] = 100; // 20,000 gas first time

// TECHNIQUE: Initialize to 1 if appropriate
// Useful for "exists" flags or counters
```

### 14. Use Bitmaps for Flags

```solidity
// EXPENSIVE: Separate storage slots
mapping(address => bool) public claimed;

// OPTIMIZED: Pack 256 flags per slot
mapping(uint256 => uint256) private claimedBitmap;

function isClaimed(uint256 index) public view returns (bool) {
    uint256 wordIndex = index / 256;
    uint256 bitIndex = index % 256;
    return (claimedBitmap[wordIndex] >> bitIndex) & 1 == 1;
}
```

---

## Gas Cost Reference

| Operation | Gas Cost |
|-----------|----------|
| SSTORE (zero to non-zero) | 20,000 |
| SSTORE (non-zero to non-zero) | 5,000 |
| SSTORE (non-zero to zero) | 5,000 + 15,000 refund |
| SLOAD | 2,100 (cold) / 100 (warm) |
| MLOAD/MSTORE | 3 |
| CALLDATALOAD | 3 |
| Memory expansion | Quadratic |
| External call | 2,600 (cold) + execution |
| LOG0-LOG4 | 375-1,875 + data |

---

## Audit Checklist for Gas

- [ ] Storage variables cached in memory for multiple reads
- [ ] Variables packed efficiently
- [ ] `external` used instead of `public` where appropriate
- [ ] `calldata` used for external function array parameters
- [ ] Constants/immutables used for fixed values
- [ ] `unchecked` blocks used safely for bounded arithmetic
- [ ] Custom errors used (0.8.4+)
- [ ] Optimizer enabled with appropriate runs value
- [ ] No unbounded loops
- [ ] Mappings preferred over arrays for lookups
- [ ] Events appropriately indexed
- [ ] `++i` preferred over `i++`
