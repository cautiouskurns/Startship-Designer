# F-AI-005: Threat Assessment System

**Status:** 🔴 Planned
**Priority:** 🔥 Critical
**Estimated Time:** 3 days
**Dependencies:** F-AI-001 (Ship Profile Analyzer), F-AI-002 (Combat State Evaluator)
**Phase:** 2 - Threat Intelligence

---

## Purpose

**Why does this feature exist?**
Current AI uses simple priority (weapons first, power first, or random). Real tactical decisions require understanding *which specific room is the biggest threat right now*, not just which room type category.

**What does it enable?**
AI can identify that the enemy's last remaining reactor is more valuable than a weapon, or that a damaged shield is a better target than a full-health armor plate. Threat assessment creates intelligent, context-aware targeting.

**Success criteria:**
- AI correctly identifies highest-threat room 85%+ of the time (compared to human expert judgment)
- Threat scores correlate with actual combat impact (±15% accuracy)
- Threat recalculation completes in <10ms per turn
- AI demonstrates measurably different targeting from simple priority system

---

## How It Works

### Overview

Every turn, the system analyzes each enemy room and calculates a **threat score** (0-100) based on multiple factors:
- **Immediate threat**: How much damage can this room deal next turn?
- **Strategic value**: How critical is this room to enemy's strategy?
- **Power multiplier**: Does destroying this room disable other rooms?
- **Damage state**: Is this room already damaged (easier to finish off)?
- **Positional value**: Is this room protecting more critical rooms?

The threat scores are used by the targeting system (F-AI-006) to select optimal targets. High-threat rooms are prioritized for destruction.

### User Flow
```
1. Turn starts → AI needs to select target
2. ThreatAssessment.analyze_threats(enemy_ship, our_ship, combat_state) called
3. System iterates through all enemy rooms, calculates threat score for each
4. Threat scores adjusted by doctrine weights (F-AI-003)
5. ThreatMap returned: {room_id: threat_score}
6. Targeting system (F-AI-006) uses ThreatMap to select best target
7. Combat log shows threat reasoning: "Targeting Reactor [C3] - High threat (score: 85)"
```

### Rules & Constraints

**Threat Score Calculation (per room):**

```
base_threat = 0

1. IMMEDIATE THREAT (damage potential)
   - Weapon: +30 per weapon (direct damage threat)
   - Shield: +15 per shield (reduces our damage effectiveness)
   - Engine: +10 per engine (initiative advantage)
   - Reactor: +5 base (enables other rooms)
   - Armor: +5 base (prolongs enemy survival)

2. STRATEGIC VALUE (based on enemy ship profile)
   - If enemy is Glass Cannon archetype:
     - Weapons: +20 (core to their strategy)
     - Reactors: +25 (powering their offense)
   - If enemy is Turtle archetype:
     - Shields: +20 (core defense)
     - Reactors: +15 (keeping shields powered)
   - If enemy is Speedster:
     - Engines: +20 (core advantage)

3. POWER MULTIPLIER (cascading damage)
   - For each powered room this reactor/relay enables:
     - Reactor: +10 per powered room (up to +40 max)
   - Example: Reactor powering 4 rooms = +40 threat
   - Non-reactors: +0

4. DAMAGE STATE (finishing potential)
   - Room at 100% HP: +0
   - Room at 50% HP: +15 (damaged, easier to finish)
   - Room at 25% HP: +30 (critical, one hit away)
   - Room at 1-24% HP: +40 (finish now before it's repaired/used)

5. POSITIONAL VALUE (shielding critical rooms)
   - Adjacent to Bridge: +10 (protecting command)
   - Adjacent to multiple reactors: +15 (power hub location)
   - Edge of ship: -5 (less connected, less critical)

6. DESPERATION MODIFIER (based on CombatState)
   - If we're losing (desperation > MILD):
     - High-damage targets (weapons): +20 (need to reduce incoming damage fast)
     - Power targets (reactors): +15 (disrupt enemy advantage)
   - If we're winning (win_prob > 70%):
     - Structural targets (armor): +10 (finish them off methodically)

total_threat = clamp(base_threat + modifiers, 0, 100)
```

**Threat Score Normalization:**
- Scores scaled to 0-100 range (100 = highest priority target on battlefield)
- If all rooms score low (<30), boost highest score to 50 (ensure something targeted)
- Bridge always excluded from normal threat calculation (special targeting rules)

**Threat Recalculation Triggers:**
- Every turn start (always fresh)
- After room destroyed (threat landscape changes)
- After power grid change (reactor destroyed → connected rooms less threatening)

### Edge Cases

**All rooms equal threat:**
- Rare scenario (identical room types, same HP%)
- System adds slight randomization (±5 points) to break ties
- Fallback to spatial priority: prefer rooms closer to Bridge

