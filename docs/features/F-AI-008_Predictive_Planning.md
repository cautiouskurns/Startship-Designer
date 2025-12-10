# F-AI-008: Predictive Planning

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 3 days
**Dependencies:** F-AI-005 (Threat Assessment System), F-AI-006 (Multi-Factor Target Scoring)
**Phase:** 3 - Advanced Behaviors

---

## Purpose

**Why does this feature exist?**
Reactive AI only considers the current turn. Predictive AI thinks ahead: "If I destroy this reactor now, 3 enemy weapons unpower next turn, reducing their damage by 45." This creates strategic, forward-thinking behavior.

**What does it enable?**
AI prioritizes high-value cascading targets (reactors powering multiple threats), anticipates multi-turn outcomes, and makes sacrifices for long-term gain. Combat feels more intelligent and less "whack-a-mole."

**Success criteria:**
- AI correctly identifies cascading damage opportunities (reactor → unpower 3 weapons) 90%+ of the time
- Predictive targets demonstrably better outcomes than reactive (10%+ win rate improvement in simulations)
- Prediction completes in <20ms per turn (1-2 turn lookahead)
- Players can understand predictive reasoning from combat log

---

## How It Works

### Overview

After target scoring (F-AI-006), the system simulates the next 1-2 turns to evaluate **cascading effects**:
1. **Current turn simulation**: "If I destroy room X, what changes?"
   - Rooms that lose power
   - Enemy stat changes (weapons, shields, engines)
   - New threat landscape
2. **Next turn simulation**: "What can I accomplish next turn with that new state?"
   - Which new targets become high priority?
   - What's my expected damage output next turn?
3. **Value comparison**: Compare immediate vs predictive value
   - Immediate: Destroy high-threat weapon now (30 damage)
   - Predictive: Destroy reactor now, unpower 3 weapons, reduce enemy damage by 45 next turn
4. **Select optimal strategy**: Choose path with highest **cumulative value** over 2 turns

### User Flow
```
1. Turn starts → Primary target selected (F-AI-006)
2. PredictivePlanning.evaluate_prediction(primary_target, enemy_ship, our_ship, combat_state) called
3. System simulates:
   a. Destroy primary target → calculate cascading effects
   b. Recalculate enemy threat landscape (new ThreatMap)
   c. Simulate our next turn with new state
   d. Calculate cumulative value over 2 turns
4. System evaluates alternative targets (top 3 from F-AI-006):
   a. Simulate destroying each alternative
   b. Calculate cascading effects for each
   c. Compare cumulative values
5. If predictive alternative offers ≥20% better value: override primary target
6. Return final target with predictive reasoning
7. Combat log: "Targeting Reactor [C3] - Predictive: Will unpower 3 weapons, reducing enemy damage by 45 next turn"
```

### Rules & Constraints

**Simulation Depth:**
- **1-turn lookahead** (default): Simulate current turn + immediate consequences
- **2-turn lookahead** (advanced): Simulate current turn + next turn + outcomes
- Max 2 turns (performance constraint, diminishing returns beyond this)

**Cascading Effect Detection:**

**1. Power Grid Disruption**
```
if target.type == REACTOR:
    affected_rooms = get_rooms_powered_by_reactor(target)
    for room in affected_rooms:
        if room.type == WEAPON:
            damage_reduction += 15  # Weapon DPS lost
        if room.type == SHIELD:
            defense_reduction += 15  # Shield absorption lost
        if room.type == ENGINE:
            initiative_loss += 1

    cascading_value = damage_reduction + (defense_reduction × 0.5) + (initiative_loss × 10)
```

**2. Stat Degradation**
```
if target.type == WEAPON:
    enemy_damage_reduction = 15  # Immediate threat reduction
if target.type == SHIELD:
    our_damage_increase = 15  # Our attacks more effective next turn
if target.type == ENGINE:
    initiative_gain = 1  # May gain first-strike advantage
```

**3. Multi-Turn Advantage**
```
current_turn_value = immediate_threat_reduction
next_turn_value = (cascading_damage_reduction × 0.8)  # Discounted (less certain)

cumulative_value = current_turn_value + next_turn_value
```

