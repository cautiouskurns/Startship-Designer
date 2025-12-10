# F-AI-004: Enhanced Combat Log

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 1 day
**Dependencies:** F-AI-002 (Combat State Evaluator), F-AI-003 (Basic Doctrine System)
**Phase:** 1 - Foundation

---

## Purpose

**Why does this feature exist?**
Auto-battlers fail when players can't understand *why* they lost. An enhanced combat log makes AI reasoning transparent, helping players learn and iterate their designs intelligently.

**What does it enable?**
Players see the AI's thought process: "Enemy targeted my reactor to disrupt power grid" or "Defensive Turtle: Prioritizing weapons to reduce incoming damage." This transforms frustrating losses into learning opportunities.

**Success criteria:**
- 90% of playtesters can explain why they won/lost after reading log
- Log entries appear within 0.2s of combat actions
- Log readable at a glance (no scrolling mid-combat for recent entries)
- AI reasoning clear and non-technical ("targeted engines" not "room_type=3 scored 0.7")

---

## How It Works

### Overview

The combat log is a scrollable text panel that displays turn-by-turn events with AI reasoning:
- **Turn announcements** ("Turn 3: Player's Turn")
- **Doctrine context** ("Alpha Strike doctrine: Focusing on enemy offense")
- **Target selection reasoning** ("Targeting enemy reactor [B4] - highest threat, disrupts power")
- **Damage breakdown** ("Dealt 30 damage. Shields absorbed 15. Hull damage: 15")
- **Room destruction** ("Destroyed enemy Weapon [A2] - enemy firepower reduced")
- **State changes** ("Momentum shift: We're gaining the advantage!")

Each entry includes:
- **Timestamp** (Turn number)
- **Actor** (Player/Enemy)
- **Action** (Attack, Target, Destroy, State Change)
- **Reasoning** (Why the AI chose this action)

### User Flow
```
1. Combat begins → log shows "Combat Start" entry
2. Turn starts → log shows "Turn 1: Player's Turn" + doctrine summary
3. AI selects target (F-AI-006) → log shows "Targeting [room] because [reason]"
4. Damage dealt → log shows damage breakdown with shield absorption
5. Room destroyed → log shows which room and impact on enemy stats
6. Turn ends → log shows brief summary if state changed
7. Combat ends → log shows final summary ("Victory: Superior firepower overwhelmed enemy")
8. Player clicks REDESIGN → log accessible in post-battle review (scroll history)
```

### Rules & Constraints

**Log Entry Format:**
```
[Turn N] [Actor]: [Action] - [Reasoning]
Example: "[Turn 2] Enemy: Targeted Reactor [C3] - Defensive Turtle: Eliminate power sources"
```

**Entry Categories:**

**1. Turn Announcements**
- Format: `[Turn N] [Actor]'s Turn`
- Example: `[Turn 1] Player's Turn`
- Frequency: Every turn start

**2. Doctrine Context (first turn only)**
- Format: `[Turn 1] [Actor]: [Doctrine Name] doctrine active - [Brief strategy]`
- Example: `[Turn 1] Enemy: Defensive Turtle doctrine active - Prioritizing threat reduction`
- Frequency: Once at combat start per ship

**3. Target Selection**
- Format: `[Turn N] [Actor]: Targeting [Room Type] [Grid Position] - [Reasoning]`
- Example: `[Turn 2] Player: Targeting Weapon [E2] - Alpha Strike: Eliminate enemy offense`
- Reasoning sources:
  - Doctrine priority: "Alpha Strike: Maximize damage output"
  - Threat assessment: "Highest threat room (30 DPS)"
  - Power disruption: "Reactor powers 4 rooms, high-value target"
  - Finishing blow: "Room already damaged, finishing it off"
- Frequency: Once per turn (primary target only)

**4. Damage Breakdown**
- Format: `[Turn N] [Actor]: Dealt [X] damage. Shields absorbed [Y]. Hull damage: [Z]`
- Example: `[Turn 3] Player: Dealt 40 damage. Shields absorbed 20. Hull damage: 20`
- Frequency: Once per turn after attack

