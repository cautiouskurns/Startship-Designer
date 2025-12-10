# F-AI-003: Basic Doctrine System

**Status:** 🔴 Planned
**Priority:** 🔥 Critical
**Estimated Time:** 2 days
**Dependencies:** F-AI-001 (Ship Profile Analyzer)
**Phase:** 1 - Foundation

---

## Purpose

**Why does this feature exist?**
AI needs personality and consistent behavior patterns so that different ship designs feel like they're "thinking" differently. Without doctrines, all ships would use the same decision logic regardless of their composition.

**What does it enable?**
A Glass Cannon ship plays aggressively (Alpha Strike doctrine), while a Turtle ship plays defensively (Defensive Turtle doctrine). Players can predict enemy behavior and design counters. Different doctrines create distinct combat experiences.

**Success criteria:**
- Each doctrine produces measurably different targeting behavior (>70% consistency)
- Players can identify active doctrine from combat log within 2 turns
- Doctrine selection matches ship archetype 90%+ of the time
- Doctrine switches appropriately when combat state changes dramatically

---

## How It Works

### Overview

At combat start, the system assigns a doctrine to each ship based on its ShipProfile archetype. The doctrine acts as a personality that influences all AI decisions:
- **Alpha Strike**: Maximize damage output, target offense first, ignore defense
- **Defensive Turtle**: Survive at all costs, target enemy offense to reduce incoming damage
- **Adaptive Response**: Balanced approach, adjusts based on combat state

Each doctrine has:
- **Target priority weights** (what room types to focus on)
- **Aggression level** (willingness to take risks)
- **Doctrine traits** (specific behavioral modifiers)

The doctrine is passed to all AI decision systems to contextualize their choices.

### User Flow
```
1. Combat begins with both ships analyzed (F-AI-001)
2. DoctrineSelector.select_doctrine(ship_profile) called for each ship
3. System matches archetype to appropriate doctrine
4. Doctrine stored with ship data, accessible to AI systems
5. Each turn, AI references doctrine for target selection
6. If combat state shifts dramatically (F-AI-002), doctrine may switch
7. Combat log shows doctrine-influenced reasoning ("Turtle: Targeting weapons to reduce threat")
```

### Rules & Constraints

**Doctrine Selection Logic:**
```
Ship Archetype → Default Doctrine

GLASS_CANNON → ALPHA_STRIKE
ALPHA_STRIKER → ALPHA_STRIKE
SPEEDSTER → ALPHA_STRIKE (hit first, hit hard)

TURTLE → DEFENSIVE_TURTLE
JUGGERNAUT → DEFENSIVE_TURTLE

BALANCED → ADAPTIVE_RESPONSE
INCOMPLETE → ADAPTIVE_RESPONSE (cautious, neutral strategy)
LAST_STAND → ADAPTIVE_RESPONSE (will switch based on desperation)
GUERRILLA → ADAPTIVE_RESPONSE (will switch based on momentum)
```

**Target Priority Weights:**

**Alpha Strike Doctrine:**
- Enemy weapons: 100% priority (destroy their offense)
- Enemy shields: 50% priority (reduce their defense slightly)
- Enemy engines: 30% priority (speed less important)
- Enemy reactors: 70% priority (power disruption valuable)
- Enemy armor: 10% priority (ignore structural targets)

**Defensive Turtle Doctrine:**
- Enemy weapons: 100% priority (eliminate threats first)
- Enemy shields: 10% priority (ignore their defense)
- Enemy engines: 20% priority (speed not a threat)
- Enemy reactors: 60% priority (disrupt enemy power)
- Enemy armor: 5% priority (ignore structure)

**Adaptive Response Doctrine:**
- Enemy weapons: 70% priority (balanced threat assessment)
- Enemy shields: 40% priority (moderate priority)
- Enemy engines: 40% priority (moderate priority)
- Enemy reactors: 80% priority (power is universal weakness)
- Enemy armor: 30% priority (structural damage helpful)