**Predictive Target Override Threshold:**
- Alternative target must offer **≥20% better cumulative value** than primary
- Example:
  - Primary (Weapon): immediate value = 30
  - Alternative (Reactor): immediate = 5, cascading = 45, cumulative = 50
  - 50 vs 30 = +67% value → override primary, select reactor
- Threshold prevents overthinking (only switch if clearly better)

**Predictive Evaluation Limits:**
- Evaluate top 3 targets from F-AI-006 scoring (not all rooms)
- Skip prediction if combat_phase == LATE (turns 9+, too few turns remaining)
- Skip prediction if desperation == CRITICAL (immediate threats take priority)

**Cascading Value Scoring:**
```
For reactor target:
    powered_rooms = count rooms powered by this reactor

    weapons_unpowered = count WEAPON rooms in powered_rooms
    shields_unpowered = count SHIELD rooms in powered_rooms
    engines_unpowered = count ENGINE rooms in powered_rooms

    damage_reduction = weapons_unpowered × 15
    defense_reduction = shields_unpowered × 15
    initiative_value = engines_unpowered × 10

    cascading_value = damage_reduction + (defense_reduction × 0.5) + initiative_value

    # Discount for uncertainty (next turn may not go as planned)
    next_turn_value = cascading_value × 0.8

    cumulative_value = immediate_threat_reduction + next_turn_value

For weapon target (direct):
    immediate_value = 15 (enemy damage reduced)
    cumulative_value = 15 (no cascading)

For shield target (direct):
    immediate_value = 15 (our damage more effective)
    cumulative_value = 15 (no cascading)
```

### Edge Cases

**Reactor powers no high-value rooms:**
- Reactor powers only armor and empty spaces
- Cascading value = low (5-10)
- Likely not worth predictive override (direct weapon still better)

**Multiple reactors power same rooms:**
- Destroying one reactor doesn't unpower rooms (redundant power)
- System detects redundancy: check if rooms have alternate power source
- Cascading value = 0 if rooms stay powered

**Late game (turn 9+):**
- Skip predictive planning (not enough turns to leverage cascading)
- Default to immediate value targeting

**Desperation mode (CRITICAL):**
- Skip predictive planning (need immediate threat reduction)
- Override: always target weapons first (reduce incoming damage NOW)

**Tie in cumulative value:**
- If predictive target = primary target value (within ±10%): stick with primary
- Reason: Avoid overthinking, primary already optimal