**5. Room Destruction**
- Format: `[Turn N] [Actor]: Destroyed [Room Type] [Grid Position] - [Impact]`
- Example: `[Turn 3] Player: Destroyed Weapon [E2] - Enemy firepower reduced to 20 DPS`
- Impact descriptions:
  - Weapon destroyed: "Enemy firepower reduced to [X] DPS"
  - Shield destroyed: "Enemy defense reduced to [X] absorption"
  - Reactor destroyed: "Enemy power grid disrupted, [X] rooms unpowered"
  - Engine destroyed: "Enemy initiative reduced"
  - Armor destroyed: "Enemy hull integrity weakened"
- Frequency: Once per destroyed room

**6. State Changes**
- Format: `[Turn N] Combat State: [State Change Description]`
- Example: `[Turn 4] Combat State: Momentum shift - We're gaining the advantage!`
- Triggers:
  - Momentum shift (GAINING/LOSING): "Momentum shift - [Actor] gaining/losing advantage"
  - Desperation level change: "Enemy entering desperate situation (win chance: 15%)"
  - Dramatic shift (win prob change ≥25%): "Dramatic turn of events! Situation changed drastically"
  - Combat phase change: "Entering late-game phase (Turn 9)"
- Frequency: When CombatState detects changes

**7. Combat End**
- Format: `[Turn N] Combat Ended: [Victory/Defeat] - [Reason]`
- Example: `[Turn 7] Combat Ended: Victory - Enemy hull destroyed (Superior firepower)`
- Reasons:
  - "Enemy hull destroyed" (HP ≤ 0)
  - "Enemy Bridge destroyed" (instant loss)
  - "Superior firepower overwhelmed enemy"
  - "Enemy unable to penetrate defenses" (shields too strong)
- Frequency: Once at combat end

**Text Length Limits:**
- Reasoning: Max 60 characters (1 line)
- Impact description: Max 50 characters
- Total entry: Max 120 characters (fits in 800px wide panel at 16pt font)