**Aggression Levels:**
- Alpha Strike: 0.8 (high risk tolerance, prefers all-in attacks)
- Defensive Turtle: 0.3 (low risk tolerance, conservative)
- Adaptive Response: 0.5 (moderate, adjusts based on combat state)

**Doctrine Traits:**

**Alpha Strike:**
- "Glass Cannon Thinking": Ignore own HP percentage, always maximize damage
- "First Strike Advantage": Bonus weight if ship has initiative
- "No Quarter": Prefers finishing off damaged rooms over spreading damage

**Defensive Turtle:**
- "Survival Instinct": Heavily weight enemy weapons when own HP < 50%
- "Threat Reduction": Prefer targets that deal most damage per turn
- "Hunker Down": Bonus defensive considerations if losing

**Adaptive Response:**
- "State Aware": Adjust aggression based on CombatState (F-AI-002)
  - If winning: reduce aggression to 0.4 (play safe)
  - If losing: increase aggression to 0.6 (take risks)
- "Balanced Targeting": Spread damage across room types instead of focusing
- "Momentum Rider": If gaining momentum, maintain current strategy; if losing, switch emphasis

### Edge Cases

**Archetype changes mid-combat:**
- Glass Cannon loses all weapons → becomes INCOMPLETE archetype
- Doctrine re-evaluated: should switch to DEFENSIVE_TURTLE (survive with remaining HP)
- System checks archetype every 3 turns or when >3 rooms destroyed

**Multiple doctrines equally valid:**
- BALANCED archetype could use any doctrine
- System uses secondary factors: current HP percentage, enemy archetype
- Default to ADAPTIVE_RESPONSE for ambiguity

**Doctrine conflict with ship state:**
- Alpha Strike doctrine but ship has 20% HP left
- Doctrine traits still apply (Glass Cannon Thinking ignores HP)
- This creates emergent "suicidal aggression" behavior (intentional, creates drama)

