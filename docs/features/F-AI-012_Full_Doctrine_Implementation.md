# F-AI-012: Full Doctrine Implementation

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 2 days
**Dependencies:** F-AI-003 (Basic Doctrine System)
**Phase:** 3 - Advanced Behaviors

---

## Purpose

**Why does this feature exist?**
Phase 1 implemented 3 core doctrines (Alpha Strike, Defensive Turtle, Adaptive Response). Full implementation adds 3 more doctrines for variety and deeper strategic matchups.

**What does it enable?**
AI exhibits 6 distinct personalities: Berserker Rush (reckless aggression), War of Attrition (patient grinding), Surgical Strike (precision targeting). More variety means more replayability and richer tactical landscape.

**Success criteria:**
- All 6 doctrines demonstrably produce different targeting patterns (70%+ unique behavior)
- Each doctrine has 30-50% win rate vs others (no dominant strategy)
- Doctrine selection matches ship archetype 90%+ of the time
- Players can identify doctrine from combat log within 2 turns

---

## How It Works

### Overview

Expands doctrine system from 3 to 6 doctrines by adding:

**4. Berserker Rush**
- **Philosophy**: Maximum aggression, ignore own damage, all-in offense
- **Target Priority**: Highest-threat targets regardless of cost
- **Aggression**: 0.9 (highest)
- **Traits**: Suicidal Charge, No Retreat, Glass Jaw (ignores own HP%)

**5. War of Attrition**
- **Philosophy**: Patient, defensive, outlast opponent through superior efficiency
- **Target Priority**: Reactors and power systems (long-term value)
- **Aggression**: 0.2 (very low)
- **Traits**: Efficiency Focus, Patience, Endurance (prioritize durability)

**6. Surgical Strike**
- **Philosophy**: Precision targeting, high-value targets only, minimal waste
- **Target Priority**: Critical rooms (Bridge, reactors), ignore low-value targets
- **Aggression**: 0.6 (moderate-high)
- **Traits**: Precision, Critical Targeting, Opportunist (exploit exposed weaknesses)

### Archetype-to-Doctrine Mapping

```
Ship Archetype → Doctrine Assignment

GLASS_CANNON → ALPHA_STRIKE (Phase 1)
ALPHA_STRIKER → ALPHA_STRIKE (Phase 1)
SPEEDSTER → BERSERKER_RUSH (new, aggressive hit-and-run)

TURTLE → DEFENSIVE_TURTLE (Phase 1)
JUGGERNAUT → WAR_OF_ATTRITION (new, slow grinding)

BALANCED → ADAPTIVE_RESPONSE (Phase 1)
INCOMPLETE → SURGICAL_STRIKE (new, precise with limited resources)
LAST_STAND → BERSERKER_RUSH (new, desperate aggression)
GUERRILLA → SURGICAL_STRIKE (new, hit critical targets and evade)
```

### Target Priority Weights (New Doctrines)

**Berserker Rush:**
- Weapons: 1.0 (destroy threats)
- Shields: 0.3 (ignore defense)
- Engines: 0.2 (irrelevant to offense)
- Reactors: 0.9 (cripple enemy power)
- Armor: 0.05 (ignore structure)

**War of Attrition:**
- Weapons: 0.6 (moderate threat priority)
- Shields: 0.3 (low priority, patient approach)
- Engines: 0.3 (not urgent)
- Reactors: 1.0 (highest priority, long-term value)
- Armor: 0.4 (moderate, chip away structure)

**Surgical Strike:**
- Weapons: 0.8 (high-value targets)
- Shields: 0.2 (low priority unless critical)
- Engines: 0.4 (moderate)
- Reactors: 1.0 (critical infrastructure)
- Armor: 0.1 (ignore unless exposed Bridge)
- **Special**: Bridge priority +50 when accessible (unique to this doctrine)

### Doctrine Traits (New)

**Berserker Rush Traits:**
1. **Suicidal Charge**: Ignore own HP% when making decisions (no defensive consideration)
2. **No Retreat**: Never switch to defensive targeting, even when losing
3. **Glass Jaw**: Vulnerable to counter-attacks, but doesn't adapt

