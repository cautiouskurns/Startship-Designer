# F-AI-007: Multi-Target Distribution

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 1 day
**Dependencies:** F-AI-006 (Multi-Factor Target Scoring)
**Phase:** 2 - Threat Intelligence

---

## Purpose

**Why does this feature exist?**
Ships with 4+ weapons firing at a single room create wasted damage (overkill). Intelligent AI should distribute fire across multiple targets when beneficial, maximizing combat efficiency.

**What does it enable?**
AI can split fire: 2 weapons destroy an enemy reactor, remaining 2 weapons target a shield. No wasted damage. This makes high-weapon-count ships (6+ weapons) feel more strategic and creates more dynamic combat.

**Success criteria:**
- AI distributes fire when overkill damage would exceed 30% of total
- Multi-target attacks destroy more rooms per turn than single-target (when applicable)
- Damage efficiency increases by 20%+ for 6-weapon ships vs single-target strategy
- Multi-target decisions complete in <10ms per turn

---

## How It Works

### Overview

After primary target selection (F-AI-006), the system evaluates whether splitting fire is beneficial:
1. Calculate **overkill damage**: How much damage exceeds primary target's remaining HP?
2. If overkill ≥ 30% of total damage: evaluate **secondary targets**
3. Score secondary targets using same logic as primary (F-AI-006)
4. Distribute weapons: some attack primary, some attack secondary
5. Execute multi-target attack sequence

Result: Primary target destroyed + secondary target damaged (or also destroyed)

### User Flow
```
1. Turn starts → AI selects primary target (F-AI-006)
2. MultiTargetDistribution.evaluate_split(primary_target, our_weapons, enemy_ship) called
3. System calculates potential overkill damage
4. If overkill < threshold: return single_target_plan (primary only)
5. If overkill ≥ threshold:
   a. Score all remaining enemy rooms as secondary targets
   b. Select highest-scoring secondary target
   c. Calculate optimal weapon distribution:
      - X weapons → primary (enough to destroy)
      - Remaining weapons → secondary (maximize damage)
6. Return multi_target_plan: {primary: room_id, weapons_primary: X, secondary: room_id, weapons_secondary: Y}
7. Combat executes both attacks in sequence
8. Combat log: "Split fire: 2 weapons destroyed Reactor [C3], 4 weapons targeted Shield [D4]"
```

### Rules & Constraints

**Overkill Calculation:**
```
total_damage = our_active_weapons × weapon_dps  # E.g., 6 weapons × 15 = 90 damage
primary_target_remaining_hp = primary_target.current_hp

overkill = total_damage - primary_target_remaining_hp

overkill_percentage = (overkill / total_damage) × 100

if overkill_percentage >= 30:
    consider_multi_target = true
else:
    single_target = true  # Not enough waste to justify splitting
```

**Multi-Target Threshold:**
- Default: 30% overkill (if 1/3+ of damage wasted, split fire)
- Tunable per doctrine:
  - Alpha Strike: 40% threshold (prefers focused fire, "overwhelming force")
  - Defensive Turtle: 25% threshold (efficient damage maximization)
  - Adaptive Response: 30% threshold (balanced)

**Secondary Target Selection:**
- Exclude primary target (already being attacked)
- Exclude destroyed rooms
- Score all remaining rooms using F-AI-006 logic
- Select highest-scoring room as secondary target
- If secondary score < 50% of primary score: abort multi-target (not worth splitting focus)

**Weapon Distribution Logic:**
```
weapons_needed_primary = ceil(primary_target_remaining_hp / weapon_dps)
weapons_to_primary = min(weapons_needed_primary, total_weapons)

weapons_to_secondary = total_weapons - weapons_to_primary

if weapons_to_secondary < 2:
    abort_multi_target  # Need at least 2 weapons for secondary (meaningful damage)
    return single_target_plan

Example:
- 6 total weapons, 15 DPS each
- Primary target: 40 HP remaining → need 3 weapons (3 × 15 = 45, destroys it)
- Secondary gets 3 weapons (3 × 15 = 45 damage to secondary)
```

