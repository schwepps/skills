# Code Architecture Review Guide

Best practices for smart contract architecture, design patterns, and code quality.

## Contract Structure

### Recommended Order

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 1. Imports
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// 2. Interfaces
interface ICustom {
    function doSomething() external;
}

// 3. Libraries
library MathLib {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
}

// 4. Contract declaration with inheritance
contract MyContract is ReentrancyGuard {
    // 5. Type declarations
    using MathLib for uint256;
    
    struct UserInfo {
        uint256 balance;
        uint256 lastUpdate;
    }
    
    enum Status { Pending, Active, Completed }
    
    // 6. State variables (order by visibility, then by type)
    // Constants
    uint256 public constant MAX_FEE = 1000;
    
    // Immutables
    address public immutable owner;
    
    // Storage variables
    mapping(address => UserInfo) public users;
    uint256 private _totalSupply;
    
    // 7. Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    
    // 8. Errors (0.8.4+)
    error Unauthorized();
    error InvalidAmount(uint256 provided, uint256 required);
    
    // 9. Modifiers
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }
    
    // 10. Constructor
    constructor() {
        owner = msg.sender;
    }
    
    // 11. Receive/Fallback
    receive() external payable {}
    fallback() external payable {}
    
    // 12. External functions
    function deposit() external payable { }
    
    // 13. Public functions
    function getBalance(address user) public view returns (uint256) { }
    
    // 14. Internal functions
    function _updateBalance(address user, uint256 amount) internal { }
    
    // 15. Private functions
    function _validate() private view { }
}
```

---

## Design Patterns

### Access Control Patterns

**Single Owner (Simple):**
```solidity
address public owner;

modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
}

function transferOwnership(address newOwner) external onlyOwner {
    require(newOwner != address(0), "Invalid address");
    owner = newOwner;
}
```

**Two-Step Ownership Transfer (Safer):**
```solidity
address public owner;
address public pendingOwner;

function transferOwnership(address newOwner) external onlyOwner {
    pendingOwner = newOwner;
}

function acceptOwnership() external {
    require(msg.sender == pendingOwner, "Not pending owner");
    owner = pendingOwner;
    pendingOwner = address(0);
}
```

**Role-Based Access (OpenZeppelin AccessControl):**
```solidity
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract MyContract is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) { }
}
```

### Reentrancy Protection

```solidity
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyContract is ReentrancyGuard {
    function withdraw() external nonReentrant {
        // Safe from reentrancy
    }
}
```

### Pausability

```solidity
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

contract MyContract is Pausable {
    function deposit() external whenNotPaused { }
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
}
```

### Pull Over Push

```solidity
// PUSH (vulnerable to DoS):
function distribute() external {
    for (uint i = 0; i < recipients.length; i++) {
        payable(recipients[i]).transfer(amounts[i]); // Can fail and block all
    }
}

// PULL (safe):
mapping(address => uint256) public pendingWithdrawals;

function claimReward() external {
    uint256 amount = pendingWithdrawals[msg.sender];
    pendingWithdrawals[msg.sender] = 0;
    (bool success,) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

### Checks-Effects-Interactions (CEI)

```solidity
function withdraw(uint256 amount) external {
    // 1. CHECKS
    require(balances[msg.sender] >= amount, "Insufficient balance");
    
    // 2. EFFECTS (state changes)
    balances[msg.sender] -= amount;
    
    // 3. INTERACTIONS (external calls)
    (bool success,) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

---

## Upgradeability Patterns

### UUPS (Recommended)

```solidity
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MyContractV1 is Initializable, UUPSUpgradeable {
    uint256 public value;
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    function initialize(uint256 _value) external initializer {
        value = _value;
    }
    
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
```

### Transparent Proxy

```solidity
// Deployment via OpenZeppelin Hardhat upgrades plugin
// Admin functions handled by separate ProxyAdmin contract
```

### Storage Layout for Upgrades

```solidity
// V1 Storage
contract V1 {
    uint256 public valueA;  // Slot 0
    uint256 public valueB;  // Slot 1
}

// V2 Storage - CORRECT (append only)
contract V2 {
    uint256 public valueA;  // Slot 0 - unchanged
    uint256 public valueB;  // Slot 1 - unchanged
    uint256 public valueC;  // Slot 2 - new variable
}

// V2 Storage - WRONG (reordering breaks storage)
contract V2Wrong {
    uint256 public valueC;  // Slot 0 - COLLISION with valueA!
    uint256 public valueA;  // Slot 1
    uint256 public valueB;  // Slot 2
}
```

---

## Error Handling

### Custom Errors (0.8.4+)

```solidity
// Define at contract level
error Unauthorized(address caller);
error InsufficientBalance(uint256 available, uint256 required);
error InvalidAddress();

// Usage
function withdraw(uint256 amount) external {
    if (msg.sender != owner) revert Unauthorized(msg.sender);
    if (balance < amount) revert InsufficientBalance(balance, amount);
    // ...
}
```

### Try-Catch for External Calls

```solidity
function safeTransfer(address token, address to, uint256 amount) internal returns (bool) {
    try IERC20(token).transfer(to, amount) returns (bool success) {
        return success;
    } catch {
        return false;
    }
}
```

---

## Code Quality Checklist

### Naming Conventions
- [ ] Contracts: PascalCase (`MyContract`)
- [ ] Functions: camelCase (`getBalance`)
- [ ] Variables: camelCase (`totalSupply`)
- [ ] Constants: UPPER_SNAKE_CASE (`MAX_SUPPLY`)
- [ ] Private/internal state: leading underscore (`_totalSupply`)
- [ ] Events: PascalCase past tense (`Transferred`)
- [ ] Errors: PascalCase (`InsufficientBalance`)

### Documentation
- [ ] NatSpec comments on all public/external functions
- [ ] Contract-level documentation
- [ ] Complex logic explained
- [ ] Parameter descriptions

```solidity
/// @notice Deposits tokens into the vault
/// @dev Emits a Deposited event
/// @param amount The amount of tokens to deposit
/// @return shares The number of shares minted
function deposit(uint256 amount) external returns (uint256 shares) {
    // ...
}
```

### Security Practices
- [ ] No floating pragmas in production (`^0.8.0` → `0.8.20`)
- [ ] Latest stable compiler version used
- [ ] OpenZeppelin contracts used for standard functionality
- [ ] Reentrancy guards on external-calling functions
- [ ] Access control on sensitive functions
- [ ] Events emitted for state changes
- [ ] Zero-address checks on initialization
- [ ] Input validation

### Testing Coverage
- [ ] Unit tests for all functions
- [ ] Integration tests for workflows
- [ ] Edge case coverage
- [ ] Fuzz testing for arithmetic
- [ ] Fork tests for mainnet interactions

---

## Architecture Audit Checklist

**Contract Organization:**
- [ ] Logical separation of concerns
- [ ] Appropriate use of libraries
- [ ] Clear inheritance hierarchy
- [ ] Consistent code style

**Access Control:**
- [ ] Roles clearly defined
- [ ] No over-privileged functions
- [ ] Emergency mechanisms appropriate
- [ ] Multi-sig for critical operations

**Upgradeability (if used):**
- [ ] Storage layout documented
- [ ] Initializer protected
- [ ] Implementation cannot be initialized
- [ ] Upgrade authorization appropriate

**Integration:**
- [ ] External dependencies audited
- [ ] Oracle usage appropriate
- [ ] Token standards followed correctly
- [ ] Gas limits considered for loops
