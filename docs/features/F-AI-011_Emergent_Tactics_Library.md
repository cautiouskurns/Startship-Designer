# F-AI-011: Emergent Tactics Library

**Status:** 🔴 Planned
**Priority:** ➡️ Medium
**Estimated Time:** 3 days
**Dependencies:** F-AI-005 (Threat Assessment), F-AI-008 (Predictive Planning)
**Phase:** 3 - Advanced Behaviors

---

## Purpose

**Why does this feature exist?**
AI combining all previous systems can discover emergent tactics organically, but codifying common tactics makes them repeatable and teachable. A tactics library recognizes when specific opportunities arise and executes proven strategies.

**What does it enable?**
AI identifies tactical opportunities: "Focus Fire" (multiple weapons on weakened target), "Power Strangle" (destroy all reactors to cripple enemy), "Surgical Strike" (target Bridge when exposed). Different situations trigger different tactics.

**Success criteria:**
- AI correctly identifies tactical opportunities 80%+ of the time when conditions met
- Tactics demonstrably improve win rate (10%+ vs non-tactical AI)
- Tactic detection completes in <5ms per turn
- Players recognize and name tactics from combat log descriptions

---

## How It Works

### Overview

The Tactics Library contains 8 tactical patterns with specific trigger conditions:

1. **Focus Fire**: Multi-weapon focus on weakened target (finish it off)
2. **Power Strangle**: Destroy all enemy reactors to collapse power grid
3. **Surgical Strike**: Target exposed Bridge for instant win
4. **Alpha Strike Opening**: All-out offense on first turn (capitalize on initiative)
5. **Defensive Withdrawal**: Prioritize defense when critically damaged
6. **Momentum Push**: Exploit gaining momentum with aggressive targeting
7. **Desperation Gambit**: All-in on high-value target when losing badly
8. **Synergy Break**: Prioritize breaking specific enemy synergy

Each turn, the system checks if any tactic conditions are met. If yes, tactic overrides normal targeting with specialized behavior.

### User Flow
```
1. Turn starts → Normal targeting selected (F-AI-006)
2. EmergentTactics.evaluate_opportunities(ship_state, threat_map, combat_state) called
3. System checks each tactic's trigger conditions
4. If tactic triggered:
   a. Execute tactic-specific targeting logic
   b. Override normal target selection
   c. Log tactic activation: "Tactic: Focus Fire on damaged Reactor [C3]"
5. If no tactic: proceed with normal targeting
```

### Rules & Constraints

**Tactic Definitions:**

**1. Focus Fire**
- **Trigger**: Enemy room at <30% HP AND we have 3+ weapons
- **Behavior**: All weapons target that room (guaranteed destruction)
- **Value**: Eliminate high-threat room efficiently, no overkill waste

**2. Power Strangle**
- **Trigger**: Enemy has ≤2 functional reactors AND destroying them unpowers 50%+ of their rooms
- **Behavior**: Prioritize all reactors, ignore other targets
- **Value**: Total power collapse cripples enemy offensive/defensive capability

**3. Surgical Strike**
- **Trigger**: Enemy Bridge accessible (no rooms shielding it) AND we can deal 60+ damage
- **Behavior**: All weapons target Bridge (instant win)
- **Value**: Immediate victory, bypasses attrition combat

**4. Alpha Strike Opening**
- **Trigger**: Turn 1 AND we have initiative AND 4+ weapons
- **Behavior**: Target highest-threat enemy room with overwhelming force
- **Value**: Cripple enemy immediately, set favorable tempo

**5. Defensive Withdrawal**
- **Trigger**: Our HP <25% AND enemy has higher DPS
- **Behavior**: Prioritize enemy weapons exclusively (reduce incoming damage)
- **Value**: Survival priority overrides doctrine

**6. Momentum Push**
- **Trigger**: combat_state.momentum == GAINING AND win_probability > 60%
- **Behavior**: Increase aggression +0.2, target structural/finishing targets
- **Value**: Close out fight quickly, don't let enemy recover

**7. Desperation Gambit**
- **Trigger**: combat_state.desperation == CRITICAL
- **Behavior**: Target single highest-value target (reactor or weapon) with all weapons
- **Value**: Last-ditch effort to swing combat, high risk/high reward

**8. Synergy Break**
- **Trigger**: Enemy has active synergy (Weapons Array, Shield Harmonics) at threshold (exactly 3 rooms)
- **Behavior**: Target synergy rooms with +50 priority (break synergy immediately)
- **Value**: Disrupt enemy's core advantage

**Tactic Priority Hierarchy** (if multiple tactics trigger):
1. Surgical Strike (instant win)
2. Desperation Gambit (survival)
3. Defensive Withdrawal (survival)
4. Power Strangle (crippling advantage)
5. Synergy Break (strategic advantage)
6. Focus Fire (efficiency)
7. Momentum Push (closing)
8. Alpha Strike Opening (first turn only)

Only one tactic active per turn (highest priority wins).