**War of Attrition Traits:**
1. **Efficiency Focus**: Bonus priority to power-related targets (+20 to reactors)
2. **Patience**: Reduce aggression further when winning (drag out fight)
3. **Endurance**: Bonus defensive priority when HP >70% (preserve advantage)

**Surgical Strike Traits:**
1. **Precision**: Avoid overkill (strongly prefer multi-target distribution, F-AI-007)
2. **Critical Targeting**: +50 priority to Bridge when accessible
3. **Opportunist**: +30 priority to rooms <25% HP (exploit weaknesses)

---

## Rules & Constraints

**Doctrine Selection Logic** (expanded from F-AI-003):
```gdscript
func select_doctrine(ship_profile: ShipProfile) -> Doctrine:
    match ship_profile.archetype:
        ShipProfile.Archetype.GLASS_CANNON:
            return Doctrine.ALPHA_STRIKE
        ShipProfile.Archetype.ALPHA_STRIKER:
            return Doctrine.ALPHA_STRIKE
        ShipProfile.Archetype.SPEEDSTER:
            return Doctrine.BERSERKER_RUSH  # NEW
        ShipProfile.Archetype.TURTLE:
            return Doctrine.DEFENSIVE_TURTLE
        ShipProfile.Archetype.JUGGERNAUT:
            return Doctrine.WAR_OF_ATTRITION  # NEW
        ShipProfile.Archetype.BALANCED:
            return Doctrine.ADAPTIVE_RESPONSE
        ShipProfile.Archetype.INCOMPLETE:
            return Doctrine.SURGICAL_STRIKE  # NEW
        ShipProfile.Archetype.LAST_STAND:
            return Doctrine.BERSERKER_RUSH  # NEW
        ShipProfile.Archetype.GUERRILLA:
            return Doctrine.SURGICAL_STRIKE  # NEW
        _:
            return Doctrine.ADAPTIVE_RESPONSE  # Default fallback
```

**Doctrine Matchups** (rock-paper-scissors dynamics):
- Alpha Strike vs Defensive Turtle: Turtle advantage (absorbs burst, grinds down)
- Berserker Rush vs War of Attrition: Attrition advantage (outlasts reckless offense)
- Surgical Strike vs Alpha Strike: Even (both offensive, different approaches)
- Adaptive Response: Moderate vs all (balanced)

**Trait Interactions:**

**Suicidal Charge** (Berserker Rush):
- Overrides desperation modifiers (no defensive shift when losing)
- Ignores own HP% in all calculations

**Patience** (War of Attrition):
- When win_probability > 70%: reduce aggression by additional 0.2
- Result: Attrition plays ultra-conservatively when ahead

**Precision** (Surgical Strike):
- Multi-target threshold reduced from 30% overkill to 15% overkill
- More likely to split fire for efficiency

**Critical Targeting** (Surgical Strike):
- Always checks Bridge accessibility every turn
- If Bridge accessible: overrides all other priorities

---

## Edge Cases

**Archetype changes mid-combat (doctrine switch):**
- Example: Berserker Rush Speedster loses all engines → becomes INCOMPLETE
- DoctrineSelector may switch to Surgical Strike (more appropriate for weakened ship)
- System checks every 3 turns or when major damage

**Doctrine conflict with Combat State:**
- Example: Berserker Rush (ignore HP) vs Desperation (prioritize survival)
- Doctrine trait overrides state (Suicidal Charge ignores desperation)

**Multiple archetypes equally valid:**
- Example: BALANCED archetype with slight offense lean
- System defaults to Adaptive Response (safe choice)

**Doctrine counter-picks:**
- Player uses Alpha Strike, enemy assigned War of Attrition (counters aggression)
- System allows asymmetric matchups (creates strategic depth)

---

## User Interaction

### Controls
None (automatic doctrine assignment)

### Visual Feedback
- Combat log shows doctrine at combat start: "Enemy: War of Attrition doctrine - Patient and efficient"
- Doctrine UI panel (F-AI-015) displays active doctrine and traits
- Thought bubbles (F-AI-013) reflect doctrine personality

### Audio Feedback
None

---

## Visual Design

### Layout
No direct UI in Phase 3 (Doctrine UI in F-AI-015)

### Components
N/A - Backend system

