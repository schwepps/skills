# Security Vulnerability Checklist

Complete checklist based on OWASP Smart Contract Top 10 (2025) and real-world exploits.

## SC-01: Access Control Vulnerabilities [$953.2M+ in losses]

### Detection Patterns

**Missing Access Control:**
```solidity
// VULNERABLE: No access control on sensitive function
function setPrice(uint256 _price) external {
    price = _price;
}

// SECURE: Proper access control
function setPrice(uint256 _price) external onlyOwner {
    price = _price;
}
```

**Checklist:**
- [ ] All state-changing functions have appropriate access control
- [ ] `onlyOwner`/role modifiers on admin functions
- [ ] `initializer` modifier on initialization functions (upgradeable)
- [ ] No exposed `selfdestruct` or `delegatecall`
- [ ] Constructor properly sets owner/admin
- [ ] Two-step ownership transfer pattern used
- [ ] No `tx.origin` for authorization (use `msg.sender`)

**Common Vulnerabilities:**
- Unprotected `initialize()` functions
- Missing modifiers on mint/burn functions
- Exposed upgrade mechanisms
- Default visibility (pre-0.5.0 was public)

### Recent Exploits
- zkSync (April 2025): Admin key leak in airdrop contract
- Penpie (2024): Unauthorized access in DeFi protocol

---

## SC-02: Logic Errors [$63.8M+ in losses]

### Detection Patterns

**Flawed Business Logic:**
```solidity
// VULNERABLE: Rewards calculated incorrectly
function calculateReward(uint256 amount) public view returns (uint256) {
    return amount * rewardRate; // Missing precision handling
}

// SECURE: Proper precision handling
function calculateReward(uint256 amount) public view returns (uint256) {
    return (amount * rewardRate) / PRECISION;
}
```

**Checklist:**
- [ ] Division before multiplication avoided
- [ ] Precision loss handled correctly
- [ ] Edge cases handled (zero values, max values)
- [ ] State transitions are valid
- [ ] Accounting logic verified (credits = debits)
- [ ] Percentage calculations correct (basis points)
- [ ] Fee calculations don't exceed 100%

**Common Patterns:**
- Rounding errors in favor of attacker
- Missing zero-address checks
- Off-by-one errors in loops
- Incorrect token decimal handling

---

## SC-03: Reentrancy [$35.7M+ in losses]

### Detection Patterns

**Classic Reentrancy:**
```solidity
// VULNERABLE: State updated after external call
function withdraw(uint256 amount) external {
    require(balances[msg.sender] >= amount);
    (bool success,) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] -= amount; // State update AFTER call
}

// SECURE: Checks-Effects-Interactions pattern
function withdraw(uint256 amount) external nonReentrant {
    require(balances[msg.sender] >= amount);
    balances[msg.sender] -= amount; // State update BEFORE call
    (bool success,) = msg.sender.call{value: amount}("");
    require(success);
}
```

**Types of Reentrancy:**
1. **Single-function**: Same function called recursively
2. **Cross-function**: Different functions sharing state
3. **Cross-contract**: Multiple contracts involved
4. **Read-only**: View functions returning stale state during callback

**Checklist:**
- [ ] Checks-Effects-Interactions (CEI) pattern followed
- [ ] `nonReentrant` modifier on state-changing functions
- [ ] State updated before external calls
- [ ] ERC-777 token callback risks assessed
- [ ] Cross-contract reentrancy considered

### Recent Exploits
- Penpie (2024): Reentrancy in DeFi lending
- Minterest (2024): $1.5M flash loan + reentrancy

---

## SC-04: Flash Loan Attack Vectors [$33.8M+ in losses]

### Detection Patterns

**Governance Manipulation:**
```solidity
// VULNERABLE: No flash loan protection in governance
function vote(uint256 proposalId) external {
    uint256 votingPower = token.balanceOf(msg.sender);
    proposals[proposalId].votes += votingPower;
}

// SECURE: Snapshot-based voting
function vote(uint256 proposalId) external {
    uint256 votingPower = token.getPastVotes(msg.sender, proposals[proposalId].snapshotBlock);
    proposals[proposalId].votes += votingPower;
}
```

**Checklist:**
- [ ] Governance uses snapshot voting
- [ ] Price oracles use TWAP, not spot prices
- [ ] Collateral ratios resistant to manipulation
- [ ] Loan/borrow functions check for same-block attacks
- [ ] Time locks on sensitive operations

**Common Attack Patterns:**
- Borrow large amount → manipulate price → profit → repay
- Flash loan → gain voting majority → pass malicious proposal
- Manipulate TWAP oracle with large swaps

### Recent Exploits
- Sonne Finance (May 2024): $20M via flash loan in Compound V2 fork
- Beanstalk (2022): $182M governance attack

---

## SC-05: Input Validation [$14.6M+ in losses]

### Detection Patterns

```solidity
// VULNERABLE: No input validation
function transfer(address to, uint256 amount) external {
    balances[msg.sender] -= amount;
    balances[to] += amount;
}

// SECURE: Proper validation
function transfer(address to, uint256 amount) external {
    require(to != address(0), "Invalid address");
    require(amount > 0, "Amount must be positive");
    require(balances[msg.sender] >= amount, "Insufficient balance");
    balances[msg.sender] -= amount;
    balances[to] += amount;
}
```

