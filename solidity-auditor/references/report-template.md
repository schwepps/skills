# Audit Report Template

Professional smart contract audit report format.

## Report Structure

```markdown
# Smart Contract Security Audit Report
[Project Name]

## Executive Summary

**Project:** [Project Name]
**Auditor:** [Auditor Name/AI Assistant]
**Date:** [Date]
**Commit:** [Commit Hash]
**Scope:** [List of contracts]
**Solidity Version:** [Version]

### Overview
[1-2 paragraph summary of what was audited and key findings]

### Risk Summary
| Severity | Count |
|----------|-------|
| Critical | X |
| High     | X |
| Medium   | X |
| Low      | X |
| Info     | X |

### Key Findings
- [Most critical finding summary]
- [Second most critical finding summary]
- [Other notable findings]

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Scope](#scope)
3. [Methodology](#methodology)
4. [Findings](#findings)
5. [Gas Optimizations](#gas-optimizations)
6. [Recommendations](#recommendations)

---

## Scope

### Contracts in Scope

| Contract | Lines | Description |
|----------|-------|-------------|
| Contract1.sol | XXX | Brief description |
| Contract2.sol | XXX | Brief description |

### Out of Scope
- [List any excluded contracts/files]
- External dependencies (e.g., OpenZeppelin)

### Deployment Information
- **Network:** [Mainnet/Testnet/Multi-chain]
- **Expected TVL:** [If applicable]

---

## Methodology

### Tools Used
- Manual code review
- Static analysis (Slither patterns)
- Logic analysis

### Review Process
1. Code understanding and documentation review
2. Static analysis for common vulnerabilities
3. Manual review following OWASP Smart Contract Top 10
4. Business logic verification
5. Gas optimization analysis

---

## Findings

### [CRITICAL-01] [Finding Title]

**Severity:** Critical
**Status:** [Open/Acknowledged/Fixed]
**File:** `Contract.sol`
**Lines:** XX-YY

#### Description
[Detailed explanation of the vulnerability]

#### Impact
[What could happen if exploited]

#### Proof of Concept
```solidity
// Vulnerable code
function vulnerableFunction() external {
    // problematic code
}
```

Attack scenario:
1. Attacker calls function with malicious input
2. State corruption occurs
3. Funds are drained

#### Recommendation
```solidity
// Fixed code
function fixedFunction() external {
    // corrected code with proper checks
}
```

---

### [HIGH-01] [Finding Title]

**Severity:** High
**Status:** [Open/Acknowledged/Fixed]
**File:** `Contract.sol`
**Lines:** XX-YY

#### Description
[Explanation]

#### Impact
[Impact description]

#### Recommendation
[Fix with code example]

---

### [MEDIUM-01] [Finding Title]

**Severity:** Medium
**Status:** [Open/Acknowledged/Fixed]
**File:** `Contract.sol`
**Lines:** XX-YY

#### Description
[Explanation]

#### Impact
[Impact description]

#### Recommendation
[Fix suggestion]

---

### [LOW-01] [Finding Title]

**Severity:** Low
**Status:** [Open/Acknowledged/Fixed]
**File:** `Contract.sol`
**Lines:** XX-YY

#### Description
[Explanation]

#### Recommendation
[Fix suggestion]

---

### [INFO-01] [Finding Title]

**Severity:** Informational
**File:** `Contract.sol`

#### Description
[Observation or suggestion]

#### Recommendation
[Optional improvement]

---

## Gas Optimizations

### [GAS-01] [Optimization Title]

**File:** `Contract.sol`
**Lines:** XX-YY
**Estimated Savings:** ~XXX gas per call

#### Current Implementation
```solidity
// Current code
```

#### Recommended Implementation
```solidity
// Optimized code
```

---

## Recommendations Summary

### Immediate Actions (Critical/High)
1. [Action item 1]
2. [Action item 2]

### Short-term Improvements (Medium)
1. [Action item 1]
2. [Action item 2]

### Best Practice Improvements (Low/Info)
1. [Action item 1]
2. [Action item 2]

---

## Conclusion

[Summary paragraph about overall security posture and recommendations]

---

## Disclaimer

This audit report is not investment advice. The findings represent the auditor's assessment at the time of review. Smart contracts may contain undiscovered vulnerabilities, and users should exercise their own due diligence.
```

---

## Finding Template (Quick Reference)

```markdown
### [SEVERITY-##] [Descriptive Title]

**Severity:** [Critical/High/Medium/Low/Info]
**Status:** [Open/Acknowledged/Fixed]
**File:** `ContractName.sol`
**Lines:** XX-YY

#### Description
[Clear explanation of the issue]

#### Impact
[Consequences if exploited/unfixed]

#### Proof of Concept (if applicable)
[Attack vector or test case]

#### Recommendation
[Specific fix with code]
```

---

## Severity Examples

### Critical
- Unrestricted minting function
- Missing access control on fund withdrawal
- Reentrancy allowing complete fund drain
- Unprotected upgrade mechanism

### High
- Reentrancy with limited impact
- Price oracle manipulation vector
- Logic error causing partial fund loss
- Access control bypass under conditions

### Medium
- Centralization risks
- Incomplete validation
- DoS vectors
- Front-running vulnerabilities

### Low
- Missing event emissions
- Inconsistent error messages
- Minor gas inefficiencies
- Code style issues

### Informational
- Best practice suggestions
- Documentation improvements
- Test coverage gaps
- Upgrade recommendations