**Multi-Target Execution Order:**
- Always attack primary target first (higher priority)
- Then attack secondary target
- Reason: If primary is a reactor, destroying it first may unpower secondary (changes threat landscape)

**Multi-Target Limitations:**
- Max 2 targets per turn (primary + secondary)
- No tertiary targets (complexity vs benefit too low)
- Minimum 2 weapons per target (less than 2 = not meaningful damage)
- Bridge never a secondary target (only targeted when it's the last room)

### Edge Cases

**Exact overkill (damage exactly destroys primary, no waste):**
- overkill = 0 → overkill_percentage = 0%
- Single target selected (no waste to distribute)

**Primary target is last non-Bridge room:**
- Secondary options = only Bridge
- Bridge excluded from secondary → abort multi-target
- Result: single-target on primary (finish the fight)

**Secondary target has very low score (<50% of primary):**
- Example: Primary (Weapon, score 85), Secondary (Armor, score 30)
- 30 / 85 = 35% < 50% → abort multi-target
- Reason: Doctrine heavily deprioritizes armor, splitting fire wastes efficiency

**Only 2-3 weapons total:**
- Overkill may be high percentage, but can't split (need min 2 per target)
- Example: 3 weapons, primary needs 2 → only 1 left for secondary (too few)
- Result: single-target (all weapons on primary)

**Multiple rooms tied for secondary:**
- Use spatial priority (closer to Bridge) or random selection (±5 variance)
- Same tie-breaking logic as F-AI-006

**Overkill threshold varies by doctrine:**
- Alpha Strike (40% threshold): Less likely to split (prefers overwhelming force)
- Defensive Turtle (25% threshold): More likely to split (efficient resource use)
- Adaptive Response (30% threshold): Moderate splitting behavior

---

## User Interaction

### Controls
None (automatic multi-target evaluation)

### Visual Feedback
- Combat log shows split fire reasoning: "Split fire: 3 weapons → Reactor, 3 weapons → Shield"
- Target highlighting (F-AI-014) shows both primary and secondary targets briefly
- Damage numbers appear on both targets sequentially
- Thought bubbles (F-AI-013) reference multi-target strategy: "Spread the firepower!"

### Audio Feedback
None (optional: distinct sound for multi-target attacks in polish phase)

---

## Visual Design

### Layout
No direct UI (combat execution only)

### Components
N/A - Backend system

### Visual Style
N/A

### States
- **Evaluating:** During multi-target analysis
- **Single-Target:** Overkill below threshold, attack primary only
- **Multi-Target:** Overkill above threshold, attack primary + secondary
- **Executing:** Multi-target attack sequence in progress

---

## Technical Implementation

### Scene Structure
```
No new scenes (logic in Combat.gd)
```

### Script Responsibilities

**New File: `scripts/ai/MultiTargetDistribution.gd`**
- Evaluates overkill and determines if splitting fire is beneficial
- Methods:
  - evaluate_split(primary_target: RoomInstance, our_ship: ShipData, enemy_ship: ShipData, threat_map: ThreatMap, doctrine: Doctrine) -> AttackPlan
  - calculate_overkill(primary_target: RoomInstance, total_damage: int) -> Dictionary {overkill: int, percentage: float}
  - select_secondary_target(threat_map: ThreatMap, primary_target_id: int, primary_score: float, enemy_ship: ShipData) -> int
  - distribute_weapons(total_weapons: int, primary_hp: int, weapon_dps: int) -> Dictionary {primary: int, secondary: int}
  - get_overkill_threshold(doctrine: Doctrine) -> float
- Returns AttackPlan: {type: SINGLE/MULTI, primary: room_id, primary_weapons: int, secondary: room_id, secondary_weapons: int}

**New File: `scripts/ai/AttackPlan.gd`**
- Data class representing targeting decision
- Properties:
  - plan_type: enum (SINGLE_TARGET, MULTI_TARGET)
  - primary_target_id: int
  - primary_weapons: int
  - secondary_target_id: int (null if SINGLE_TARGET)
  - secondary_weapons: int (0 if SINGLE_TARGET)
- Methods: to_string() → human-readable summary

**Modified: `scripts/combat/Combat.gd`**
- After target selection (F-AI-006), call MultiTargetDistribution.evaluate_split()
- Receive AttackPlan
- If SINGLE_TARGET: execute attack as before
- If MULTI_TARGET:
  - Execute primary attack (primary_weapons × dps)
  - Check if primary destroyed
  - Execute secondary attack (secondary_weapons × dps)
  - Check if secondary destroyed
  - Update combat log with split fire entry

**Modified: `scripts/ui/CombatLog.gd`**
- New method: add_split_fire_entry(primary: String, primary_weapons: int, secondary: String, secondary_weapons: int)
- Format: "[Turn N] [Actor]: Split fire - [X] weapons → [Primary], [Y] weapons → [Secondary]"

### Data Structures

```gdscript
class_name AttackPlan

enum PlanType {
    SINGLE_TARGET,  # All weapons on one target
    MULTI_TARGET    # Weapons distributed across 2 targets
}

var plan_type: PlanType
var primary_target_id: int
var primary_weapons: int
var secondary_target_id: int = -1  # -1 if not applicable
var secondary_weapons: int = 0

var overkill_damage: int
var overkill_percentage: float

# Reasoning for combat log
var reasoning: String

func is_multi_target() -> bool:
    return plan_type == PlanType.MULTI_TARGET

func to_string() -> String:
    if is_multi_target():
        return "Multi-target: %d weapons → Room %d, %d weapons → Room %d (Overkill: %0.1f%%)" % [
            primary_weapons, primary_target_id, secondary_weapons, secondary_target_id, overkill_percentage
        ]
    else:
        return "Single-target: %d weapons → Room %d" % [primary_weapons, primary_target_id]
```

### Integration Points

**Connects to:**
- TargetScoring (F-AI-006): Primary target selection
- ThreatMap (F-AI-005): Secondary target scoring
- Doctrine (F-AI-003): Overkill threshold and targeting preferences
- ShipData: Weapon counts, room HP
- Combat log (F-AI-004): Split fire entries

**Emits signals:**
None (pure function)

**Listens for:**
None

**Modifies:**
- Enhances Combat.gd attack execution (splits damage across targets)

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
# Multi-target thresholds by doctrine
const MULTI_TARGET_OVERKILL_ALPHA_STRIKE = 0.4  # 40%
const MULTI_TARGET_OVERKILL_TURTLE = 0.25       # 25%
const MULTI_TARGET_OVERKILL_ADAPTIVE = 0.3      # 30%

# Multi-target constraints
const MULTI_TARGET_MIN_WEAPONS_PER_TARGET = 2   # Need at least 2 weapons per target
const MULTI_TARGET_SECONDARY_SCORE_MIN_RATIO = 0.5  # Secondary must be ≥50% of primary score

# Damage calculation
const WEAPON_DPS = 15  # Damage per weapon (from Phase 3.2 combat math)
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] MultiTargetDistribution.evaluate_split() returns AttackPlan with correct plan_type
- [ ] Overkill calculated correctly: overkill = total_damage - primary_target_hp
- [ ] Overkill percentage calculated correctly: (overkill / total_damage) × 100
- [ ] Single-target selected when overkill < 30%
- [ ] Multi-target evaluated when overkill ≥ 30%
- [ ] Secondary target selected using F-AI-006 scoring logic
- [ ] Secondary target aborted if score < 50% of primary score
- [ ] Weapon distribution calculated: primary gets ceil(target_hp / dps) weapons, rest go to secondary
- [ ] Multi-target aborted if secondary would get <2 weapons
- [ ] Alpha Strike doctrine uses 40% threshold (less splitting)
- [ ] Defensive Turtle doctrine uses 25% threshold (more splitting)
- [ ] Multi-target attack executes primary first, then secondary
- [ ] Combat log shows split fire entry with weapon distribution
- [ ] Multi-target evaluation completes in <10ms per turn

