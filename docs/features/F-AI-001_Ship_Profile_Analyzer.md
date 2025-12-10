# F-AI-001: Ship Profile Analyzer

**Status:** 🔴 Planned
**Priority:** 🔥 Critical
**Estimated Time:** 2 days
**Dependencies:** None
**Phase:** 1 - Foundation

---

## Purpose

**Why does this feature exist?**
AI needs to understand its own ship's strengths, weaknesses, and capabilities to make intelligent combat decisions.

**What does it enable?**
AI can detect if it's playing a Glass Cannon, Turtle, Speedster, etc., and adjust its strategy accordingly. Different ship designs will produce different AI behaviors.

**Success criteria:**
- AI correctly identifies ship archetype 95%+ of the time
- AI recognizes tactical capabilities (can alpha strike, can tank, etc.)
- Profile generation completes in <10ms

---

## How It Works

### Overview

At combat start, the system analyzes both player and enemy ships to create a ShipProfile. This profile contains:
- **Archetype detection** (Glass Cannon, Turtle, Balanced, etc.)
- **Stat ratings** (offense, defense, speed, durability, efficiency from 0-100%)
- **Strengths and weaknesses** (primary/secondary strength, critical weakness)
- **Tactical capabilities** (can alpha strike, can tank, has power redundancy)
- **Synergy counts** (how many of each synergy type)

The profile is used by all other AI systems to make contextual decisions.

### User Flow
```
1. Combat begins with player/enemy ShipData
2. ShipProfileAnalyzer.analyze_ship(ship_data) called
3. System calculates stat ratings using existing ShipProfilePanel logic
4. System determines archetype based on stat thresholds
5. System identifies capabilities based on stat combinations
6. Profile stored with ship, available to all AI systems
7. Profile displayed in Doctrine UI (Phase 4)
```

### Rules & Constraints

**Stat Calculation:**
- Offense: (weapon_count × 10 / 60) × 100
- Defense: ((shields × 15) + (armor × 20) / 150) × 100
- Speed: (engine_count / 6) × 100
- Durability: ((60 + armor × 20) / 200) × 100
- Efficiency: (powered_rooms / total_rooms) × 100

**Archetype Detection Thresholds:**
- Glass Cannon: offense ≥ 70% AND defense ≤ 30%
- Turtle: defense ≥ 70% AND offense ≤ 40%
- Speedster: speed ≥ 70% AND durability ≤ 40%
- Balanced: offense 40-60% AND defense 40-60%
- Alpha Striker: offense ≥ 80% AND speed ≥ 60%
- Juggernaut: durability ≥ 70% AND speed ≤ 30%
- Incomplete: total_rooms < 5

**Capabilities:**
- can_alpha_strike = offense > 70% AND speed > 50%
- can_tank = defense > 60% AND durability > 60%
- can_outlast = efficiency > 80% AND durability > 50%
- has_power_redundancy = reactor_count ≥ 2

### Edge Cases

**Unusual builds:**
- All reactors, no weapons → Archetype.INCOMPLETE
- Exactly balanced stats (50% everything) → Archetype.BALANCED
- Multiple archetype thresholds met → Priority order: ALPHA_STRIKER > GLASS_CANNON > TURTLE > SPEEDSTER > JUGGERNAUT > BALANCED

**Damaged ships:**
- Profile recalculated if >3 rooms destroyed
- Archetype can shift mid-combat (Glass Cannon loses weapons → becomes Incomplete)

---

## User Interaction

### Controls
None (automatic analysis)

### Visual Feedback
- Profile visible in Doctrine UI panel (Phase 4)
- Combat log shows archetype on first turn
- Thought bubbles reflect archetype personality

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
- **Analyzing:** During profile generation
- **Complete:** Profile ready for AI use
- **Stale:** Needs recalculation after major damage

---

## Technical Implementation

### Scene Structure
```
No new scenes (pure data structure)
```

### Script Responsibilities

**New File: `scripts/ai/ShipProfileAnalyzer.gd`**
- Analyzes ShipData to produce ShipProfile
- Calculates stat ratings
- Detects archetype
- Identifies capabilities
- Caches synergy data

**New File: `scripts/ai/ShipProfile.gd`**
- Data class holding analysis results
- Properties: archetype, stat ratings, capabilities, synergies
- Methods: to_string() for debugging

**Modified: `scripts/combat/Combat.gd`**
- Calls ShipProfileAnalyzer on combat start
- Stores profiles with ship data
- Passes profiles to AI decision system

### Data Structures

