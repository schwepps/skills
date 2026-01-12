# Storage Optimization Patterns

Guide to efficient storage layout and patterns in Solidity smart contracts.

## EVM Storage Model

- Storage organized in 32-byte (256-bit) slots
- Each slot costs 20,000 gas to initialize
- Slots are addressed by uint256 keys (0, 1, 2, ...)
- Variables packed left-to-right within slots

## Slot Layout Rules

### Basic Types

| Type | Size | Slot Behavior |
|------|------|---------------|
| uint256/int256 | 32 bytes | Full slot |
| uint128/int128 | 16 bytes | Packable |
| uint64/int64 | 8 bytes | Packable |
| uint32/int32 | 4 bytes | Packable |
| uint8/int8 | 1 byte | Packable |
| bool | 1 byte | Packable |
| address | 20 bytes | Packable |
| bytes1-bytes32 | 1-32 bytes | Packable |
| bytes/string | 32 bytes* | Dynamic |
| mapping | 32 bytes | Empty slot, data at hash |
| array (dynamic) | 32 bytes | Length at slot, data at hash |
| array (fixed) | N * element | Consecutive slots |

### Packing Examples

```solidity
// INEFFICIENT: 4 slots used
contract BadLayout {
    uint8 a;        // Slot 0 (1 byte, 31 wasted)
    uint256 b;      // Slot 1 (full slot)
    uint8 c;        // Slot 2 (1 byte, 31 wasted)
    address d;      // Slot 3 (20 bytes, 12 wasted)
}

// OPTIMIZED: 2 slots used
contract GoodLayout {
    uint8 a;        // Slot 0 (1 byte)
    uint8 c;        // Slot 0 (1 byte, packed)
    address d;      // Slot 0 (20 bytes, packed - total 22/32)
    uint256 b;      // Slot 1 (full slot)
}
```

### Struct Packing

```solidity
// INEFFICIENT: 3 slots
struct BadStruct {
    uint64 timestamp;   // Slot 0
    address user;       // Slot 1 (starts new slot)
    uint128 amount;     // Slot 2
}

// OPTIMIZED: 2 slots
struct GoodStruct {
    address user;       // Slot 0 (20 bytes)
    uint64 timestamp;   // Slot 0 (8 bytes, packed - 28 total)
    uint128 amount;     // Slot 1 (16 bytes)
}
```

---

## Storage Patterns

### Pattern 1: Mapping + Struct

Common pattern for user data:

```solidity
struct UserInfo {
    uint128 balance;      // 16 bytes
    uint64 lastUpdate;    // 8 bytes
    uint64 nonce;         // 8 bytes = 32 bytes total (1 slot)
}

mapping(address => UserInfo) public users;
```

### Pattern 2: Bitmap for Flags

Store 256 boolean flags in one slot:

```solidity
uint256 private flags;

function setFlag(uint8 index) external {
    flags |= (1 << index);
}

function getFlag(uint8 index) external view returns (bool) {
    return (flags >> index) & 1 == 1;
}

function clearFlag(uint8 index) external {
    flags &= ~(1 << index);
}
```

### Pattern 3: Packed Timestamps + Amounts

```solidity
// Pack timestamp (40 bits = ~34,000 years) + amount (216 bits)
struct PackedData {
    uint40 timestamp;
    uint216 amount;
}
// Fits in single slot
```

### Pattern 4: EnumerableSet Alternative

Instead of OpenZeppelin's EnumerableSet (expensive), consider:

```solidity
// Cheaper: Mapping + Array with index tracking
mapping(address => uint256) private _index;
address[] private _values;

function add(address value) internal returns (bool) {
    if (_index[value] != 0) return false;
    _values.push(value);
    _index[value] = _values.length; // 1-indexed
    return true;
}

function remove(address value) internal returns (bool) {
    uint256 valueIndex = _index[value];
    if (valueIndex == 0) return false;
    
    uint256 lastIndex = _values.length;
    if (valueIndex != lastIndex) {
        address lastValue = _values[lastIndex - 1];
        _values[valueIndex - 1] = lastValue;
        _index[lastValue] = valueIndex;
    }
    _values.pop();
    delete _index[value];
    return true;
}
```

---

## Dynamic Storage

### Mappings

```solidity
mapping(KeyType => ValueType) map;
// Slot of map = p
// Value location = keccak256(key . p)
```

Key points:
- Mapping slot itself stores nothing
- Values stored at `keccak256(key, slot)`
- Cannot iterate mappings
- Cannot get length of mappings

### Dynamic Arrays

```solidity
uint256[] arr;
// Slot p stores length
// Element i at keccak256(p) + i
```

### Nested Mappings

```solidity
mapping(address => mapping(uint256 => uint256)) nested;
// Value at keccak256(innerKey, keccak256(outerKey, slot))
```

---

## Storage Collision Prevention (Upgradeable Contracts)

### Diamond Storage Pattern

```solidity
library DiamondStorage {
    bytes32 constant STORAGE_POSITION = keccak256("diamond.storage.mycontract");
    
    struct Data {
        uint256 value;
        mapping(address => uint256) balances;
    }
    
    function data() internal pure returns (Data storage d) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            d.slot := position
        }
    }
}

contract MyContract {
    function getValue() external view returns (uint256) {
        return DiamondStorage.data().value;
    }
}
```

### ERC-7201: Namespaced Storage

```solidity
// @custom:storage-location erc7201:example.main
struct MainStorage {
    uint256 value;
    mapping(address => uint256) balances;
}

// keccak256(abi.encode(uint256(keccak256("example.main")) - 1)) & ~bytes32(uint256(0xff))
bytes32 private constant MAIN_STORAGE_LOCATION = 
    0x183a6125c38840424c4a85fa12bab2ab606c4b6d0e7cc73c0c06ba5300eab500;

function _getMainStorage() private pure returns (MainStorage storage $) {
    assembly {
        $.slot := MAIN_STORAGE_LOCATION
    }
}
```

---

## Storage Anti-Patterns

### Anti-Pattern 1: Unnecessary State Variables

```solidity
// BAD: Stored but computable
uint256 public totalValue;
uint256[] public values;
// totalValue always equals sum(values)

// GOOD: Compute on demand
function getTotalValue() public view returns (uint256 total) {
    for (uint i = 0; i < values.length; i++) {
        total += values[i];
    }
}
// Or maintain running total only when gas is critical
```

### Anti-Pattern 2: String Storage

```solidity
// BAD: Dynamic string storage (expensive)
string public name = "My Long Token Name";

// GOOD: bytes32 or constant
bytes32 public constant NAME = "My Long Token Name";

// Or if truly dynamic, consider events for logging only
```

### Anti-Pattern 3: Redundant Data

```solidity
// BAD: Storing derivable data
mapping(address => uint256) public deposits;
mapping(address => uint256) public withdrawals;
mapping(address => uint256) public balance; // Redundant!

// GOOD: Compute balance
function getBalance(address user) public view returns (uint256) {
    return deposits[user] - withdrawals[user];
}
```

---

## Audit Checklist for Storage

- [ ] Variables ordered for optimal packing
- [ ] Structs packed efficiently
- [ ] No wasted bytes between variables
- [ ] Mappings used for O(1) lookups
- [ ] Bitmaps used for multiple boolean flags
- [ ] Constants used for fixed values
- [ ] Dynamic strings minimized
- [ ] No redundant stored data
- [ ] Upgradeable contracts use namespaced storage
- [ ] Storage layout documented for upgrades
- [ ] Array lengths bounded or iterations limited
- [ ] Delete unused storage for gas refunds