### Visual Style
N/A

### States
- **Selected**: Doctrine assigned at combat start
- **Active**: Influencing decisions
- **Switched**: Doctrine changed mid-combat (rare)

---

## Technical Implementation

### Scene Structure
```
No new scenes (data structures only)
```

### Script Responsibilities

**Modified: `scripts/ai/Doctrine.gd`** (from F-AI-003)
- Add 3 new doctrine types to enum:
  - BERSERKER_RUSH
  - WAR_OF_ATTRITION
  - SURGICAL_STRIKE
- Add 9 new doctrine traits to enum (3 per new doctrine)
- Define target_weights for new doctrines
- Define aggression levels for new doctrines

**Modified: `scripts/ai/DoctrineSelector.gd`** (from F-AI-003)
- Update select_doctrine() with new archetype mappings
- Add trait configuration for new doctrines

**Modified: `scripts/ai/TargetScoring.gd`** (F-AI-006)
- Implement new trait modifiers:
  - Suicidal Charge: Ignore our_ship.health_percent in calculations
  - Patience: Reduce aggression when winning
  - Precision: Adjust multi-target threshold to 15%
  - Critical Targeting: Add +50 to Bridge when accessible
  - Opportunist: Add +30 to rooms <25% HP

**Modified: `scripts/ui/CombatLog.gd`** (F-AI-004)
- Add display names and descriptions for 3 new doctrines

### Data Structures

```gdscript
# Extended from F-AI-003
enum DoctrineType {
    ALPHA_STRIKE,
    DEFENSIVE_TURTLE,
    ADAPTIVE_RESPONSE,
    BERSERKER_RUSH,      # NEW
    WAR_OF_ATTRITION,    # NEW
    SURGICAL_STRIKE      # NEW
}

enum DoctrineTrait {
    # ... existing traits ...

    # Berserker Rush traits
    SUICIDAL_CHARGE,
    NO_RETREAT,
    GLASS_JAW,

    # War of Attrition traits
    EFFICIENCY_FOCUS,
    PATIENCE,
    ENDURANCE,

    # Surgical Strike traits
    PRECISION,
    CRITICAL_TARGETING,
    OPPORTUNIST
}
```

### Integration Points

**Connects to:**
- ShipProfile (F-AI-001): Archetype detection
- TargetScoring (F-AI-006): Target priorities and trait modifiers
- MultiTargetDistribution (F-AI-007): Precision trait affects overkill threshold
- Combat log (F-AI-004): Doctrine descriptions

**Emits signals:**
None (passive data)

**Listens for:**
None

**Modifies:**
- Expands existing doctrine system (additive)

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
# New doctrine aggression levels
const BERSERKER_RUSH_AGGRESSION = 0.9
const WAR_OF_ATTRITION_AGGRESSION = 0.2
const SURGICAL_STRIKE_AGGRESSION = 0.6

# Berserker Rush weights
const BERSERKER_WEAPON_WEIGHT = 1.0
const BERSERKER_REACTOR_WEIGHT = 0.9
const BERSERKER_SHIELD_WEIGHT = 0.3
const BERSERKER_ENGINE_WEIGHT = 0.2
const BERSERKER_ARMOR_WEIGHT = 0.05

# War of Attrition weights
const ATTRITION_REACTOR_WEIGHT = 1.0
const ATTRITION_WEAPON_WEIGHT = 0.6
const ATTRITION_ARMOR_WEIGHT = 0.4
const ATTRITION_SHIELD_WEIGHT = 0.3
const ATTRITION_ENGINE_WEIGHT = 0.3

# Surgical Strike weights
const SURGICAL_REACTOR_WEIGHT = 1.0
const SURGICAL_WEAPON_WEIGHT = 0.8
const SURGICAL_ENGINE_WEIGHT = 0.4
const SURGICAL_SHIELD_WEIGHT = 0.2
const SURGICAL_ARMOR_WEIGHT = 0.1