```gdscript
class_name ShipProfile

enum Archetype {
    INCOMPLETE,
    GLASS_CANNON,
    TURTLE,
    SPEEDSTER,
    BALANCED,
    JUGGERNAUT,
    ALPHA_STRIKER,
    LAST_STAND,
    GUERRILLA
}

enum StatType {
    OFFENSE,
    DEFENSE,
    SPEED,
    DURABILITY,
    EFFICIENCY
}

var archetype: Archetype
var offense_rating: float  # 0.0-1.0
var defense_rating: float
var speed_rating: float
var durability_rating: float
var efficiency_rating: float

var primary_strength: StatType
var secondary_strength: StatType
var critical_weakness: StatType

var synergy_count: Dictionary  # {SynergyType: int}
var reactor_count: int
var weapon_count: int
var shield_count: int

var can_alpha_strike: bool
var can_tank: bool
var can_outlast: bool
var has_power_redundancy: bool
```

### Integration Points

**Connects to:**
- ShipData (analyzes)
- ShipProfilePanel (reuses stat calculation logic)
- CombatAI (consumes profile)

**Emits signals:**
None (pure function)

**Listens for:**
None

**Modifies:**
Nothing (read-only analysis)

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
const ARCHETYPE_GLASS_CANNON_OFFENSE_THRESHOLD = 0.7
const ARCHETYPE_GLASS_CANNON_DEFENSE_MAX = 0.3
const ARCHETYPE_TURTLE_DEFENSE_THRESHOLD = 0.7
const ARCHETYPE_TURTLE_OFFENSE_MAX = 0.4
# ... etc for all archetypes

const ALPHA_STRIKE_OFFENSE_MIN = 0.7
const ALPHA_STRIKE_SPEED_MIN = 0.5
# ... etc for all capabilities
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] ShipProfileAnalyzer correctly identifies Glass Cannon (offense 70%+, defense 30%-)
- [ ] ShipProfileAnalyzer correctly identifies Turtle (defense 70%+, offense 40%-)
- [ ] ShipProfileAnalyzer correctly identifies Speedster (speed 70%+, durability 40%-)
- [ ] ShipProfileAnalyzer correctly identifies Balanced (offense/defense 40-60%)
- [ ] ShipProfileAnalyzer calculates stat ratings matching ShipProfilePanel values
- [ ] Profile identifies primary/secondary strengths correctly (highest/second highest stats)
- [ ] Profile identifies critical weakness correctly (lowest stat)
- [ ] Profile detects can_alpha_strike capability (offense 70%+, speed 50%+)
- [ ] Profile detects can_tank capability (defense 60%+, durability 60%+)
- [ ] Profile synergy_count matches ship_data.calculate_synergy_bonuses()
- [ ] Profile generation completes in <10ms for typical 8x6 ship
- [ ] Combat.gd successfully creates profiles for both ships on combat start
- [ ] Profile accessible from AI decision systems

---

## Testing Checklist

### Functional Tests
- [ ] **Glass Cannon ship** (6 weapons, 0 shields, 2 engines): Archetype = GLASS_CANNON, offense ≥ 70%, can_alpha_strike = true
- [ ] **Turtle ship** (2 weapons, 5 shields, 4 armor): Archetype = TURTLE, defense ≥ 70%, can_tank = true
- [ ] **Balanced ship** (3 weapons, 3 shields, 2 engines, 2 armor): Archetype = BALANCED, all stats 40-60%
- [ ] **Empty ship** (1 bridge only): Archetype = INCOMPLETE, all stats near 0%

### Edge Case Tests
- [ ] **All reactors, no weapons**: Archetype = INCOMPLETE
- [ ] **Exactly 50% all stats**: Archetype = BALANCED
- [ ] **Multiple thresholds met** (alpha strike + glass cannon): Archetype = ALPHA_STRIKER (higher priority)

### Integration Tests
- [ ] Works with ShipData from ShipDesigner
- [ ] Works with enemy ShipData from JSON
- [ ] Doesn't break existing combat flow
- [ ] Profile accessible in Combat.gd

### Polish Tests
- [ ] Profile generation causes no noticeable lag
- [ ] to_string() produces readable debug output
- [ ] Archetypes match player expectations (playtester validation)

---

## Known Limitations

- **No partial damage tracking:** Profile only updates on room destruction, not partial damage
- **Static analysis:** Profile doesn't consider opponent's composition (that's Combat State Evaluator's job)
- **Archetype priority hardcoded:** Can't easily add new archetypes without modifying detection logic

---

## Future Enhancements

*(Not for MVP)*

- Machine learning layer: Learn optimal archetype thresholds from player data
- Per-room threat weighting: Some weapons more dangerous than others
- Enemy-aware analysis: "I'm a glass cannon vs a turtle" contextual awareness

---

## Implementation Notes

**Code Reuse:**
- Most stat calculation logic already exists in ShipProfilePanel.gd
- Extract to shared utility functions in new ShipStatsCalculator.gd
- Both ShipProfilePanel and ShipProfileAnalyzer call shared functions

**Performance:**
- Cache synergy calculation results (don't recalculate every turn)
- Only recalculate profile when ship composition changes significantly (>3 rooms)

**Compatibility:**
- Profile is additive (doesn't modify ShipData)
- Can be disabled via flag for A/B testing vs old AI

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
