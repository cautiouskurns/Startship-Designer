# F-AI-016: Post-Battle Analysis

**Status:** 🔴 Planned
**Priority:** ➡️ Medium
**Estimated Time:** 2 days
**Dependencies:** F-AI-004 (Enhanced Combat Log), F-AI-011 (Emergent Tactics)
**Phase:** 4 - Visual Feedback

---

## Purpose

**Why does this feature exist?**
After combat ends, players need to review what happened to learn and improve. A post-battle screen summarizes key moments, tactics used, and strategic insights.

**What does it enable?**
Players review full combat log, see tactical highlights, understand why they won/lost, and export battle data for analysis. Accelerates learning and iteration.

**Success criteria:**
- Post-battle screen shows complete combat summary
- Highlights key turning points (momentum shifts, tactic activations)
- Players understand defeat causes within 30 seconds of review
- Battle data exportable to .txt or .json

---

## How It Works

### Overview

After combat ends (victory or defeat), transition to Post-Battle Analysis screen showing:

**Summary Section:**
- Result: Victory/Defeat
- Turns survived: N
- Final HP: Player X%, Enemy Y%
- Damage dealt: Total player damage
- Damage taken: Total enemy damage
- Rooms destroyed: Player lost X, Enemy lost Y

**Tactical Highlights:**
- Tactics activated (both sides)
- Momentum shifts (turn numbers + descriptions)
- Critical moments (reactor destroyed, synergy broken)

**Full Combat Log:**
- Scrollable complete log from combat
- Highlighting for key entries (tactics, state changes)

**Action Buttons:**
- REDESIGN: Return to ship designer
- REMATCH: Restart combat with same ships
- EXPORT LOG: Save battle log to file
- NEXT MISSION: (if victorious) Proceed to next

---

## Technical Implementation

**New Scene: `scripts/ui/PostBattleAnalysis.tscn`**
- Summary panel (top)
- Highlights panel (middle)
- Full log scroll container (bottom)
- Action buttons (bottom)

**Data Collection:**
- Combat.gd tracks statistics during battle
- Stores tactical events, state changes, damage totals
- Passes to PostBattleAnalysis on combat end

### Displayed Data

```gdscript
class BattleSummary:
    var victory: bool
    var turns: int
    var player_final_hp_percent: float
    var enemy_final_hp_percent: float
    var player_damage_dealt: int
    var enemy_damage_dealt: int
    var player_rooms_lost: int
    var enemy_rooms_lost: int
    var tactics_used: Array[TacticType]
    var momentum_shifts: Array[{turn: int, direction: String}]
    var critical_events: Array[String]
```

---

## Acceptance Criteria

- [ ] Post-battle screen appears after combat ends
- [ ] Summary shows correct statistics (HP%, damage, rooms lost)
- [ ] Highlights show tactics and momentum shifts
- [ ] Full combat log accessible and scrollable
- [ ] REDESIGN button returns to designer
- [ ] EXPORT LOG saves battle data to file

---

## Implementation Notes

**Performance**: Data collected during combat (no post-processing needed).
**Design Philosophy**: Learning tool, not just summary. Highlight educational moments.

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