### Edge Cases

**Multiple tactics eligible:**
- Use hierarchy (Surgical Strike > Desperation > Defensive, etc.)
- Example: Desperation + Focus Fire both trigger → Desperation takes priority

**Tactic conditions change mid-turn:**
- Tactics evaluated at turn start only (not re-evaluated after damage dealt)
- Next turn will re-evaluate with new conditions

**Tactic conflicts with doctrine:**
- Example: Turtle doctrine deprioritizes offense, but Desperation Gambit forces aggression
- Tactic overrides doctrine (situational tactics trump strategy)

**Tactic requires resources we don't have:**
- Example: Focus Fire requires 3+ weapons, we only have 2
- Tactic doesn't trigger (condition fails)

**Surgical Strike impossible (Bridge shielded):**
- Tactic doesn't trigger
- May trigger in later turns if shielding rooms destroyed

**Tactic succeeds/fails:**
- Success: Enemy room destroyed as planned, log: "Focus Fire successful - Reactor destroyed"
- Failure: Room survives (insufficient damage), log: "Focus Fire incomplete - Target weakened"

---

## User Interaction

### Controls
None (automatic tactic detection)

### Visual Feedback
- Combat log shows tactic activation: "**TACTIC: Focus Fire** - Concentrating all weapons on damaged Reactor [C3]"
- Thought bubbles (F-AI-013) reflect tactical thinking: "Time to finish them off!"
- Target highlighting (F-AI-014) may show special emphasis for tactical targets

### Audio Feedback
None (optional: tactical alert sound effect)

---

## Visual Design

### Layout
No direct UI (combat log only)

### Components
N/A - Backend system

### Visual Style
- Tactic names in **bold** in combat log for emphasis

### States
- **Scanning:** Checking tactic conditions
- **Activated:** Tactic triggered, overriding normal targeting
- **Inactive:** No tactics applicable this turn

---

## Technical Implementation

### Scene Structure
```
No new scenes (pure logic)
```

### Script Responsibilities

**New File: `scripts/ai/EmergentTactics.gd`**
- Detects tactical opportunities and executes tactics
- Methods:
  - evaluate_opportunities(our_ship: ShipData, enemy_ship: ShipData, threat_map: ThreatMap, combat_state: CombatState) -> TacticalAction
  - check_focus_fire(...) -> bool
  - check_power_strangle(...) -> bool
  - check_surgical_strike(...) -> bool
  - check_alpha_strike_opening(...) -> bool
  - check_defensive_withdrawal(...) -> bool
  - check_momentum_push(...) -> bool
  - check_desperation_gambit(...) -> bool
  - check_synergy_break(...) -> bool
  - execute_tactic(tactic_type: TacticType, ...) -> target_id
- Returns TacticalAction with tactic type and target

**New File: `scripts/ai/TacticalAction.gd`**
- Data class representing activated tactic
- Properties:
  - tactic_type: TacticType (enum)
  - target_id: int (or array for multi-target)
  - active: bool (true if tactic triggered)
  - reasoning: String
- Methods: to_string() → tactic summary

**Modified: `scripts/combat/Combat.gd`**
- Before normal targeting (F-AI-006), call EmergentTactics.evaluate_opportunities()
- If tactic.active == true: use tactic.target_id instead of normal target
- Log tactic activation prominently

**Modified: `scripts/ui/CombatLog.gd` (F-AI-004)**
- Add tactic activation entries with bold formatting
- Format: "[Turn N] **TACTIC: [Name]** - [Description and reasoning]"

### Data Structures

```gdscript
class_name TacticalAction

enum TacticType {
    NONE,
    FOCUS_FIRE,
    POWER_STRANGLE,
    SURGICAL_STRIKE,
    ALPHA_STRIKE_OPENING,
    DEFENSIVE_WITHDRAWAL,
    MOMENTUM_PUSH,
    DESPERATION_GAMBIT,
    SYNERGY_BREAK
}

var tactic_type: TacticType = TacticType.NONE
var active: bool = false

var target_id: int = -1  # Primary target (or -1 if multi-target)
var target_ids: Array[int] = []  # For multi-target tactics

var reasoning: String

func is_active() -> bool:
    return active and tactic_type != TacticType.NONE
```

### Integration Points

**Connects to:**
- ThreatMap (F-AI-005): Room threat scores
- CombatState (F-AI-002): Momentum, desperation, win probability
- PredictivePlanning (F-AI-008): Cascading effects for Power Strangle
- TargetScoring (F-AI-006): Overrides normal targeting
- Combat log (F-AI-004): Tactic activation entries

**Emits signals:**
- tactic_activated(ship: String, tactic_type: TacticType)
- tactic_completed(ship: String, tactic_type: TacticType, success: bool)

**Listens for:**
None

**Modifies:**
- Overrides target selection when tactic active

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
# Focus Fire thresholds
const TACTIC_FOCUS_FIRE_HP_THRESHOLD = 0.3  # <30% HP
const TACTIC_FOCUS_FIRE_MIN_WEAPONS = 3

