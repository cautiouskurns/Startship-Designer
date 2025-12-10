# F-AI-002: Combat State Evaluator

**Status:** 🔴 Planned
**Priority:** 🔥 Critical
**Estimated Time:** 2 days
**Dependencies:** F-AI-001 (Ship Profile Analyzer)
**Phase:** 1 - Foundation

---

## Purpose

**Why does this feature exist?**
AI needs to understand the current state of combat—who's winning, who's losing, and by how much—to make contextual decisions about risk-taking and strategy.

**What does it enable?**
AI can detect when it's losing and become more aggressive (desperation), or when it's winning and play more conservatively. Different combat states trigger different behaviors (retreat, all-out attack, defensive posture).

**Success criteria:**
- Combat state evaluation completes in <5ms per turn
- Win probability predictions accurate within ±15% of actual outcomes
- Momentum shifts detected within 1 turn of significant changes
- Desperation mode triggers appropriately when losing badly

---

## How It Works

### Overview

Every turn, the system evaluates the current combat state by analyzing both ships' conditions. This produces a CombatState object containing:
- **Win probability** (0-100% chance of victory)
- **HP advantage** (positive if player ahead, negative if behind)
- **DPS advantage** (positive if dealing more damage, negative if taking more)
- **Momentum** (GAINING, NEUTRAL, LOSING)
- **Desperation level** (NONE, MILD, CRITICAL)
- **Turn count** and **combat phase** (EARLY, MID, LATE)

The AI uses this state to adjust aggression, target selection, and doctrine behavior.

### User Flow
```
1. Turn begins in Combat.gd
2. CombatStateEvaluator.evaluate(player_ship, enemy_ship, turn_number) called
3. System calculates HP ratios, active weapon counts, shield status
4. System computes win probability based on stat advantages
5. System detects momentum by comparing to previous turn's state
6. CombatState object stored and passed to AI decision systems
7. AI adjusts behavior based on state (e.g., desperation → aggressive)
```

### Rules & Constraints

**HP Advantage Calculation:**
- HP percentage = (current_hp / max_hp) × 100
- HP advantage = player_hp_percentage - enemy_hp_percentage
- Range: -100 (enemy full health, player dead) to +100 (player full, enemy dead)

**DPS Advantage Calculation:**
- Active weapons = count of functional weapon rooms
- DPS estimate = active_weapons × 15 (average damage per weapon)
- DPS advantage = player_dps - enemy_dps
- Normalized to percentage: (dps_advantage / max_dps) × 100

**Win Probability Formula:**
```
base_probability = 50%
hp_factor = hp_advantage × 0.3  // ±30% swing
dps_factor = dps_advantage × 0.2  // ±20% swing
shield_factor = (player_shields - enemy_shields) × 5%  // ±5% per shield difference

win_probability = clamp(base_probability + hp_factor + dps_factor + shield_factor, 0, 100)
```

**Momentum Detection:**
- Compare current win_probability to previous turn's value
- GAINING: win_probability increased by ≥10%
- LOSING: win_probability decreased by ≥10%
- NEUTRAL: change within ±10%

**Desperation Thresholds:**
- NONE: win_probability ≥ 40%
- MILD: win_probability 20-40%
- CRITICAL: win_probability < 20%

**Combat Phase:**
- EARLY: turns 1-3
- MID: turns 4-8
- LATE: turns 9+

### Edge Cases

**First turn:**
- No previous state to compare for momentum
- Momentum defaults to NEUTRAL
- Win probability based on ship profiles only

**Identical ships:**
- Win probability = 50%
- Slight randomization (±5%) to prevent stalemate logic

**Rapid state changes:**
- If multiple rooms destroyed in one turn, momentum may skip from GAINING to LOSING
- System detects "dramatic shift" flag if win_probability changes by ≥25%

**Damaged ships entering combat:**
- System uses current HP, not max theoretical HP
- Win probability accounts for pre-existing damage

---

## User Interaction

### Controls
None (automatic evaluation)

### Visual Feedback
- Win probability shown in Doctrine UI panel (Phase 4)
- Combat log shows momentum shifts ("Momentum shifting in our favor!")
- Desperation state reflected in AI thought bubbles ("We're in trouble!")

### Audio Feedback
None (Phase 4 may add tension music based on state)

---

## Visual Design

### Layout
No direct UI (data structure only)

### Components
N/A - Backend system

### Visual Style
N/A

### States
- **Evaluating:** During state calculation
- **Complete:** State ready for AI use
- **Stale:** Previous turn's state (outdated)

---

## Technical Implementation

### Scene Structure
```
No new scenes (pure data structure)
```

### Script Responsibilities

**New File: `scripts/ai/CombatStateEvaluator.gd`**
- Evaluates current combat state from ship data
- Calculates HP advantage, DPS advantage, win probability
- Detects momentum shifts by comparing to previous state
- Determines desperation level and combat phase
- Caches previous state for momentum comparison

**New File: `scripts/ai/CombatState.gd`**
- Data class holding evaluation results
- Properties: win_probability, hp_advantage, dps_advantage, momentum, desperation, combat_phase
- Methods: to_string() for debugging, get_aggression_modifier() for AI use

**Modified: `scripts/combat/Combat.gd`**
- Calls CombatStateEvaluator at start of each turn
- Stores current CombatState with combat data
- Passes CombatState to AI decision systems

### Data Structures