---

## Testing Checklist

### Functional Tests
- [ ] **6 weapons, primary 40 HP** (needs 3 weapons): Split to 3 primary + 3 secondary
- [ ] **6 weapons, primary 80 HP** (needs 6 weapons): Single-target (no overkill)
- [ ] **4 weapons, primary 30 HP** (needs 2 weapons): Split to 2 primary + 2 secondary
- [ ] **3 weapons, primary 20 HP** (needs 2 weapons): Single-target (only 1 left for secondary, too few)

### Edge Case Tests
- [ ] **Overkill exactly 30%**: Multi-target evaluated (threshold inclusive)
- [ ] **Primary is last non-Bridge room**: Secondary = only Bridge → aborted, single-target
- [ ] **Secondary score 30, primary score 80** (30/80 = 37.5% < 50%): Aborted, single-target
- [ ] **Alpha Strike doctrine, 35% overkill**: Single-target (below 40% threshold)
- [ ] **Turtle doctrine, 27% overkill**: Multi-target (above 25% threshold)

### Integration Tests
- [ ] Works with TargetScoring (F-AI-006) for primary and secondary selection
- [ ] Works with ThreatMap (F-AI-005) for scoring secondary targets
- [ ] Works with Doctrine (F-AI-003) for overkill thresholds
- [ ] Combat.gd executes multi-target attacks correctly (both targets damaged)
- [ ] Combat log shows split fire entries