**Enemy counters player doctrine:**
- Player uses Alpha Strike, enemy uses Defensive Turtle (targets player's weapons)
- System allows this asymmetry (creates interesting matchups)
- Post-battle analysis (F-AI-016) can highlight doctrine counters

---

## User Interaction

### Controls
None (automatic doctrine selection)

### Visual Feedback
- Combat log shows doctrine name on first turn ("Enemy: Defensive Turtle doctrine active")
- Doctrine UI panel (Phase 4, F-AI-015) displays active doctrine and traits
- Thought bubbles (Phase 4, F-AI-013) reflect doctrine personality

### Audio Feedback
None

---

## Visual Design

### Layout
No direct UI in Phase 1 (data structure only)

### Components
N/A - Backend system

### Visual Style
N/A

### States
- **Selected:** Doctrine assigned at combat start
- **Active:** Doctrine influencing decisions each turn
- **Switched:** Doctrine changed mid-combat due to state shift

---

## Technical Implementation

### Scene Structure
```
No new scenes (pure data structure)
```

### Script Responsibilities

**New File: `scripts/ai/Doctrine.gd`**
- Enum for doctrine types (ALPHA_STRIKE, DEFENSIVE_TURTLE, ADAPTIVE_RESPONSE)
- Data class holding doctrine configuration
- Properties: doctrine_type, target_weights{}, aggression_level, trait_flags{}
- Methods: get_target_weight(room_type), get_aggression_modifier(combat_state)

**New File: `scripts/ai/DoctrineSelector.gd`**
- Selects appropriate doctrine based on ShipProfile archetype
- Handles doctrine switching when archetype changes mid-combat
- Methods: select_doctrine(ship_profile), should_switch_doctrine(ship_profile, current_doctrine)

**Modified: `scripts/combat/Combat.gd`**
- Calls DoctrineSelector during combat initialization
- Stores doctrine with ship data
- Passes doctrine to AI decision systems each turn
- Checks for doctrine switches every 3 turns

### Data Structures

```gdscript
class_name Doctrine

enum DoctrineType {
    ALPHA_STRIKE,       # High aggression, offensive focus
    DEFENSIVE_TURTLE,   # Low aggression, survival focus
    ADAPTIVE_RESPONSE   # Moderate aggression, state-aware
}

enum DoctrineTrait {
    # Alpha Strike traits
    GLASS_CANNON_THINKING,
    FIRST_STRIKE_ADVANTAGE,
    NO_QUARTER,

    # Defensive Turtle traits
    SURVIVAL_INSTINCT,
    THREAT_REDUCTION,
    HUNKER_DOWN,

    # Adaptive traits
    STATE_AWARE,
    BALANCED_TARGETING,
    MOMENTUM_RIDER
}

var doctrine_type: DoctrineType
var aggression_level: float  # 0.0-1.0

# Target priority weights by room type
var target_weights: Dictionary = {
    RoomData.RoomType.WEAPON: 1.0,
    RoomData.RoomType.SHIELD: 0.5,
    RoomData.RoomType.ENGINE: 0.3,
    RoomData.RoomType.REACTOR: 0.7,
    RoomData.RoomType.ARMOR: 0.1
}

# Active traits for this doctrine
var traits: Array[DoctrineTrait] = []

# Descriptive text for UI/logs
var display_name: String
var description: String
```

### Integration Points

**Connects to:**
- ShipProfile (uses archetype for selection)
- CombatState (Adaptive Response adjusts based on state)
- Targeting AI (provides priority weights)
- Combat log (provides reasoning text)

**Emits signals:**
- doctrine_switched(old_doctrine, new_doctrine) - when doctrine changes mid-combat

**Listens for:**
- None (passive data structure)

**Modifies:**
- Nothing (read-only influence on AI)

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
# Doctrine aggression levels
const ALPHA_STRIKE_AGGRESSION = 0.8
const DEFENSIVE_TURTLE_AGGRESSION = 0.3
const ADAPTIVE_RESPONSE_AGGRESSION = 0.5

# Target priority weights - Alpha Strike
const ALPHA_WEAPON_WEIGHT = 1.0
const ALPHA_SHIELD_WEIGHT = 0.5
const ALPHA_ENGINE_WEIGHT = 0.3
const ALPHA_REACTOR_WEIGHT = 0.7
const ALPHA_ARMOR_WEIGHT = 0.1

# Target priority weights - Defensive Turtle
const TURTLE_WEAPON_WEIGHT = 1.0
const TURTLE_SHIELD_WEIGHT = 0.1
const TURTLE_ENGINE_WEIGHT = 0.2
const TURTLE_REACTOR_WEIGHT = 0.6
const TURTLE_ARMOR_WEIGHT = 0.05

# Target priority weights - Adaptive Response
const ADAPTIVE_WEAPON_WEIGHT = 0.7
const ADAPTIVE_SHIELD_WEIGHT = 0.4
const ADAPTIVE_ENGINE_WEIGHT = 0.4
const ADAPTIVE_REACTOR_WEIGHT = 0.8
const ADAPTIVE_ARMOR_WEIGHT = 0.3

# Doctrine switching thresholds
const ARCHETYPE_RECHECK_TURN_INTERVAL = 3  # Check every 3 turns
const ARCHETYPE_RECHECK_ROOM_THRESHOLD = 3  # Or when 3+ rooms destroyed

# Adaptive Response state modifiers
const ADAPTIVE_WINNING_AGGRESSION = 0.4  # Reduce aggression when winning
const ADAPTIVE_LOSING_AGGRESSION = 0.6   # Increase aggression when losing
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] DoctrineSelector correctly assigns ALPHA_STRIKE to GLASS_CANNON archetype
- [ ] DoctrineSelector correctly assigns DEFENSIVE_TURTLE to TURTLE archetype
- [ ] DoctrineSelector correctly assigns ADAPTIVE_RESPONSE to BALANCED archetype
- [ ] Alpha Strike doctrine has target_weights: weapons=1.0, reactors=0.7, shields=0.5
- [ ] Defensive Turtle doctrine has target_weights: weapons=1.0, reactors=0.6, shields=0.1
- [ ] Adaptive Response doctrine has aggression_level=0.5
- [ ] Alpha Strike doctrine includes GLASS_CANNON_THINKING trait
- [ ] Defensive Turtle doctrine includes SURVIVAL_INSTINCT trait
- [ ] Adaptive Response doctrine adjusts aggression based on CombatState (winning → 0.4, losing → 0.6)
- [ ] Doctrine accessible from Combat.gd for AI decision systems
- [ ] Doctrine switching detected when archetype changes mid-combat
- [ ] Combat log receives doctrine display_name for reasoning text
- [ ] Doctrine selection completes in <5ms