```gdscript
class_name CombatState

enum Momentum {
    GAINING,    # Winning momentum (win prob increasing)
    NEUTRAL,    # Stalemate
    LOSING      # Losing momentum (win prob decreasing)
}

enum Desperation {
    NONE,       # Comfortable position (40%+ win chance)
    MILD,       # Concerning position (20-40% win chance)
    CRITICAL    # Desperate position (<20% win chance)
}

enum CombatPhase {
    EARLY,      # Turns 1-3
    MID,        # Turns 4-8
    LATE        # Turns 9+
}

var win_probability: float  # 0.0-1.0
var hp_advantage: float     # -100 to +100
var dps_advantage: float    # -100 to +100

var momentum: Momentum
var desperation: Desperation
var combat_phase: CombatPhase

var turn_number: int
var dramatic_shift: bool  # True if win_prob changed ≥25% in one turn

# Ship condition snapshots
var player_hp_percent: float
var enemy_hp_percent: float
var player_active_weapons: int
var enemy_active_weapons: int
```

### Integration Points

**Connects to:**
- ShipProfile (uses stat ratings for initial prediction)
- ShipData (reads current HP, active rooms)
- CombatAI (provides state context for decisions)

**Emits signals:**
None (pure function)

**Listens for:**
None

**Modifies:**
Nothing (read-only analysis)

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
const WIN_PROB_HP_WEIGHT = 0.3        # How much HP affects win probability
const WIN_PROB_DPS_WEIGHT = 0.2       # How much DPS affects win probability
const WIN_PROB_SHIELD_WEIGHT = 5.0    # Win prob bonus per shield advantage

const MOMENTUM_THRESHOLD = 0.1        # 10% change needed to shift momentum
const DRAMATIC_SHIFT_THRESHOLD = 0.25 # 25% change = dramatic

const DESPERATION_MILD_THRESHOLD = 0.4    # Below 40% win chance
const DESPERATION_CRITICAL_THRESHOLD = 0.2 # Below 20% win chance

const COMBAT_PHASE_EARLY_MAX = 3
const COMBAT_PHASE_MID_MAX = 8

const AVERAGE_WEAPON_DPS = 15.0  # For DPS estimation
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] CombatStateEvaluator correctly calculates HP advantage (player 80% HP, enemy 40% = +40 advantage)
- [ ] CombatStateEvaluator correctly calculates DPS advantage (player 4 weapons, enemy 2 weapons = positive advantage)
- [ ] Win probability calculation accounts for HP, DPS, and shield advantages
- [ ] Win probability clamped to 0-100% range
- [ ] Momentum detection correctly identifies GAINING when win prob increases ≥10%
- [ ] Momentum detection correctly identifies LOSING when win prob decreases ≥10%
- [ ] Momentum defaults to NEUTRAL on first turn (no previous state)
- [ ] Desperation level set to CRITICAL when win_probability < 20%
- [ ] Desperation level set to MILD when win_probability 20-40%
- [ ] Combat phase correctly identifies EARLY (turns 1-3), MID (4-8), LATE (9+)
- [ ] Dramatic shift flag set when win_probability changes ≥25% in one turn
- [ ] State evaluation completes in <5ms for typical combat
- [ ] Combat.gd successfully creates CombatState every turn

---

## Testing Checklist

### Functional Tests
- [ ] **Balanced ships, full health**: win_probability ≈ 50%, momentum = NEUTRAL
- [ ] **Player 100% HP, enemy 50% HP**: hp_advantage = +50, win_probability > 60%
- [ ] **Player 2 weapons, enemy 6 weapons**: dps_advantage negative, win_probability < 40%
- [ ] **Player loses 3 weapons in one turn**: momentum = LOSING, dramatic_shift = true

### Edge Case Tests
- [ ] **First turn**: momentum = NEUTRAL (no previous state to compare)
- [ ] **Identical ships**: win_probability ≈ 50% with slight randomization
- [ ] **Player destroys enemy reactor**: win_probability spikes dramatically, momentum = GAINING
- [ ] **Late game (turn 12)**: combat_phase = LATE

### Integration Tests
- [ ] Works with ShipProfile data from F-AI-001
- [ ] Works with live ShipData during combat
- [ ] Doesn't break existing Combat.gd turn flow
- [ ] State accessible from AI decision systems

### Polish Tests
- [ ] State evaluation causes no noticeable lag
- [ ] Win probability predictions correlate with actual outcomes (±15% accuracy)
- [ ] to_string() produces readable debug output
- [ ] Momentum shifts feel responsive to player actions

---

## Known Limitations

- **Static DPS estimation:** Assumes all weapons deal same damage (15 DPS average)
- **No shield regeneration prediction:** Doesn't account for Shield Harmonics synergy
- **No power state consideration:** Doesn't detect if weapons are unpowered
- **Simple win probability model:** Doesn't account for room positioning, synergies, or doctrines

---

## Future Enhancements

*(Not for MVP)*

- Machine learning: Train win probability model on actual combat outcomes
- Predictive modeling: Simulate next 2-3 turns to predict likely outcomes
- Synergy awareness: Account for Shield Harmonics, Weapons Arrays in DPS calculation
- Power state analysis: Reduce DPS estimate for unpowered weapons
- Historical tracking: Track momentum over last 3 turns instead of just previous turn

---

## Implementation Notes

**Code Reuse:**
- HP calculation logic similar to ShipProfilePanel's durability calculation
- Active room counting reuses ShipData.count_room_type() methods

**Performance:**
- Cache previous CombatState instead of recalculating from history
- Only recalculate win probability when ship states change
- Avoid expensive operations (simulation, deep analysis) in this layer

**Compatibility:**
- CombatState is additive (doesn't modify Combat.gd state)
- Can be disabled via flag for A/B testing vs old AI
- Win probability available for future difficulty scaling

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
