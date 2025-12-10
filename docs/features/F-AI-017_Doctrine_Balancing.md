# F-AI-017: Doctrine Balancing

**Status:** 🔴 Planned
**Priority:** 🔥 Critical
**Estimated Time:** 3 days
**Dependencies:** All Phase 1-3 features
**Phase:** 5 - Polish & Balance

---

## Purpose

**Why does this feature exist?**
Unbalanced doctrines create dominant strategies and stale meta. Balancing ensures all doctrines are viable and create diverse, interesting matchups.

**What does it enable?**
No single doctrine dominates (win rates 30-50% vs others). Each doctrine has clear strengths, weaknesses, and counters. Rock-paper-scissors dynamics create strategic depth.

**Success criteria:**
- All doctrines have 30-50% win rate vs each other (no outliers)
- Each doctrine has ≥1 favorable and ≥1 unfavorable matchup
- Doctrine performance consistent across ship sizes (8x6, 6x5, 4x4)
- Balance achieved through tuning constants, not code rewrites

---

## How It Works

### Overview

Systematic testing and tuning process:

**Phase 1: Data Collection (1 day)**
- Run 100+ AI vs AI battles for each doctrine matchup (6x6 = 36 matchups)
- Track win rates, average damage, turns to victory
- Identify statistical outliers (doctrines with >60% or <30% win rate)

**Phase 2: Analysis (1 day)**
- Identify over/underpowered doctrines
- Analyze why imbalances exist (weights, aggression, traits)
- Propose balance changes (adjust tuning constants in BalanceConstants.gd)

**Phase 3: Iteration (1 day)**
- Implement balance changes
- Re-run test suite (100+ battles)
- Validate changes brought outliers into 30-50% range
- Repeat if needed (max 3 iterations)

**Tunable Levers:**
1. Target priority weights (weapon=1.0 → 0.9)
2. Aggression levels (0.8 → 0.75)
3. Trait modifier values (+20 → +15)
4. State modifier thresholds (70% → 65%)
5. Overkill thresholds (30% → 35%)

---

## Balancing Goals

**Win Rate Targets:**
- Alpha Strike vs Defensive Turtle: 45-55% (slight Turtle advantage)
- Berserker Rush vs War of Attrition: 40-60% (Attrition advantage)
- Surgical Strike vs Adaptive Response: 48-52% (even)

**No Dominant Doctrine:**
- No doctrine should exceed 55% win rate vs ALL others
- No doctrine should fall below 35% win rate vs ALL others

**Matchup Variety:**
- Each doctrine should have at least 1 favorable (>55%) matchup
- Each doctrine should have at least 1 unfavorable (<45%) matchup
- Promotes counter-picking and strategic diversity

---

## Testing Methodology

**Automated Battle Simulator:**
```gdscript
func run_doctrine_matchup_test(doctrine_a, doctrine_b, iterations=100):
    var results = {"a_wins": 0, "b_wins": 0}
    for i in range(iterations):
        var ship_a = generate_archetype_ship(doctrine_a.archetype)
        var ship_b = generate_archetype_ship(doctrine_b.archetype)
        var winner = simulate_battle(ship_a, ship_b)
        if winner == "a":
            results.a_wins += 1
        else:
            results.b_wins += 1
    return results
```

**Test Ships:**
- Standardized builds for each archetype
- Glass Cannon: 6 weapons, 2 reactors, 1 bridge, 2 engines
- Turtle: 2 weapons, 5 shields, 2 reactors, 1 bridge, 2 engines
- (etc. for all 6 doctrines)

---

## Acceptance Criteria

- [ ] 100+ battles run for each of 36 doctrine matchups (3600+ total battles)
- [ ] All doctrines achieve 30-50% overall win rate
- [ ] No doctrine has >60% or <30% win rate vs any single opponent
- [ ] Balance changes documented in BalanceConstants.gd with comments
- [ ] Balance report generated showing final win rate matrix

---

## Deliverables

1. **Balance Report** (docs/balance/AI_Doctrine_Balance_Report.md):
   - Win rate matrix (6x6 table)
   - Statistical analysis
   - Change log of balance iterations

2. **BalanceConstants.gd** (updated):
   - All tuning constants finalized
   - Comments explaining balance rationale

---

## Implementation Notes

**Tools**: Automated test suite with headless Godot (no GUI, fast simulation).
**Data Analysis**: Export results to CSV, analyze in spreadsheet or Python script.

**Design Philosophy**: Balance through iteration, not theory. Let data guide changes.

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