**Visual Styling:**
- Player actions: White text (#FFFFFF)
- Enemy actions: Red text (#E24A4A)
- State changes: Yellow text (#E2D44A)
- Combat end: Green (#4AE24A) for victory, Red for defeat

**Auto-Scroll Behavior:**
- Log auto-scrolls to newest entry when new text added
- Player can manually scroll up to read history (disables auto-scroll temporarily)
- Clicking anywhere in combat re-enables auto-scroll

### Edge Cases

**Multiple rooms destroyed in one turn:**
- Create separate log entry for each room
- Example:
  ```
  [Turn 3] Player: Destroyed Weapon [E2] - Enemy firepower reduced to 30 DPS
  [Turn 3] Player: Destroyed Weapon [E3] - Enemy firepower reduced to 20 DPS
  ```

**No damage dealt (shields block everything):**
- Format: `[Turn N] [Actor]: Dealt [X] damage. Fully absorbed by shields. Hull damage: 0`
- Example: `[Turn 2] Player: Dealt 20 damage. Fully absorbed by shields. Hull damage: 0`

**First turn (no previous state to compare):**
- Skip state change entries (momentum defaults to NEUTRAL, no log entry)
- Only show doctrine context and first attack

**Combat shorter than 3 turns:**
- Still show all relevant entries (turn announcements, attacks, end result)
- May not reach late-game phase (no phase change entry)

**Very long combat (15+ turns):**
- Log grows long, player may need to scroll
- Keep last 50 entries in memory (older entries discarded to prevent lag)
- Post-battle review (F-AI-016) saves full log to file

---

## User Interaction

### Controls
- **Mouse wheel / trackpad**: Scroll through log history
- **Click log area**: Re-enable auto-scroll if manually scrolled up

### Visual Feedback
- New entries fade in (0.2s) with slight highlight
- Auto-scroll animates smoothly (0.3s tween)
- Current turn entry has subtle glow outline

### Audio Feedback
None (optional: subtle "log entry" sound effect in polish phase)

---

## Visual Design

### Layout
- **Position**: Right side of screen, 400px wide, full height (720px)
- **Background**: Semi-transparent dark panel (#1A1A1A, 90% opacity)
- **Border**: 2px white border (#FFFFFF)
- **Title**: "COMBAT LOG" at top (24pt white text)

### Components
- **ScrollContainer**: Parent container for log entries
- **VBoxContainer**: Vertical list of log entries (auto-grows)
- **LogEntry**: Individual text labels (RichTextLabel for color formatting)

### Visual Style
- **Font**: Monospace (Courier New or similar) for alignment
- **Size**: 16pt for body text, 18pt for turn announcements
- **Spacing**: 8px between entries, 16px between turns
- **Colors**: (as defined in Rules & Constraints)

### States
- **Normal**: Auto-scrolling to newest entry
- **Manual Scroll**: Player scrolled up, auto-scroll disabled
- **Scrolled to Bottom**: Player at newest entry, auto-scroll re-enabled

---

## Technical Implementation

### Scene Structure
```
CombatLog.tscn (new scene, added to Combat.tscn)
├── Panel (background)
├── Title Label ("COMBAT LOG")
└── ScrollContainer
    └── VBoxContainer
        └── LogEntry (Label) ×N (dynamically added)
```

### Script Responsibilities

**New File: `scripts/ui/CombatLog.gd`**
- Manages log entries and scrolling
- Methods:
  - add_entry(text: String, color: Color, category: EntryCategory)
  - add_turn_announcement(turn_number: int, actor: String)
  - add_doctrine_context(actor: String, doctrine_name: String, strategy: String)
  - add_target_selection(actor: String, room_type: String, grid_pos: String, reasoning: String)
  - add_damage_breakdown(actor: String, total_damage: int, shield_absorption: int, hull_damage: int)
  - add_room_destruction(actor: String, room_type: String, grid_pos: String, impact: String)
  - add_state_change(description: String)
  - add_combat_end(victory: bool, reason: String)
  - clear_log()
- Handles auto-scroll logic and manual scroll detection

**Modified: `scripts/combat/Combat.gd`**
- Instantiates CombatLog scene
- Calls log methods at appropriate moments:
  - Combat start: add doctrine context for both ships
  - Turn start: add turn announcement
  - Target selected: add target selection with reasoning
  - Damage dealt: add damage breakdown
  - Room destroyed: add destruction entry with impact
  - State changes (from F-AI-002): add state change entry
  - Combat end: add combat end summary

**New File: `scripts/ai/AIReasoning.gd`**
- Generates human-readable reasoning strings for log
- Methods:
  - get_target_reasoning(doctrine: Doctrine, target_room: RoomData, threat_score: float) -> String
  - get_impact_description(room_type: RoomData.RoomType, remaining_stats: Dictionary) -> String
  - get_end_reason(winner_stats: Dictionary, loser_stats: Dictionary) -> String
- Formats reasoning based on doctrine traits and combat state

### Data Structures

```gdscript
class_name CombatLog

enum EntryCategory {
    TURN_ANNOUNCEMENT,
    DOCTRINE_CONTEXT,
    TARGET_SELECTION,
    DAMAGE_BREAKDOWN,
    ROOM_DESTRUCTION,
    STATE_CHANGE,
    COMBAT_END
}

# Log entry data (for post-battle analysis)
class LogEntry:
    var turn_number: int
    var category: EntryCategory
    var actor: String  # "Player" or "Enemy"
    var text: String
    var color: Color
    var timestamp: float  # Time.get_ticks_msec()
```

### Integration Points

**Connects to:**
- Combat.gd (receives combat events)
- Doctrine (uses doctrine name and traits for reasoning)
- CombatState (receives state change notifications)
- Threat Assessment (F-AI-005, uses threat scores for reasoning)

**Emits signals:**
None (display only)

**Listens for:**
- combat_turn_started(turn_number, actor)
- target_selected(actor, target_room, reasoning)
- damage_dealt(actor, total, shields, hull)
- room_destroyed(actor, room_type, grid_pos)
- combat_state_changed(old_state, new_state)
- combat_ended(victory, reason)

**Modifies:**
Nothing (display only, no game logic)

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
const LOG_ENTRY_FADE_IN_TIME = 0.2  # Seconds
const LOG_AUTO_SCROLL_SPEED = 0.3   # Seconds for scroll animation
const LOG_MAX_ENTRIES = 50          # Max entries before pruning old ones
const LOG_ENTRY_SPACING = 8         # Pixels between entries
const LOG_TURN_SPACING = 16         # Pixels between turns
const LOG_REASONING_MAX_LENGTH = 60 # Characters
const LOG_IMPACT_MAX_LENGTH = 50    # Characters
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] Combat log visible on right side of combat screen (400px wide)
- [ ] Turn announcements appear each turn with correct turn number
- [ ] Doctrine context shown on Turn 1 for both player and enemy
- [ ] Target selection entries show room type, grid position, and reasoning
- [ ] Damage breakdown entries show total damage, shield absorption, hull damage
- [ ] Room destruction entries show room type, position, and impact on enemy stats
- [ ] State change entries appear when momentum shifts or desperation changes
- [ ] Combat end entry shows victory/defeat with human-readable reason
- [ ] Player actions displayed in white, enemy actions in red, state changes in yellow
- [ ] Log auto-scrolls to newest entry within 0.3s of new entry
- [ ] Player can manually scroll up to read history (disables auto-scroll)
- [ ] Clicking log area re-enables auto-scroll
- [ ] Log entries fade in smoothly (0.2s) when added
- [ ] Log performs well with 50+ entries (no lag or stutter)

---

## Testing Checklist

### Functional Tests
- [ ] **Full combat playthrough**: All entry types appear in correct order
- [ ] **Alpha Strike vs Turtle**: Log shows doctrine-specific reasoning ("Alpha Strike: Targeting weapons")
- [ ] **Shield absorption**: Damage breakdown shows correct absorption math
- [ ] **Multiple rooms destroyed**: Separate log entries for each room
- [ ] **Momentum shift**: State change entry appears when win probability changes ≥10%

### Edge Case Tests
- [ ] **No damage dealt (shields block all)**: Log shows "Fully absorbed by shields. Hull damage: 0"
- [ ] **Combat ends Turn 2 (quick victory)**: Log shows all relevant entries, no errors
- [ ] **Combat lasts 15+ turns**: Log handles long combat, old entries pruned after 50
- [ ] **Reactor destroyed**: Log shows power grid disruption impact

### Integration Tests
- [ ] Works with Doctrine system (F-AI-003) for reasoning text
- [ ] Works with CombatState (F-AI-002) for state change entries
- [ ] Works with Combat.gd turn flow (entries appear at correct moments)
- [ ] Doesn't block combat execution (async, non-blocking)

### Polish Tests
- [ ] Log entries readable at a glance (font size appropriate, colors distinct)
- [ ] Auto-scroll smooth and predictable
- [ ] Manual scroll doesn't interfere with combat animations
- [ ] Reasoning text concise and non-technical (playtester-friendly)
- [ ] Log provides enough info to understand win/loss (playtester validation)

---

## Known Limitations

- **No filtering:** Can't filter by entry type (e.g., show only target selections)
- **No timestamps:** Entries show turn number, not real-world time
- **Limited history:** Only last 50 entries kept in memory (older ones discarded)
- **No export:** Log not saved to file (F-AI-016 adds this feature)
- **Single-line reasoning:** Reasoning limited to 60 characters (may be too short for complex logic)

---

## Future Enhancements

*(Not for MVP)*

- Collapsible turn sections: Click turn announcement to collapse/expand turn details
- Entry filtering: Toggle buttons to show/hide entry categories
- Log export: Save full log to .txt file (implemented in F-AI-016)
- Color-coded threat levels: Highlight high-threat targets in orange
- Hover tooltips: Hover over room reference (e.g., "Reactor [C3]") to highlight it on ship grid
- Voice narration: Text-to-speech reads log entries aloud (accessibility feature)

---

## Implementation Notes

**Code Reuse:**
- RichTextLabel for color formatting (built-in Godot feature)
- ScrollContainer handles scrolling logic (minimal custom code)
- Tween for auto-scroll animation (simple easing)

**Performance:**
- Limit to 50 entries to prevent memory bloat
- Use object pooling for LogEntry labels (create once, reuse)
- Defer log updates by 1 frame if combat animation playing (avoid blocking)

**Compatibility:**
- Combat log is additive (doesn't change combat logic)
- Can be hidden via toggle button (accessibility option)
- Log data structure enables post-battle analysis (F-AI-016)

**Design Philosophy:**
- Transparency over mystery: Show AI reasoning openly
- Brevity over detail: One-line reasoning, not paragraphs
- Learning tool: Log teaches players game mechanics through observation

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