---

## Testing Checklist

### Functional Tests
- [ ] **Glass Cannon ship (6 weapons, 0 shields)**: Doctrine = ALPHA_STRIKE, aggression = 0.8
- [ ] **Turtle ship (2 weapons, 5 shields)**: Doctrine = DEFENSIVE_TURTLE, aggression = 0.3
- [ ] **Balanced ship (3 weapons, 3 shields)**: Doctrine = ADAPTIVE_RESPONSE, aggression = 0.5
- [ ] **Alpha Strike doctrine targeting**: Prefers enemy weapons and reactors over shields and armor

### Edge Case Tests
- [ ] **Glass Cannon loses all weapons mid-combat**: Archetype recalculated → switches to DEFENSIVE_TURTLE
- [ ] **Adaptive Response when winning**: Aggression drops to 0.4
- [ ] **Adaptive Response when losing**: Aggression rises to 0.6
- [ ] **Incomplete ship (<5 rooms)**: Doctrine = ADAPTIVE_RESPONSE (safe default)

### Integration Tests
- [ ] Works with ShipProfile from F-AI-001
- [ ] Works with CombatState from F-AI-002 for Adaptive aggression adjustment
- [ ] Doctrine accessible in Combat.gd
- [ ] Doesn't break existing combat flow

### Polish Tests
- [ ] Doctrine selection causes no noticeable lag
- [ ] Display names readable and descriptive ("Alpha Strike", "Defensive Turtle", "Adaptive Response")
- [ ] Traits clearly influence behavior (Glass Cannon Thinking ignores own HP)

---

## Known Limitations

- **Only 3 doctrines:** Limited variety in Phase 1 (Phase 3 adds 3 more via F-AI-012)
- **Simple switching logic:** Only checks archetype changes, not tactical situations
- **Static trait effects:** Traits are boolean flags, not parameterized behaviors
- **No doctrine learning:** AI doesn't adapt doctrine choices based on success/failure

---

## Future Enhancements

*(Not for MVP)*

- 6 total doctrines (F-AI-012): Add Berserker Rush, War of Attrition, Surgical Strike
- Doctrine reputation system: Track which doctrines work best against which archetypes
- Player-selectable doctrine: Let player choose their own ship's doctrine (override auto-select)
- Doctrine blending: Mix traits from multiple doctrines (e.g., 70% Alpha Strike + 30% Turtle)
- Dynamic trait activation: Traits trigger based on combat events, not always active

---

## Implementation Notes

**Code Reuse:**
- Doctrine selection logic similar to archetype detection (threshold-based)
- Target weight dictionaries easily extendable for new doctrines

**Performance:**
- Doctrine selected once at combat start (cached, not recalculated each turn)
- Archetype recheck only every 3 turns or major damage events
- No expensive calculations (simple dictionary lookups)

**Compatibility:**
- Doctrine is additive (doesn't replace existing AI, just influences it)
- Can be disabled via flag for A/B testing
- Target weights expose tuning knobs for balance testing

**Design Philosophy:**
- Doctrines should feel like "personalities," not just stat modifiers
- Player should be able to predict doctrine from ship design
- Doctrine creates asymmetric matchups (rock-paper-scissors potential)

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