### Polish Tests
- [ ] Multi-target evaluation causes no noticeable lag
- [ ] Damage efficiency demonstrably higher for 6-weapon ships with multi-target (vs single-target)
- [ ] Multi-target creates more dynamic combat (playtester feedback)
- [ ] Split fire reasoning clear in combat log

---

## Known Limitations

- **Max 2 targets:** No tertiary targeting (even with 9+ weapons)
- **No predictive splitting:** Doesn't anticipate "If I split now, next turn I can finish both"
- **Static weapon DPS:** Assumes all weapons deal 15 damage (doesn't account for weapon type variations)
- **Sequential execution:** Primary then secondary (no simultaneous targeting)

---

## Future Enhancements

*(Not for MVP)*

- Tertiary targeting: Distribute fire across 3+ targets for 9+ weapon ships
- Predictive splitting: Simulate multi-turn outcomes to optimize distribution
- Weapon type awareness: Split based on weapon specialization (beam vs missile vs ballistic)
- Simultaneous targeting: Visual effect shows both targets attacked at once
- Overkill recovery: Redirect overkill damage to adjacent rooms (splash damage)

---

## Implementation Notes

**Code Reuse:**
- Secondary target scoring reuses F-AI-006 TargetScoring logic
- Weapon distribution uses simple arithmetic (ceil, min, max)
- Overkill calculation reuses damage formulas from Combat.gd

**Performance:**
- Multi-target evaluation only runs when overkill detected (not every turn)
- Secondary scoring can reuse cached ThreatMap (no recalculation)
- Weapon distribution is O(1) math (very fast)

**Compatibility:**
- Multi-target is additive (doesn't replace single-target, augments it)
- Can be disabled via flag for A/B testing
- Old single-target behavior preserved when multi-target aborted

**Design Philosophy:**
- Multi-target should feel *efficient*, not chaotic
- Splitting fire is an optimization, not a requirement (single-target still valid)
- Clear log entries help players understand multi-target decisions
- Doctrine shapes multi-target behavior (Alpha Strike focuses, Turtle optimizes)

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