**Checklist:**
- [ ] Zero address checks on all address parameters
- [ ] Amount bounds validation
- [ ] Array length limits (DoS prevention)
- [ ] Deadline parameters not expired
- [ ] Slippage parameters reasonable
- [ ] Signature parameters validated
- [ ] Callback data validated

---

## SC-06: Oracle Manipulation [$8.8M+ in losses]

### Detection Patterns

```solidity
// VULNERABLE: Spot price from AMM
function getPrice() public view returns (uint256) {
    return uniswapPair.getReserves()[0] / uniswapPair.getReserves()[1];
}

// SECURE: TWAP or Chainlink
function getPrice() public view returns (uint256) {
    (,int256 price,, uint256 updatedAt,) = chainlinkFeed.latestRoundData();
    require(block.timestamp - updatedAt < MAX_STALENESS, "Stale price");
    require(price > 0, "Invalid price");
    return uint256(price);
}
```

**Checklist:**
- [ ] No spot prices from AMMs
- [ ] TWAP implemented correctly (sufficient window)
- [ ] Price staleness checks
- [ ] Price bounds validation (circuit breakers)
- [ ] Multiple oracle sources considered
- [ ] Fallback oracle mechanism

### Recent Exploits
- Moby (January 2025): Price oracle manipulation via flash loan

---

## SC-07: Unchecked External Calls

### Detection Patterns

```solidity
// VULNERABLE: Unchecked low-level call
function transferETH(address to, uint256 amount) external {
    to.call{value: amount}(""); // Return value ignored
}

// SECURE: Checked return value
function transferETH(address to, uint256 amount) external {
    (bool success,) = to.call{value: amount}("");
    require(success, "Transfer failed");
}
```

**Checklist:**
- [ ] All `.call()` return values checked
- [ ] All `.transfer()` success verified (or use call)
- [ ] External contract calls wrapped in try-catch when appropriate
- [ ] Untrusted contracts handled carefully
- [ ] Return data validated

---

## SC-08: Integer Overflow/Underflow

### Version-Specific

**Pre-0.8.0:** Vulnerable by default
```solidity
// VULNERABLE (pre-0.8.0)
uint256 balance = 100;
balance -= 200; // Underflows to huge number

// SECURE (pre-0.8.0): Use SafeMath
using SafeMath for uint256;
balance = balance.sub(200); // Reverts
```

**0.8.0+:** Protected by default, but watch for:
```solidity
// VULNERABLE: unchecked block bypasses protection
unchecked {
    balance -= amount; // Can underflow!
}
```

**Checklist:**
- [ ] Pre-0.8.0: SafeMath used for all arithmetic
- [ ] 0.8.0+: `unchecked` blocks reviewed carefully
- [ ] Type casting checked (uint256 to uint128, etc.)
- [ ] Multiplication before division (precision)

### Recent Exploits
- Cetus DEX (May 2025): $223M via missing overflow check

---

## SC-09: Denial of Service

### Detection Patterns

**Unbounded Loops:**
```solidity
// VULNERABLE: Unbounded iteration
function distributeRewards() external {
    for (uint i = 0; i < holders.length; i++) { // Can run out of gas
        payable(holders[i]).transfer(rewards);
    }
}

// SECURE: Pull pattern
function claimRewards() external {
    uint256 reward = pendingRewards[msg.sender];
    pendingRewards[msg.sender] = 0;
    payable(msg.sender).transfer(reward);
}
```

**Checklist:**
- [ ] No unbounded loops over dynamic arrays
- [ ] Pull-over-push pattern for payments
- [ ] Gas limits considered for external calls
- [ ] Block gas limit cannot prevent critical operations
- [ ] No dependency on external contract state for critical functions

---

## SC-10: Front-Running / MEV

### Detection Patterns

```solidity
// VULNERABLE: No slippage protection
function swap(uint256 amountIn) external {
    uint256 amountOut = router.swap(amountIn); // Can be sandwiched
}

// SECURE: Slippage protection
function swap(uint256 amountIn, uint256 minAmountOut, uint256 deadline) external {
    require(block.timestamp <= deadline, "Expired");
    uint256 amountOut = router.swap(amountIn);
    require(amountOut >= minAmountOut, "Slippage exceeded");
}
```

**Checklist:**
- [ ] Slippage parameters on swaps (0.1%-5% typical)
- [ ] Deadline parameters to prevent stale transactions
- [ ] Commit-reveal schemes for sensitive operations
- [ ] Private transaction options considered

---

## Additional Security Checks

### Upgradeability (if applicable)
- [ ] Storage layout preserved across upgrades
- [ ] Initializers cannot be called twice
- [ ] Implementation cannot be initialized directly
- [ ] Upgrade access properly controlled
- [ ] No storage collisions with proxy

### Token Security
- [ ] ERC-20: `approve` race condition handled (use increaseAllowance)
- [ ] ERC-721: `safeTransferFrom` callbacks considered
- [ ] ERC-777: Hooks create reentrancy risk
- [ ] Fee-on-transfer tokens handled
- [ ] Rebasing tokens handled
- [ ] Token decimal assumptions verified

### Signature Verification
- [ ] Replay protection (nonce or deadline)
- [ ] Chain ID included in signature
- [ ] Zero address check on ecrecover result
- [ ] EIP-712 structured data used

### Randomness
- [ ] No `block.timestamp` for randomness
- [ ] No `block.difficulty`/`prevrandao` for randomness
- [ ] Chainlink VRF or commit-reveal used
