# F-AI-010: Power Management AI

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 3 days
**Dependencies:** F-AI-002 (Combat State Evaluator), F-AI-003 (Basic Doctrine System)
**Phase:** 3 - Advanced Behaviors

---

## Purpose

**Why does this feature exist?**
Current power management is static (set at design time). Dynamic power management during combat allows AI to adapt: reroute power to prioritize offense when winning, defense when losing, or engines when desperate.

**What does it enable?**
AI can make tactical power decisions: "Reactor destroyed, reroute remaining power to keep weapons online, sacrifice shields." Different ships manage power crises differently based on doctrine and combat state.

**Success criteria:**
- AI correctly prioritizes power allocation based on doctrine and combat state 90%+ of the time
- Power management demonstrably improves survival in crisis scenarios (15%+ win rate improvement)
- Power decisions complete in <10ms per turn
- Players understand AI power reasoning from combat log

---

## How It Works

### Overview

When power becomes limited (reactor destroyed, power grid damaged), AI evaluates which rooms to keep powered:1. **Assess available power**: Count functional reactors and total power capacity
2. **Identify critical rooms**: Determine which rooms are essential for current strategy
3. **Prioritize allocation**: Assign power based on doctrine, combat state, and room value
4. **Execute reallocation**: Update power grid to match priorities

Priority order determined by:
- **Doctrine**: Alpha Strike prioritizes weapons, Turtle prioritizes shields
- **Combat state**: Losing prioritizes survival (defense), winning prioritizes offense
- **Room criticality**: Bridge always powered (game over if unpowered)

### User Flow
```
1. Reactor destroyed → power capacity reduced
2. PowerManagementAI.reallocate_power(ship, doctrine, combat_state) called
3. System calculates available_power vs required_power
4. If available_power < required_power: enter power crisis mode
   a. Score all rooms by criticality (doctrine + state + base value)
   b. Sort rooms by score (highest first)
   c. Allocate power to highest-scoring rooms until capacity reached
   d. Unpower lowest-scoring rooms
5. Update ship.power_grid with new allocation
6. Recalculate ship stats (weapons, shields may change)
7. Combat log: "Power crisis: Rerouted power to maintain weapons, shields unpowered"
```

### Rules & Constraints

**Power Crisis Detection:**
```
available_power = functional_reactors × 4  # Each reactor powers 4 adjacent rooms
required_power = count of powered rooms currently

if required_power > available_power:
    power_crisis = true  # Need to unpower some rooms
```

**Room Criticality Scoring:**
```
base_score = 0

# Base room values
if room.type == BRIDGE:
    base_score = 1000  # Always highest priority (game over if unpowered)
elif room.type == WEAPON:
    base_score = 50
elif room.type == SHIELD:
    base_score = 40
elif room.type == ENGINE:
    base_score = 30
elif room.type == REACTOR:
    base_score = 45  # High value (powers other rooms)
elif room.type == ARMOR:
    base_score = 10  # Passive, doesn't need power

# Doctrine modifiers
if doctrine == ALPHA_STRIKE:
    if room.type == WEAPON:
        base_score += 30
    if room.type == SHIELD:
        base_score -= 10  # Deprioritize defense
elif doctrine == DEFENSIVE_TURTLE:
    if room.type == SHIELD:
        base_score += 30
    if room.type == WEAPON:
        base_score -= 5  # Slight deprioritization

# Combat state modifiers
if combat_state.desperation == CRITICAL:
    if room.type == WEAPON:
        base_score += 20  # Need offense to survive
elif combat_state.desperation == NONE and combat_state.win_probability > 0.7:
    if room.type == SHIELD:
        base_score += 15  # Winning, preserve advantage

# Synergy modifiers (if applicable from F-AI-009)
if ship.has_synergy(WEAPONS_ARRAY) and room.type == WEAPON:
    base_score += 25  # Protect synergy
if ship.has_synergy(SHIELD_HARMONICS) and room.type == SHIELD:
    base_score += 25

criticality_score = base_score
```

**Power Allocation Algorithm:**
```
1. Calculate available_power (functional reactors × 4)
2. Get all rooms requiring power (exclude armor, destroyed rooms)
3. Score each room with criticality formula
4. Sort rooms by criticality_score (descending)
5. Allocate power:
   for room in sorted_rooms:
       if power_allocated < available_power:
           room.powered = true
           power_allocated += 1
       else:
           room.powered = false
6. Update ship stats based on new power allocation
```