**Predictive reasoning fails (simulation error):**
- Fallback to primary target (don't block combat)
- Log warning: "Predictive planning unavailable, using reactive targeting"

---

## User Interaction

### Controls
None (automatic predictive evaluation)

### Visual Feedback
- Combat log shows predictive reasoning: "Predictive: Reactor powers 3 weapons, destroying will reduce enemy damage by 45"
- Thought bubbles (F-AI-013) reference future planning: "Cutting their power will cripple them!"
- Target highlighting (F-AI-014) shows cascading affected rooms briefly (flash yellow when reactor targeted)

### Audio Feedback
None (optional: distinct "tactical insight" sound when predictive override occurs)

---

## Visual Design

### Layout
No direct UI (logic only)

### Components
N/A - Backend system

### Visual Style
N/A

### States
- **Evaluating:** During predictive simulation
- **Override:** Predictive target selected (better than primary)
- **Confirmed:** Primary target confirmed (no predictive override)
- **Skipped:** Predictive planning skipped (late game or desperation)

---

## Technical Implementation

### Scene Structure
```
No new scenes (pure logic)
```

### Script Responsibilities

**New File: `scripts/ai/PredictivePlanning.gd`**
- Simulates turn outcomes and evaluates cascading effects
- Methods:
  - evaluate_prediction(primary_target: int, alternative_targets: Array, enemy_ship: ShipData, our_ship: ShipData, combat_state: CombatState, threat_map: ThreatMap) -> PredictiveResult
  - simulate_room_destruction(target_id: int, enemy_ship: ShipData) -> SimulationResult
  - calculate_cascading_value(destroyed_room: RoomInstance, enemy_ship: ShipData) -> float
  - get_powered_rooms(reactor: RoomInstance, enemy_ship: ShipData) -> Array[RoomInstance]
  - calculate_cumulative_value(immediate: float, cascading: float) -> float
  - should_use_prediction(combat_state: CombatState) -> bool
- Returns PredictiveResult: {final_target: room_id, reasoning: String, cascading_value: float}

**New File: `scripts/ai/PredictiveResult.gd`**
- Data class holding predictive evaluation results
- Properties:
  - final_target_id: int
  - predictive_override: bool (true if switched from primary)
  - immediate_value: float
  - cascading_value: float
  - cumulative_value: float
  - affected_rooms: Array[int] (rooms that lose power)
  - reasoning: String (for combat log)

**New File: `scripts/ai/SimulationResult.gd`**
- Data class representing simulated combat state after room destruction
- Properties:
  - destroyed_room_id: int
  - rooms_unpowered: Array[int]
  - enemy_damage_output: int (recalculated)
  - enemy_defense: int (recalculated)
  - enemy_initiative: int (recalculated)

**Modified: `scripts/combat/Combat.gd`**
- After primary target selected (F-AI-006), call PredictivePlanning.evaluate_prediction()
- If predictive_override == true: use predictive target instead of primary
- Pass PredictiveResult.reasoning to combat log

**Modified: `scripts/ui/CombatLog.gd`**
- Enhanced target selection entry to include predictive reasoning
- Format: "[Turn N] [Actor]: Targeting [Room] [Grid] - Predictive: [Cascading effect description]"

### Data Structures

```gdscript
class_name PredictiveResult

var final_target_id: int
var predictive_override: bool  # True if overrode primary target

# Value breakdown
var immediate_value: float
var cascading_value: float
var cumulative_value: float

# Cascading effects
var rooms_unpowered: Array[int] = []
var damage_reduction: int = 0
var defense_reduction: int = 0

# Reasoning
var reasoning: String

func to_string() -> String:
    if predictive_override:
        return "Predictive override: Target %d (Cumulative value: %0.1f, unpowers %d rooms)" % [
            final_target_id, cumulative_value, rooms_unpowered.size()
        ]
    else:
        return "Primary target confirmed: %d (No predictive advantage)" % final_target_id
```

### Integration Points

**Connects to:**
- TargetScoring (F-AI-006): Primary and alternative target inputs
- ThreatMap (F-AI-005): Recalculated after simulation
- ShipData: Power grid traversal, room states
- Combat log (F-AI-004): Predictive reasoning entries
- CombatState (F-AI-002): Check if prediction should run

**Emits signals:**
None (pure function)

**Listens for:**
None

**Modifies:**
- May override primary target from F-AI-006 (substitutes predictive target)

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
# Predictive planning settings
const PREDICTIVE_OVERRIDE_THRESHOLD = 0.2  # 20% better value needed
const PREDICTIVE_TURN_LOOKAHEAD = 2  # Max turns to simulate
const PREDICTIVE_NEXT_TURN_DISCOUNT = 0.8  # Discount future value by 20%

# Cascading value weights
const PREDICTIVE_DAMAGE_REDUCTION_WEIGHT = 1.0
const PREDICTIVE_DEFENSE_REDUCTION_WEIGHT = 0.5
const PREDICTIVE_INITIATIVE_WEIGHT = 10.0

# Predictive constraints
const PREDICTIVE_MIN_CASCADING_VALUE = 20.0  # Min value to consider override
const PREDICTIVE_MAX_ALTERNATIVE_TARGETS = 3  # Evaluate top 3 alternatives only
const PREDICTIVE_SKIP_LATE_GAME_TURN = 9  # Skip prediction after turn 9

# Room unpowering values
const PREDICTIVE_WEAPON_UNPOWER_VALUE = 15.0  # DPS reduction per weapon
const PREDICTIVE_SHIELD_UNPOWER_VALUE = 15.0  # Absorption reduction per shield
const PREDICTIVE_ENGINE_UNPOWER_VALUE = 10.0  # Initiative value per engine
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] PredictivePlanning.evaluate_prediction() returns PredictiveResult with final_target_id
- [ ] Reactor destruction simulation correctly identifies powered rooms
- [ ] Cascading value calculated: weapons_unpowered × 15 + shields_unpowered × 15 × 0.5 + engines × 10
- [ ] Cumulative value calculated: immediate + (cascading × 0.8)
- [ ] Predictive override occurs when alternative ≥20% better than primary
- [ ] Predictive override does NOT occur when difference <20%
- [ ] Prediction skipped when combat_phase == LATE (turn 9+)
- [ ] Prediction skipped when desperation == CRITICAL
- [ ] Multiple reactors powering same room detected (redundancy check, cascading = 0)
- [ ] Prediction evaluates top 3 alternative targets only (performance constraint)
- [ ] Predictive reasoning shown in combat log
- [ ] Prediction completes in <20ms per turn