# New trait modifiers
const PATIENCE_WINNING_AGGRESSION_REDUCTION = -0.2
const PRECISION_OVERKILL_THRESHOLD = 0.15  # 15% vs normal 30%
const CRITICAL_TARGETING_BRIDGE_BONUS = 50.0
const OPPORTUNIST_DAMAGED_BONUS = 30.0
const EFFICIENCY_FOCUS_REACTOR_BONUS = 20.0
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] DoctrineSelector assigns BERSERKER_RUSH to Speedster archetype
- [ ] DoctrineSelector assigns WAR_OF_ATTRITION to Juggernaut archetype
- [ ] DoctrineSelector assigns SURGICAL_STRIKE to Incomplete/Guerrilla archetypes
- [ ] Berserker Rush has aggression = 0.9, target_weights: weapons=1.0, reactors=0.9
- [ ] War of Attrition has aggression = 0.2, target_weights: reactors=1.0, weapons=0.6
- [ ] Surgical Strike has aggression = 0.6, target_weights: reactors=1.0, weapons=0.8
- [ ] Suicidal Charge trait ignores own HP% in decision-making
- [ ] Patience trait reduces aggression by -0.2 when win_probability > 70%
- [ ] Precision trait reduces multi-target threshold to 15% overkill
- [ ] Critical Targeting trait adds +50 to Bridge when accessible
- [ ] Opportunist trait adds +30 to rooms <25% HP
- [ ] All 6 doctrines produce measurably different targeting patterns

---

## Testing Checklist

### Functional Tests
- [ ] **Speedster ship**: Doctrine = BERSERKER_RUSH, high aggression (0.9)
- [ ] **Juggernaut ship**: Doctrine = WAR_OF_ATTRITION, low aggression (0.2)
- [ ] **Incomplete ship**: Doctrine = SURGICAL_STRIKE, targets reactors and opportunistic rooms
- [ ] **Berserker Rush vs War of Attrition**: Attrition wins more often (patient vs reckless)

### Edge Case Tests
- [ ] **Berserker Rush, HP <10%, desperation = CRITICAL**: Ignores desperation, maintains aggression
- [ ] **War of Attrition, winning (70% win prob)**: Aggression drops to 0.0 (ultra-conservative)
- [ ] **Surgical Strike, Bridge accessible**: Prioritizes Bridge (+50 bonus)
- [ ] **Precision trait, 20% overkill**: Multi-target activated (threshold = 15%)

### Integration Tests
- [ ] Works with ShipProfile (F-AI-001) for archetype detection
- [ ] Works with TargetScoring (F-AI-006) for weight and trait application
- [ ] Works with MultiTargetDistribution (F-AI-007) for Precision trait
- [ ] Combat log shows new doctrine names correctly

### Polish Tests
- [ ] Each doctrine feels distinctly different when observed in combat
- [ ] No single doctrine dominates (win rates between 30-50% vs others)
- [ ] Players can identify doctrine from targeting behavior
- [ ] Doctrine variety increases replayability (playtester feedback)

---

## Known Limitations

- **Fixed doctrine count**: 6 doctrines total (no runtime doctrine creation)
- **Static traits**: Trait effects hardcoded (no dynamic trait generation)
- **Simple archetype mapping**: 1-to-1 archetype→doctrine (no blended doctrines)

---

## Future Enhancements

*(Not for MVP)*

- 12+ total doctrines for extreme variety
- Doctrine blending: Mix traits from multiple doctrines (70% Alpha Strike + 30% Turtle)
- Player-selectable doctrine: Override auto-assignment
- Doctrine evolution: AI adapts doctrine mid-combat based on effectiveness
- Custom doctrine builder: Players design doctrines for AI to use

---

## Implementation Notes

**Code Reuse:**
- Extends existing F-AI-003 structures (minimal new code)
- Trait implementation reuses F-AI-006 modifier system
- Selection logic extends DoctrineSelector cleanly

**Performance:**
- No additional performance cost (same evaluation logic, just more enum values)
- Trait checks are simple conditionals (very fast)

**Compatibility:**
- Backward compatible with F-AI-003 (existing 3 doctrines unchanged)
- New doctrines additive (doesn't break existing behavior)

**Design Philosophy:**
- 6 doctrines create rich tactical landscape (rock-paper-scissors-lizard-spock dynamics)
- Each doctrine should feel like a distinct personality
- Variety ensures no two battles feel identical
- Players discover counters through experimentation

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
