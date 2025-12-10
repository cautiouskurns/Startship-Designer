# F-AI-006: Multi-Factor Target Scoring

**Status:** 🔴 Planned
**Priority:** 🔥 Critical
**Estimated Time:** 2 days
**Dependencies:** F-AI-005 (Threat Assessment System), F-AI-003 (Basic Doctrine System)
**Phase:** 2 - Threat Intelligence

---

## Purpose

**Why does this feature exist?**
Threat assessment (F-AI-005) identifies *what* is dangerous, but doctrine (F-AI-003) defines *how* we should respond. Multi-factor scoring combines threat, doctrine, and combat state to select the single best target each turn.

**What does it enable?**
AI makes contextual decisions: "I'm an Alpha Strike Glass Cannon, losing momentum, so I'll target the enemy's highest-threat weapon to reduce incoming damage before they finish me." Different ships make different choices in the same situation.

**Success criteria:**
- Target selection demonstrably influenced by doctrine (≥80% correlation)
- Target selection changes appropriately as combat state shifts
- AI selects "optimal" target (matches human expert judgment 70%+ of the time)
- Target scoring completes in <5ms per turn

---

## How It Works

### Overview

Every turn, the AI combines three data sources to score each potential target:
1. **Threat scores** from ThreatAssessment (F-AI-005): How dangerous is this room?
2. **Doctrine weights** from Doctrine (F-AI-003): What room types does my strategy prioritize?
3. **Combat state modifiers** from CombatState (F-AI-002): Am I winning or losing?

The formula:
```
final_score = (threat_score × doctrine_weight) + state_modifier + random_variance
```

The room with the highest final score becomes the primary target.

### User Flow
```
1. Turn starts → AI needs primary target
2. TargetScoring.select_target(threat_map, doctrine, combat_state, enemy_ship) called
3. For each enemy room:
   a. Get threat_score from ThreatMap
   b. Get doctrine_weight for room's type
   c. Calculate state_modifier based on CombatState
   d. Add small random_variance for unpredictability
   e. Compute final_score
4. Sort rooms by final_score (descending)
5. Return highest-scoring room as primary target
6. Log reasoning: "Targeting Weapon [E2] (Threat: 75, Doctrine: Alpha Strike, Score: 88)"
```

### Rules & Constraints

**Final Score Formula:**

```
For each enemy room:

1. BASE SCORE (from threat assessment)
   base_score = threat_score  # 0-100 from F-AI-005

2. DOCTRINE MULTIPLIER (from doctrine weights)
   room_type = room.type  # WEAPON, SHIELD, ENGINE, etc.
   doctrine_weight = doctrine.target_weights[room_type]  # 0.0-1.0

   weighted_score = base_score × doctrine_weight

   Example:
   - Weapon with threat=75, Alpha Strike doctrine (weapon_weight=1.0) → 75 × 1.0 = 75
   - Shield with threat=50, Alpha Strike doctrine (shield_weight=0.5) → 50 × 0.5 = 25

3. STATE MODIFIER (from combat state)
   if combat_state.desperation == CRITICAL:
       # Desperate: focus on high-damage threats
       if room_type == WEAPON:
           weighted_score += 20

   if combat_state.desperation == NONE and combat_state.win_probability > 0.7:
       # Winning: methodical targeting, finish structural rooms
       if room.health_percent < 0.5:
           weighted_score += 15

   if combat_state.momentum == LOSING:
       # Losing momentum: shift to high-value targets
       if room_type == REACTOR:
           weighted_score += 10

   if combat_state.combat_phase == LATE:
       # Late game: prefer finishing blows
       if room.health_percent < 0.3:
           weighted_score += 20

4. DOCTRINE TRAIT MODIFIERS (from doctrine traits)
   # Alpha Strike traits
   if doctrine.has_trait(GLASS_CANNON_THINKING):
       # Ignore own HP, always maximize damage
       if room_type == WEAPON or room_type == REACTOR:
           weighted_score += 10

   if doctrine.has_trait(NO_QUARTER):
       # Prefer finishing damaged rooms
       if room.health_percent < 0.5:
           weighted_score += 15

   # Defensive Turtle traits
   if doctrine.has_trait(SURVIVAL_INSTINCT):
       # Heavily prioritize weapons when low HP
       if our_ship.health_percent < 0.5 and room_type == WEAPON:
           weighted_score += 25

   if doctrine.has_trait(THREAT_REDUCTION):
       # Extra weight to highest-DPS rooms
       if room.type == WEAPON and room.is_powered:
           weighted_score += (room.dps_contribution × 0.5)

   # Adaptive Response traits
   if doctrine.has_trait(STATE_AWARE):
       # Already handled in STATE MODIFIER section
       pass

   if doctrine.has_trait(BALANCED_TARGETING):
       # Reduce variance to spread damage
       random_variance = random_variance × 0.5

5. RANDOM VARIANCE (unpredictability)
   random_variance = randf_range(-5.0, 5.0)  # ±5 points
   weighted_score += random_variance

6. FINAL SCORE
   final_score = clamp(weighted_score, 0.0, 150.0)  # Cap at 150
```