---

## Testing Checklist

### Functional Tests
- [ ] **Reactor powering 3 weapons**: Cascading value = 45, likely overrides direct weapon target (15)
- [ ] **Reactor powering 1 armor**: Cascading value = 5, does NOT override weapon target
- [ ] **Two reactors powering same weapons**: Destroying one reactor = cascading value 0 (redundant power)
- [ ] **Turn 10 (late game)**: Prediction skipped, primary target used

### Edge Case Tests
- [ ] **Desperation = CRITICAL**: Prediction skipped, immediate weapon targeted
- [ ] **Predictive value 17% better than primary**: No override (below 20% threshold)
- [ ] **Predictive value 25% better than primary**: Override occurs
- [ ] **Tie in cumulative value (within ±10%)**: Stick with primary

### Integration Tests
- [ ] Works with TargetScoring (F-AI-006) for primary and alternatives
- [ ] Works with ThreatMap (F-AI-005) for cascading recalculation
- [ ] Works with CombatState (F-AI-002) for skip conditions
- [ ] Combat.gd successfully uses predictive target when override
- [ ] Combat log shows predictive reasoning

### Polish Tests
- [ ] Prediction causes no noticeable lag (<20ms per turn)
- [ ] Predictive AI demonstrably smarter (wins more often vs reactive AI)
- [ ] Predictive reasoning clear and understandable in combat log
- [ ] Players can learn predictive strategy from observing AI (playtester validation)

---

## Known Limitations

- **2-turn max lookahead:** Doesn't simulate deep multi-turn strategies
- **Deterministic simulation:** Assumes next turn goes exactly as planned (no enemy adaptation)
- **Single-path evaluation:** Doesn't explore multiple branching paths
- **No enemy prediction:** Doesn't anticipate enemy's predictive planning

---

## Future Enhancements

*(Not for MVP)*

- 3-turn lookahead: Simulate deeper strategies (performance intensive)
- Probabilistic simulation: Account for uncertainty in enemy actions
- Multi-path evaluation: Explore branching decision trees (minimax algorithm)
- Counter-prediction: Anticipate enemy's predictive moves and counter
- Machine learning: Train model to recognize high-value predictive opportunities

---

## Implementation Notes

**Code Reuse:**
- Power grid traversal reuses ShipData.is_room_powered() and power_grid data
- Stat recalculation reuses ShipProfileAnalyzer logic
- Threat recalculation reuses ThreatAssessment system

**Performance:**
- Limit to top 3 alternatives (don't simulate all 20+ rooms)
- Cache power grid state (don't recalculate per room)
- Skip prediction when not valuable (late game, desperation)
- Use shallow copy for simulation (don't clone entire ShipData)

**Compatibility:**
- Predictive planning is additive (enhances F-AI-006, doesn't replace)
- Can be disabled via flag for A/B testing vs reactive AI
- Prediction failures fallback gracefully to primary target

**Design Philosophy:**
- Prediction should feel *smart*, not omniscient (2-turn limit creates realism)
- Override threshold (20%) prevents overthinking every turn
- Cascading effects create "aha!" moments for players watching combat
- Predictive reasoning teaches players optimal strategies through observation

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
