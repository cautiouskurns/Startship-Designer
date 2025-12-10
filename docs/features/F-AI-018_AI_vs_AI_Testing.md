# F-AI-018: AI vs AI Testing

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 2 days
**Dependencies:** All Phase 1-3 features
**Phase:** 5 - Polish & Balance

---

## Purpose

**Why does this feature exist?**
Validates that AI systems work correctly across diverse matchups without human player involvement. Identifies edge cases, bugs, and unexpected behaviors before player testing.

**What does it enable?**
Automated test suite runs hundreds of AI vs AI battles, detecting crashes, infinite loops, dominant strategies, and logical errors. Catches issues early.

**Success criteria:**
- Test suite runs 500+ battles without crashes
- AI makes legal moves 100% of the time
- Combat completes within reasonable turn count (avg 10-15 turns, max 30)
- No doctrine achieves >70% win rate (balance check)

---

## How It Works

### Overview

Automated test harness that:
1. Generates diverse ship builds (archetypes, synergies, sizes)
2. Pairs ships in various matchups (doctrine vs doctrine)
3. Runs full combat simulations headless (no GUI)
4. Logs results, errors, and anomalies
5. Generates test report

**Test Categories:**

**1. Smoke Tests (50 battles)**
- Basic functionality: AI makes decisions, combat completes
- Detects crashes, infinite loops, null reference errors

**2. Matchup Tests (360 battles)**
- Every doctrine vs every doctrine (6x6 = 36 matchups)
- 10 battles per matchup
- Validates balance, detects outliers

**3. Edge Case Tests (90 battles)**
- Extreme builds (all weapons, all shields, all reactors)
- Damaged ships entering combat
- Power crises, synergy breaks mid-combat

---

## Test Execution

**Test Runner Script:**
```gdscript
class AITestRunner:
    func run_full_test_suite():
        print("Starting AI vs AI test suite...")
        var results = {
            "smoke_tests": run_smoke_tests(),
            "matchup_tests": run_matchup_tests(),
            "edge_case_tests": run_edge_case_tests()
        }
        generate_report(results)
        return results

    func run_smoke_tests():
        # 50 random battles, check for crashes
        pass

    func run_matchup_tests():
        # 360 doctrine matchup battles
        pass

    func run_edge_case_tests():
        # 90 extreme scenario battles
        pass
```

**Execution**: Run via command line:
```bash
godot --headless --script res://tests/AITestRunner.gd
```

---

## Validation Criteria

**Pass Conditions:**
- [ ] All battles complete without crashes
- [ ] Average combat length 10-15 turns
- [ ] Max combat length <30 turns (no infinite loops)
- [ ] AI makes legal targeting decisions 100% of time
- [ ] No doctrine >70% or <20% overall win rate

**Failure Conditions:**
- Crash/hang during any battle → Critical bug
- Illegal move (target destroyed room, target Bridge mid-game) → Logic error
- Combat exceeds 30 turns → Stalemate detection needed
- Doctrine outlier (>70% win rate) → Balance issue

---

## Deliverables

**Test Report** (tests/AI_Test_Report.txt):
- Total battles run: 500
- Crashes: 0
- Avg combat length: 12.3 turns
- Max combat length: 24 turns
- Doctrine win rates: [matrix]
- Edge case results: [pass/fail per scenario]

---

## Acceptance Criteria

- [ ] Test suite executes 500+ battles successfully
- [ ] Zero crashes or hangs
- [ ] Avg combat length within 10-15 turns
- [ ] All doctrines within 20-70% win rate range
- [ ] Edge cases handled gracefully (no errors)

---

## Implementation Notes

**Performance**: Headless mode + no delays → 10-20 battles/second.
**Automation**: Runs in CI/CD pipeline or locally before releases.

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