**Target Selection Logic:**
```
1. Calculate final_score for all enemy rooms
2. Sort rooms by final_score (highest first)
3. Exclude invalid targets:
   - Destroyed rooms (already at 0 HP)
   - Bridge (unless it's the only room left)
4. Select room with highest final_score as primary target
5. If tie (scores within ±2 points): prefer spatially closer room
6. Return primary_target_id
```

**Doctrine Weight Reference** (from F-AI-003):
- Alpha Strike: weapons=1.0, reactors=0.7, shields=0.5, engines=0.3, armor=0.1
- Defensive Turtle: weapons=1.0, reactors=0.6, shields=0.1, engines=0.2, armor=0.05
- Adaptive Response: reactors=0.8, weapons=0.7, shields=0.4, engines=0.4, armor=0.3

**Bridge Targeting Rules:**
- Bridge never targeted unless:
  - It's the only remaining room (instant win condition)
  - Special "Surgical Strike" tactic detected (Phase 3, F-AI-011)
- Bridge excluded from normal scoring

### Edge Cases

**All scores below threshold (all < 30):**
- Boost highest score by +20 to ensure something is targeted
- Log: "No high-priority targets, selecting best available"

**Perfect tie (multiple rooms score exactly equal):**
- Rare due to random_variance (±5 points)
- Fallback: prefer room with lowest grid distance to Bridge (spatial priority)

**Doctrine weight = 0.0 (room type ignored by doctrine):**
- Example: Alpha Strike targeting Armor (weight=0.1), threat=60 → final score = 6
- May still be targeted if all other rooms destroyed (highest of remaining)

**Target has 0 threat but high doctrine weight:**
- Example: Unpowered weapon (threat=5), Alpha Strike doctrine (weight=1.0) → score = 5
- Low score means likely skipped for powered threats

**Desperation mode overrides doctrine:**
- Example: Turtle doctrine (weapon_weight=1.0) + CRITICAL desperation → weapons get +20 bonus
- Result: Even Turtle prioritizes weapons when losing badly (survival trumps doctrine)

**Late-game with only armor/structure remaining:**
- State modifier boosts damaged rooms (+20)
- Ensures AI finishes the fight quickly, doesn't stall

---

## User Interaction

### Controls
None (automatic target scoring)

### Visual Feedback
- Combat log shows final scores in reasoning: "Selected Weapon [E2] (Score: 88)"
- Target highlighting (F-AI-014) shows final target with visual emphasis
- Thought bubbles (F-AI-013) reference scoring logic: "That weapon is my top priority!"

### Audio Feedback
None

---

## Visual Design

### Layout
No direct UI (data structure only)

### Components
N/A - Backend system

### Visual Style
N/A

### States
- **Scoring:** During target evaluation
- **Complete:** Primary target selected
- **Rescoring:** Target destroyed mid-turn, need new target

---

## Technical Implementation

### Scene Structure
```
No new scenes (pure data structure)
```

### Script Responsibilities