# Power Strangle thresholds
const TACTIC_POWER_STRANGLE_MAX_REACTORS = 2
const TACTIC_POWER_STRANGLE_UNPOWER_PERCENTAGE = 0.5  # 50%+ rooms unpowered

# Surgical Strike thresholds
const TACTIC_SURGICAL_STRIKE_MIN_DAMAGE = 60  # Need enough damage to destroy Bridge

# Alpha Strike Opening thresholds
const TACTIC_ALPHA_STRIKE_MIN_WEAPONS = 4

# Defensive Withdrawal thresholds
const TACTIC_DEFENSIVE_HP_THRESHOLD = 0.25  # <25% HP

# Momentum Push thresholds
const TACTIC_MOMENTUM_PUSH_WIN_PROB_MIN = 0.6  # >60% win chance

# Synergy Break thresholds
const TACTIC_SYNERGY_BREAK_ROOM_THRESHOLD = 3  # Synergy at exactly threshold (about to break)
const TACTIC_SYNERGY_BREAK_PRIORITY_BONUS = 50.0
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] EmergentTactics correctly detects Focus Fire opportunity (enemy room <30% HP, we have 3+ weapons)
- [ ] EmergentTactics correctly detects Power Strangle opportunity (≤2 enemy reactors, 50%+ rooms would unpower)
- [ ] EmergentTactics correctly detects Surgical Strike opportunity (Bridge accessible, 60+ damage available)
- [ ] EmergentTactics correctly detects Desperation Gambit (combat_state.desperation == CRITICAL)
- [ ] Tactic priority hierarchy enforced (Surgical Strike > Desperation > Defensive > others)
- [ ] Only one tactic active per turn (highest priority wins if multiple eligible)
- [ ] Tactic overrides normal targeting (tactic.target_id used instead of F-AI-006 result)
- [ ] Combat log shows tactic activation with **bold** formatting
- [ ] Tactic detection completes in <5ms per turn

---

## Testing Checklist

### Functional Tests
- [ ] **Enemy Reactor at 25% HP, we have 4 weapons**: Focus Fire triggers, all weapons target reactor
- [ ] **Enemy has 2 reactors, destroying both unpowers 60% rooms**: Power Strangle triggers
- [ ] **Enemy Bridge exposed, we have 6 weapons (90 damage)**: Surgical Strike triggers
- [ ] **Desperation = CRITICAL**: Desperation Gambit triggers, targets highest-value room

### Edge Case Tests
- [ ] **Focus Fire + Desperation both eligible**: Desperation takes priority (higher in hierarchy)
- [ ] **Surgical Strike eligible**: Overrides all other tactics (highest priority)
- [ ] **Turn 1, 5 weapons, have initiative**: Alpha Strike Opening triggers
- [ ] **No tactics eligible**: Returns TacticType.NONE, normal targeting proceeds

### Integration Tests
- [ ] Works with ThreatMap (F-AI-005) for target identification
- [ ] Works with CombatState (F-AI-002) for trigger conditions
- [ ] Overrides TargetScoring (F-AI-006) when active
- [ ] Combat log shows tactic entries correctly

### Polish Tests
- [ ] Tactic detection causes no noticeable lag
- [ ] Tactical AI wins more often than non-tactical AI (A/B testing)
- [ ] Tactic names and descriptions clear and memorable
- [ ] Players learn to recognize tactics from observing AI

---

## Known Limitations

- **Fixed tactics:** 8 predefined tactics, no dynamic tactic generation
- **Single-tactic limit:** Only one tactic per turn (can't combine tactics)
- **Binary activation:** Tactics either on or off (no partial/graduated tactics)
- **No tactic chaining:** Doesn't plan multi-turn tactic sequences

---

## Future Enhancements

*(Not for MVP)*

- Dynamic tactic generation: AI discovers new tactics during gameplay
- Multi-tactic combos: Combine compatible tactics (Focus Fire + Momentum Push)
- Tactic sequences: Plan multi-turn tactical plays (Turn 1: Power Strangle, Turn 2: Alpha Strike)
- Player-visible tactic counter: UI shows detected tactical opportunities
- Tactic library expansion: Add 12+ additional tactics post-launch

---

## Implementation Notes

**Code Reuse:**
- Trigger condition checks reuse ThreatMap, CombatState, ShipData queries
- Target override mechanism simple (return target_id instead of calling F-AI-006)

**Performance:**
- 8 condition checks per turn (simple boolean logic, very fast)
- Early exit once tactic triggered (don't check lower-priority tactics)

**Compatibility:**
- Tactics layer on top of existing systems (doesn't replace them)
- Can be disabled individually via flags for balance testing

**Design Philosophy:**
- Tactics should feel like "smart plays," not exploits
- Tactic names memorable and teachable (players adopt AI terminology)
- Tactics create highlight moments in combat
- Observing tactics teaches players optimal strategies

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