**Critical Room Protection:**
- Bridge: Always powered (if no power available, game effectively over)
- Last weapon: Highly prioritized if only offensive capability
- Last shield: Highly prioritized if defense critical
- Reactors: Medium priority (can't power themselves if no other reactor)

### Edge Cases

**All reactors destroyed:**
- available_power = 0
- All rooms unpowered except Bridge (special case)
- Combat log: "Total power failure - All systems offline"

**Exactly enough power for critical rooms:**
- Allocate to highest priorities (weapons, shields)
- Engines may be sacrificed first (initiative less critical than damage/defense)

**Multiple rooms tied in criticality:**
- Use spatial priority: rooms closer to Bridge slightly favored
- Random tiebreaker if still tied (±2 points)

**Power restored mid-combat (enemy reactor destroyed, then rebuilt—not in MVP):**
- Re-run allocation with increased available_power
- Previously unpowered rooms may come back online

**Synergy breaks due to power loss:**
- Weapons Array requires 3 powered weapons
- If power crisis unpowers 1 weapon → synergy broken
- System detects and logs: "Weapons Array synergy lost due to power shortage"

---

## User Interaction

### Controls
None (automatic power management)

### Visual Feedback
- Combat log shows power crisis and allocation decisions
- Unpowered rooms visually dim (50% opacity, gray overlay)
- Thought bubbles (F-AI-013) reference power struggle: "Losing power, focusing on weapons!"

### Audio Feedback
None (optional: power failure sound effect)

---

## Visual Design

### Layout
No direct UI (visual feedback on ship grid)

### Components
- Room sprites dim when unpowered (gray overlay)
- Power lines disappear when reactors destroyed

### Visual Style
- Unpowered rooms: 50% opacity + gray ColorRect overlay (consistent with Phase 3.3)

### States
- **Normal Power:** All desired rooms powered
- **Power Crisis:** Available power < required, reallocating
- **Critical Power:** Very limited power, only essentials online

---

## Technical Implementation

### Scene Structure
```
No new scenes (logic integrated into Combat.gd)
```

### Script Responsibilities

**New File: `scripts/ai/PowerManagementAI.gd`**
- Manages dynamic power allocation during combat
- Methods:
  - reallocate_power(ship: ShipData, doctrine: Doctrine, combat_state: CombatState, synergy_strategy: SynergyStrategy) -> PowerAllocation
  - calculate_room_criticality(room: RoomInstance, doctrine: Doctrine, combat_state: CombatState, synergy_strategy: SynergyStrategy) -> float
  - detect_power_crisis(ship: ShipData) -> bool
  - get_available_power(ship: ShipData) -> int
- Returns PowerAllocation with room priorities

**New File: `scripts/ai/PowerAllocation.gd`**
- Data class representing power allocation decision
- Properties:
  - available_power: int
  - required_power: int
  - powered_rooms: Array[room_id]
  - unpowered_rooms: Array[room_id]
  - power_crisis: bool
  - reasoning: String

**Modified: `scripts/combat/Combat.gd`**
- After reactor destroyed, call PowerManagementAI.reallocate_power()
- Update ship.power_grid based on PowerAllocation
- Recalculate ship stats (active weapons, shields, engines)
- Log power crisis events

**Modified: `scripts/ui/CombatLog.gd` (F-AI-004)**
- Add power crisis entries: "Power crisis: [X] rooms require power, only [Y] available"
- Add reallocation entries: "Prioritizing weapons, shields unpowered"

### Data Structures

```gdscript
class_name PowerAllocation

var available_power: int
var required_power: int
var power_crisis: bool

var room_priorities: Array = []  # {room_id: int, criticality: float}
var powered_rooms: Array[int] = []
var unpowered_rooms: Array[int] = []

var reasoning: String  # For combat log

func to_string() -> String:
    if power_crisis:
        return "Power crisis: %d/%d capacity. Powered: %d rooms, Unpowered: %d rooms" % [
            available_power, required_power, powered_rooms.size(), unpowered_rooms.size()
        ]
    else:
        return "Normal power: %d/%d capacity, all essential rooms powered" % [
            available_power, required_power
        ]
```

### Integration Points

**Connects to:**
- Doctrine (F-AI-003): Room type priorities
- CombatState (F-AI-002): Desperation and win probability
- SynergyStrategy (F-AI-009): Synergy room protection
- ShipData: Power grid and room states
- Combat log (F-AI-004): Power crisis notifications

**Emits signals:**
- power_crisis_triggered(ship: String)
- power_reallocated(ship: String, powered: Array, unpowered: Array)

**Listens for:**
- reactor_destroyed signal

**Modifies:**
- ship.power_grid (updates which rooms are powered)

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
# Base room criticality values
const POWER_CRITICALITY_BRIDGE = 1000.0
const POWER_CRITICALITY_WEAPON = 50.0
const POWER_CRITICALITY_SHIELD = 40.0
const POWER_CRITICALITY_ENGINE = 30.0
const POWER_CRITICALITY_REACTOR = 45.0
const POWER_CRITICALITY_ARMOR = 10.0

# Doctrine modifiers
const POWER_ALPHA_STRIKE_WEAPON_BONUS = 30.0
const POWER_ALPHA_STRIKE_SHIELD_PENALTY = -10.0
const POWER_TURTLE_SHIELD_BONUS = 30.0
const POWER_TURTLE_WEAPON_PENALTY = -5.0

# Combat state modifiers
const POWER_DESPERATION_WEAPON_BONUS = 20.0
const POWER_WINNING_SHIELD_BONUS = 15.0

# Synergy protection
const POWER_SYNERGY_PROTECTION_BONUS = 25.0

# Power capacity
const POWER_REACTOR_CAPACITY = 4  # Each reactor powers 4 adjacent rooms
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] PowerManagementAI.detect_power_crisis() correctly identifies when required_power > available_power
- [ ] Room criticality scoring includes base values, doctrine modifiers, state modifiers, synergy modifiers
- [ ] Bridge always receives highest criticality (1000)
- [ ] Alpha Strike doctrine prioritizes weapons (+30), deprioritizes shields (-10)
- [ ] Defensive Turtle doctrine prioritizes shields (+30), slightly deprioritizes weapons (-5)
- [ ] Desperation = CRITICAL adds +20 to weapon criticality
- [ ] Winning (win_prob > 70%) adds +15 to shield criticality
- [ ] Power allocation algorithm powers highest-scoring rooms until capacity reached
- [ ] Unpowered rooms visually dim (50% opacity + gray overlay)
- [ ] Combat log shows power crisis and reallocation reasoning
- [ ] Ship stats recalculated after power reallocation (weapons/shields may decrease)
- [ ] Power management completes in <10ms per turn