**New File: `scripts/ai/TargetScoring.gd`**
- Combines threat, doctrine, and state to score targets
- Methods:
  - select_target(threat_map: ThreatMap, doctrine: Doctrine, combat_state: CombatState, enemy_ship: ShipData, our_ship: ShipData) -> int
  - calculate_final_score(room_id: int, threat_score: float, doctrine: Doctrine, combat_state: CombatState, enemy_ship: ShipData, our_ship: ShipData) -> float
  - get_state_modifier(room: RoomInstance, combat_state: CombatState) -> float
  - get_trait_modifier(room: RoomInstance, doctrine: Doctrine, our_ship: ShipData) -> float
  - get_spatial_priority(room_id: int, enemy_ship: ShipData) -> float
- Returns primary_target_id

**New File: `scripts/ai/TargetScore.gd`**
- Data class holding scoring breakdown for debugging
- Properties: room_id, threat_score, doctrine_weight, state_modifier, trait_modifier, random_variance, final_score
- Methods: to_string() → human-readable breakdown

**Modified: `scripts/combat/Combat.gd`**
- Calls TargetScoring.select_target() at turn start (replaces old _select_target_room())
- Receives primary_target_id
- Passes target to attack execution
- Logs target selection with reasoning

**Modified: `scripts/ui/CombatLog.gd`**
- Enhanced target selection entry to include final score
- Format: "[Turn N] [Actor]: Targeting [Room] [Grid] - [Doctrine] priority (Score: [X])"

### Data Structures

```gdscript
class_name TargetScore

var room_id: int
var threat_score: float
var doctrine_weight: float
var weighted_score: float
var state_modifier: float
var trait_modifier: float
var random_variance: float
var final_score: float

# Reasoning text for combat log
var reasoning: String

func to_string() -> String:
    return "Room %d: Threat=%0.1f × Doctrine=%0.2f = %0.1f + State=%0.1f + Trait=%0.1f + Rand=%0.1f = Final=%0.1f" % [
        room_id, threat_score, doctrine_weight, weighted_score,
        state_modifier, trait_modifier, random_variance, final_score
    ]
```

### Integration Points

**Connects to:**
- ThreatMap (F-AI-005): Provides threat_scores
- Doctrine (F-AI-003): Provides target_weights and traits
- CombatState (F-AI-002): Provides desperation, momentum, combat_phase
- ShipData: Reads room health, power status
- Combat log (F-AI-004): Provides final score for reasoning

**Emits signals:**
None (pure function)

**Listens for:**
None

**Modifies:**
- Replaces Combat.gd:_select_target_room() function

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
# State modifiers
const SCORING_DESPERATION_WEAPON_BONUS = 20.0
const SCORING_WINNING_DAMAGED_BONUS = 15.0
const SCORING_LOSING_REACTOR_BONUS = 10.0
const SCORING_LATE_GAME_FINISHING_BONUS = 20.0

# Trait modifiers
const SCORING_GLASS_CANNON_OFFENSE_BONUS = 10.0
const SCORING_NO_QUARTER_DAMAGED_BONUS = 15.0
const SCORING_SURVIVAL_INSTINCT_WEAPON_BONUS = 25.0
const SCORING_THREAT_REDUCTION_DPS_MULTIPLIER = 0.5

# Random variance
const SCORING_RANDOM_VARIANCE_MIN = -5.0
const SCORING_RANDOM_VARIANCE_MAX = 5.0
const SCORING_BALANCED_VARIANCE_REDUCTION = 0.5  # Halve variance for Balanced Targeting trait

# Normalization
const SCORING_LOW_THRESHOLD = 30.0  # Boost if all scores below this
const SCORING_LOW_BOOST = 20.0
const SCORING_TIE_THRESHOLD = 2.0  # Scores within ±2 are ties
const SCORING_MAX_FINAL_SCORE = 150.0