**Only Bridge remains:**
- Bridge always targetable when it's the last room
- Threat score = 100 (instant-win target)

**Reactors with no powered rooms:**
- Power multiplier = +0 (reactor not providing value)
- Still has base threat (+5) and strategic value
- May be deprioritized compared to active rooms

**Heavily damaged but low-threat room:**
- Example: Armor at 10% HP
- Damage state modifier (+40) may elevate to medium priority
- Doctrine weight still applies (Alpha Strike ignores armor, might skip anyway)

**Enemy desperation (losing badly):**
- Their threat scores don't change (we assess their threat to us, not their strategy)
- But their targeting behavior changes (they assess our rooms differently)

---

## User Interaction

### Controls
None (automatic threat analysis)

### Visual Feedback
- Threat scores visible in combat log reasoning
- Target highlighting (F-AI-014) shows high-threat rooms in red
- Thought bubbles (F-AI-013) reference threat levels ("That reactor is dangerous!")

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
- **Analyzing:** During threat calculation
- **Complete:** ThreatMap ready for targeting
- **Stale:** Previous turn's ThreatMap (outdated after room destroyed)

---

## Technical Implementation

### Scene Structure
```
No new scenes (pure data structure)
```

### Script Responsibilities

**New File: `scripts/ai/ThreatAssessment.gd`**
- Analyzes enemy ship rooms and calculates threat scores
- Methods:
  - analyze_threats(enemy_ship: ShipData, our_ship: ShipData, combat_state: CombatState) -> ThreatMap
  - calculate_room_threat(room: RoomInstance, enemy_profile: ShipProfile, combat_state: CombatState) -> float
  - get_power_multiplier(room: RoomInstance, enemy_ship: ShipData) -> float
  - get_positional_value(room: RoomInstance, enemy_ship: ShipData) -> float
  - get_damage_state_modifier(room: RoomInstance) -> float
- Returns ThreatMap dictionary: {room_id: threat_score}

**New File: `scripts/ai/ThreatMap.gd`**
- Data class holding threat scores for all enemy rooms
- Properties: threats: Dictionary {room_id: float}
- Methods:
  - get_highest_threat_room() -> room_id
  - get_threat_score(room_id: int) -> float
  - get_rooms_by_threat_range(min_threat: float, max_threat: float) -> Array[room_id]
  - to_string() -> String (debugging output)

**Modified: `scripts/combat/Combat.gd`**
- Calls ThreatAssessment.analyze_threats() at turn start
- Stores ThreatMap with combat data
- Passes ThreatMap to AI targeting system (F-AI-006)
- Recalculates threat after room destroyed

### Data Structures

```gdscript
class_name ThreatMap

var threats: Dictionary = {}  # {room_id: threat_score}
var turn_calculated: int
var combat_phase: CombatState.CombatPhase

func get_highest_threat_room() -> int:
    var highest_score = 0.0
    var highest_room = -1
    for room_id in threats:
        if threats[room_id] > highest_score:
            highest_score = threats[room_id]
            highest_room = room_id
    return highest_room

func get_rooms_by_threat_descending() -> Array:
    var sorted_rooms = []
    for room_id in threats:
        sorted_rooms.append({"id": room_id, "score": threats[room_id]})
    sorted_rooms.sort_custom(func(a, b): return a.score > b.score)
    return sorted_rooms
```

### Integration Points

**Connects to:**
- ShipProfile (uses enemy archetype for strategic value)
- CombatState (uses desperation and win probability)
- ShipData (reads room HP, power grid, positions)
- Targeting AI (F-AI-006 consumes ThreatMap)
- Combat log (F-AI-004 displays threat scores)

**Emits signals:**
None (pure function)

**Listens for:**
None

**Modifies:**
Nothing (read-only analysis)

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
# Base threat values
const THREAT_WEAPON_BASE = 30.0
const THREAT_SHIELD_BASE = 15.0
const THREAT_ENGINE_BASE = 10.0
const THREAT_REACTOR_BASE = 5.0
const THREAT_ARMOR_BASE = 5.0

# Strategic value bonuses (by archetype)
const THREAT_GLASS_CANNON_WEAPON_BONUS = 20.0
const THREAT_GLASS_CANNON_REACTOR_BONUS = 25.0
const THREAT_TURTLE_SHIELD_BONUS = 20.0
const THREAT_TURTLE_REACTOR_BONUS = 15.0
const THREAT_SPEEDSTER_ENGINE_BONUS = 20.0

# Power multiplier
const THREAT_POWER_MULTIPLIER_PER_ROOM = 10.0
const THREAT_POWER_MULTIPLIER_MAX = 40.0

# Damage state modifiers
const THREAT_DAMAGE_50_PERCENT_BONUS = 15.0
const THREAT_DAMAGE_25_PERCENT_BONUS = 30.0
const THREAT_DAMAGE_CRITICAL_BONUS = 40.0