---

## Testing Checklist

### Functional Tests
- [ ] **Reactor destroyed, 6 rooms need power, only 4 available**: Power crisis detected, 2 lowest-priority rooms unpowered
- [ ] **Alpha Strike ship, power crisis**: Weapons prioritized over shields
- [ ] **Turtle ship, power crisis**: Shields prioritized over weapons
- [ ] **Desperation = CRITICAL, power crisis**: Weapons get +20 bonus, likely stay powered

### Edge Case Tests
- [ ] **All reactors destroyed**: All rooms unpowered except Bridge
- [ ] **Exactly enough power for essentials**: Engines unpowered first, weapons/shields prioritized
- [ ] **Weapons Array synergy, power crisis**: Array weapons protected (+25 bonus)
- [ ] **Multiple rooms tied in criticality**: Spatial priority or random tiebreaker used

### Integration Tests
- [ ] Works with Doctrine (F-AI-003) for priority modifiers
- [ ] Works with CombatState (F-AI-002) for state-based priorities
- [ ] Works with SynergyStrategy (F-AI-009) for synergy protection
- [ ] Combat.gd successfully updates power_grid after reallocation
- [ ] Ship stats correctly recalculated (weapons/shields reflect new power state)

### Polish Tests
- [ ] Power management causes no noticeable lag
- [ ] AI with power management survives power crises more often than static power AI
- [ ] Combat log power crisis messages clear and understandable
- [ ] Visual feedback (dimming) clearly shows unpowered rooms

---

## Known Limitations

- **Reactive only:** Responds to power loss, doesn't predict or plan power allocation
- **Static priorities:** Room priorities fixed during power crisis (doesn't adapt mid-crisis)
- **No partial power:** Rooms are either fully powered or fully unpowered (no degraded states)
- **Single reactor radius:** Power allocation uses adjacency only (no power relay chaining)

---

## Future Enhancements

*(Not for MVP)*

- Predictive power management: Anticipate power loss and preemptively reallocate
- Dynamic priorities: Adjust room priorities each turn based on evolving situation
- Power overloading: Temporarily boost room effectiveness at risk of reactor damage
- Power relay system: Route power through intermediate rooms (multi-hop)
- Emergency power: Sacrifice rooms permanently to keep critical systems online

---

## Implementation Notes

**Code Reuse:**
- Criticality scoring similar to threat assessment (F-AI-005)
- Power grid traversal reuses ShipData methods
- Doctrine modifiers reuse F-AI-003 structures

**Performance:**
- Power reallocation only when reactor destroyed (not every turn)
- Simple sorting algorithm (O(n log n) for ~20 rooms)
- No expensive simulation required

**Compatibility:**
- Power management is additive (doesn't replace static power system)
- Works with existing power_grid structure in ShipData
- Can be disabled via flag for testing

**Design Philosophy:**
- Power management creates dramatic moments ("Everything's failing!")
- Doctrine shapes crisis response (different ships handle crises differently)
- Clear feedback helps players understand power trade-offs

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