# Health thresholds for modifiers
const SCORING_DAMAGED_THRESHOLD = 0.5  # <50% HP
const SCORING_CRITICAL_THRESHOLD = 0.3  # <30% HP
const SCORING_OWN_LOW_HP_THRESHOLD = 0.5  # <50% our HP
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] TargetScoring.select_target() returns room_id of valid enemy room
- [ ] Final score combines threat × doctrine_weight correctly
- [ ] Alpha Strike doctrine selects weapons/reactors over shields (when threat equal)
- [ ] Defensive Turtle doctrine selects weapons over shields (weapon_weight=1.0 vs shield_weight=0.1)
- [ ] Adaptive Response doctrine adjusts aggression based on combat_state
- [ ] CRITICAL desperation adds +20 to enemy weapons (state modifier)
- [ ] LATE combat phase adds +20 to damaged rooms <30% HP (finishing bonus)
- [ ] GLASS_CANNON_THINKING trait adds +10 to weapons and reactors
- [ ] NO_QUARTER trait adds +15 to rooms <50% HP
- [ ] SURVIVAL_INSTINCT trait adds +25 to weapons when our HP <50%
- [ ] Random variance adds ±5 points to all scores (creates unpredictability)
- [ ] Destroyed rooms excluded from targeting
- [ ] Bridge excluded unless it's the only remaining room
- [ ] Target scoring completes in <5ms per turn
- [ ] Combat log shows final score in reasoning text

---

## Testing Checklist

### Functional Tests
- [ ] **Alpha Strike vs Turtle**: Alpha Strike targets enemy weapons first (high threat + doctrine weight)
- [ ] **Turtle vs Glass Cannon**: Turtle targets enemy weapons (threat reduction)
- [ ] **Adaptive Response, winning**: Targets damaged rooms for finishing blows
- [ ] **Adaptive Response, losing**: Targets reactors to disrupt enemy advantage
- [ ] **Desperation = CRITICAL**: Enemy weapons prioritized regardless of doctrine

### Edge Case Tests
- [ ] **All scores <30**: System boosts highest score by +20, selects target
- [ ] **Perfect tie (scores within ±2)**: Selects spatially closer room
- [ ] **Doctrine weight = 0.0** (e.g., Alpha Strike vs Armor): Low final score, likely skipped
- [ ] **Only Bridge remains**: Bridge targeted (instant win condition)

### Integration Tests
- [ ] Works with ThreatMap (F-AI-005) for threat scores
- [ ] Works with Doctrine (F-AI-003) for weights and traits
- [ ] Works with CombatState (F-AI-002) for modifiers
- [ ] Replaces Combat.gd:_select_target_room() successfully
- [ ] Combat log receives final score for reasoning text

### Polish Tests
- [ ] Target scoring causes no noticeable lag
- [ ] AI targeting demonstrably smarter than simple priority (playtester validation)
- [ ] Different doctrines produce measurably different targeting patterns
- [ ] Random variance creates unpredictability without sacrificing strategy

---

## Known Limitations

- **Single-target only:** Doesn't evaluate multi-target combinations (F-AI-007 adds this)
- **No look-ahead:** Doesn't predict "If I destroy this reactor, 3 weapons unpower"
- **Static trait effects:** Trait modifiers are fixed bonuses, not dynamic calculations
- **No enemy prediction:** Doesn't consider "enemy will target X next turn, so protect Y"

---

## Future Enhancements

*(Not for MVP)*

- Multi-target optimization (F-AI-007): Score target combinations, not just single rooms
- Predictive scoring: Simulate "If I destroy this room, what's the next best target?"
- Dynamic trait values: Trait modifiers scale with combat intensity
- Enemy behavior prediction: Anticipate enemy targeting and counter-position
- Learning system: Track which targets led to victories, adjust scoring over time

---

## Implementation Notes

**Code Reuse:**
- Doctrine weight lookup reuses F-AI-003 data structures
- Threat scores reuse F-AI-005 ThreatMap
- State checks reuse F-AI-002 CombatState properties

**Performance:**
- Cache doctrine weights (don't look up per room)
- Early exit for destroyed rooms (skip scoring entirely)
- Use fast arithmetic (avoid expensive function calls in hot loop)

**Compatibility:**
- Replaces Combat.gd:_select_target_room() cleanly (same interface)
- Old targeting logic can be toggled via flag for A/B testing
- Scoring exposes tuning knobs for balance iteration

**Design Philosophy:**
- Scoring should be transparent (players understand why AI chose target)
- Multiple factors create nuanced decisions (not "always weapons first")
- Random variance prevents repetitive behavior (keeps combat fresh)
- Doctrine shapes personality (different ships think differently)

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