# Positional value modifiers
const THREAT_ADJACENT_BRIDGE_BONUS = 10.0
const THREAT_ADJACENT_REACTOR_BONUS = 15.0
const THREAT_EDGE_PENALTY = -5.0

# Desperation modifiers
const THREAT_LOSING_WEAPON_BONUS = 20.0
const THREAT_LOSING_REACTOR_BONUS = 15.0
const THREAT_WINNING_ARMOR_BONUS = 10.0

# Normalization
const THREAT_MIN_BASELINE = 50.0  # Boost low scores to this if all < 30
const THREAT_TIE_RANDOMIZATION = 5.0  # ±5 points for tie-breaking
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] ThreatAssessment correctly calculates base threat for each room type (weapon=30, shield=15, etc.)
- [ ] Strategic value bonus applied: Glass Cannon enemy with weapons gets +20 bonus
- [ ] Power multiplier applied: Reactor powering 4 rooms gets +40 threat bonus
- [ ] Damage state modifier applied: Room at 25% HP gets +30 threat bonus
- [ ] Positional value applied: Room adjacent to Bridge gets +10 bonus
- [ ] Desperation modifier applied: When losing, enemy weapons get +20 bonus
- [ ] Threat scores normalized to 0-100 range
- [ ] ThreatMap.get_highest_threat_room() returns room with highest score
- [ ] Threat recalculated each turn (scores reflect current state)
- [ ] Threat recalculated after room destroyed (power grid changes reflected)
- [ ] Threat calculation completes in <10ms for 8×6 ship
- [ ] Combat.gd successfully creates ThreatMap and passes to targeting AI
- [ ] Combat log displays threat scores in reasoning text

---

## Testing Checklist

### Functional Tests
- [ ] **Enemy with 3 weapons, 1 reactor**: Reactor powering all weapons gets highest threat (base + power multiplier)
- [ ] **Enemy Glass Cannon archetype**: Weapons and reactors prioritized over shields
- [ ] **Enemy Turtle archetype**: Shields prioritized over weapons
- [ ] **Room at 10% HP**: Receives +40 damage state bonus, elevated in threat ranking
- [ ] **Reactor powering 0 rooms** (isolated): Low threat (base only, no multiplier)

### Edge Case Tests
- [ ] **Only Bridge remains**: Threat score = 100, targetable
- [ ] **All rooms equal threat**: System adds randomization (±5), selects one
- [ ] **We're losing (desperation = CRITICAL)**: Enemy weapons get +20 bonus, top priority
- [ ] **We're winning (win_prob > 70%)**: Enemy armor gets +10 bonus

### Integration Tests
- [ ] Works with ShipProfile (F-AI-001) for archetype-based bonuses
- [ ] Works with CombatState (F-AI-002) for desperation modifiers
- [ ] Works with Combat.gd turn flow (threat recalculated each turn)
- [ ] Doesn't break existing combat execution

### Polish Tests
- [ ] Threat calculation causes no noticeable lag
- [ ] Threat scores correlate with human expert judgment (playtester validation)
- [ ] AI targeting demonstrably smarter than simple priority (wins more often vs same builds)
- [ ] Threat reasoning in combat log makes sense to players

---

## Known Limitations

- **Static threat model:** Doesn't predict future turns (e.g., "This weapon will fire next turn")
- **No synergy awareness:** Doesn't account for Shield Harmonics or Weapons Array synergies
- **Simple positional logic:** Only considers adjacency, not room placement strategy
- **No multi-target optimization:** Evaluates each room independently, not as combinations

---

## Future Enhancements

*(Not for MVP)*

- Predictive threat: Simulate next 2 turns to assess future threat
- Synergy-aware threat: Detect synergies and boost threat scores accordingly
- Multi-target scoring: Evaluate threat of room *combinations* (e.g., reactor + 3 weapons)
- Historical threat tracking: Learn which rooms posed greatest threat in past combats
- Threat visualization: Show threat heatmap overlay on enemy ship (debug mode)

---

## Implementation Notes

**Code Reuse:**
- Room iteration logic similar to ShipProfileAnalyzer
- Power grid traversal reuses ShipData.is_room_powered() logic
- Threat scoring can reuse stat calculation utilities

**Performance:**
- Cache powered rooms list (don't recalculate per room)
- Early exit for destroyed rooms (skip threat calculation)
- Use fast dictionary lookups instead of array iteration

**Compatibility:**
- ThreatMap is additive (doesn't replace existing targeting, augments it)
- Can be disabled via flag for A/B testing vs simple priority
- Threat scores expose tuning knobs for balance testing

**Design Philosophy:**
- Threat reflects "danger to us," not "value to enemy"
- High variance in scores creates clear prioritization (avoid all rooms ~50)
- Context-aware scoring makes AI feel intelligent, not robotic

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
