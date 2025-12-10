# F-AI-013: AI Thought Bubbles

**Status:** 🔴 Planned
**Priority:** 🔥 Critical
**Estimated Time:** 2 days
**Dependencies:** F-AI-004 (Enhanced Combat Log)
**Phase:** 4 - Visual Feedback

---

## Purpose

**Why does this feature exist?**
Combat log is detailed but requires reading. Thought bubbles provide instant, at-a-glance understanding of AI reasoning through visual speech bubbles that appear above ships.

**What does it enable?**
Players instantly understand AI thinking without reading log: "Targeting their weapons!" or "We're losing power!" Thought bubbles add personality and make AI feel alive rather than mechanical.

**Success criteria:**
- Thought bubbles appear within 0.2s of AI decisions
- 85% of playtesters correctly identify AI strategy from bubbles alone
- Bubbles don't obstruct combat view (positioned cleanly)
- Bubbles reflect doctrine personality (Alpha Strike sounds aggressive, Turtle sounds cautious)

---

## How It Works

### Overview

Thought bubbles are speech-bubble-style UI elements that appear above ships during combat, showing concise AI reasoning:
- **Turn start**: Show doctrine summary ("Gotta break their offense!")
- **Target selection**: Show targeting reasoning ("That reactor looks critical")
- **State changes**: Show emotional reactions ("We're in trouble!" or "They're falling apart!")
- **Tactic activation**: Show tactical intent ("Time for a surgical strike!")

Each bubble:
- Displays for 2-3 seconds
- Fades in/out smoothly (0.3s)
- Max 40 characters (brief, punchy text)
- Positioned above ship, clear of other UI

### User Flow
```
1. Combat turn starts → AI makes decision
2. ThoughtBubble.show(ship, text, emotion) called
3. Bubble appears above ship with text
4. Bubble displays for 2-3 seconds
5. Bubble fades out
6. Next decision → new bubble appears (old one cleared)
```

### Rules & Constraints

**Bubble Triggers & Text:**

**Turn Start (Doctrine Context):**
- Alpha Strike: "Hit them hard and fast!"
- Defensive Turtle: "Stay defensive, outlast them."
- Adaptive Response: "Let's adapt to the situation."
- Berserker Rush: "CHARGE! No holding back!"
- War of Attrition: "Patience... wear them down."
- Surgical Strike: "Precision. Target their weak points."

**Target Selection:**
- Weapon targeted: "Taking out their firepower!"
- Reactor targeted: "Cut their power supply!"
- Shield targeted: "Breaking through their defenses!"
- Engine targeted: "Slow them down!"
- Bridge targeted: "Going for the kill shot!"

**State Changes:**
- Momentum GAINING: "We're turning this around!"
- Momentum LOSING: "They're gaining ground..."
- Desperation CRITICAL: "This is it! All or nothing!"
- Win probability >80%: "Victory is in sight!"
- Power crisis: "Losing power! Priorities shifting!"

**Tactic Activation:**
- Focus Fire: "Concentrate fire!"
- Power Strangle: "Cripple their power grid!"
- Surgical Strike: "Critical target acquired!"
- Desperation Gambit: "One last shot at this!"

**Room Destroyed (Reaction):**
- Our room destroyed: "They got our [room type]!"
- Enemy room destroyed: "Direct hit on their [room type]!"

**Text Length**: Max 40 characters to fit in bubble cleanly

**Display Duration**: 2.5 seconds per bubble (tunable)

**Positioning:**
- Player ship: Above ship, offset Y: -100px from ship center
- Enemy ship: Above ship, offset Y: -100px from ship center
- Z-index: Above ships, below UI panels

**Visual Style:**
- Speech bubble shape (rounded rectangle with tail pointing to ship)
- Semi-transparent white background (#FFFFFF, 85% opacity)
- Black text (#000000, 18pt font)
- Border: 2px solid color matching ship (player=blue, enemy=red)
- Tail pointing downward toward ship

---

## Edge Cases

**Multiple bubbles trigger simultaneously:**
- Queue bubbles, show one at a time (0.5s gap between)
- Max 3 bubbles in queue (discard oldest if exceeded)

**Bubble during animation:**
- Bubble appears even during damage/explosion animations
- Positioned relative to ship center (not affected by ship shake/flash)

**Very long text (>40 chars):**
- Truncate to 37 characters + "..."
- Example: "Their reactor is the key to..." → "Their reactor is the key to victory..."

**Rapid state changes:**
- Example: Momentum shift + tactic activation same turn
- Show tactic bubble (higher priority), skip state change bubble

**Combat ends while bubble displaying:**
- Bubble fades out immediately (0.1s) when combat ends
- Victory/defeat screen has priority

---

## User Interaction

### Controls
None (automatic display)

### Visual Feedback
- Bubble fades in (0.3s)
- Text appears
- Bubble holds (2.5s)
- Bubble fades out (0.3s)

### Audio Feedback
None (optional: subtle "bubble pop" sound on appear)

---

## Visual Design

### Layout
- **Position**: Above ship center, Y offset -100px
- **Size**: Auto-width (fit text), 60px height
- **Anchor**: Center-top of ship

### Components
- NinePatchRect or ColorRect (bubble background)
- Label (text)
- Polygon2D (speech tail)

### Visual Style
- **Background**: White (#FFFFFF) 85% opacity
- **Border**: 2px solid, colored by ship (blue/red)
- **Text**: Black (#000000), 18pt, centered
- **Tail**: 20px tall triangle, same color as border

### States
- **Fading In**: Modulate alpha 0.0 → 1.0 (0.3s)
- **Displaying**: Modulate alpha 1.0 (2.5s)
- **Fading Out**: Modulate alpha 1.0 → 0.0 (0.3s)

---

## Technical Implementation

### Scene Structure
```
ThoughtBubble.tscn
├── Panel (background + border)
├── Label (text)
└── Polygon2D (tail pointing to ship)
```

### Script Responsibilities

**New File: `scripts/ui/ThoughtBubble.gd`**
- Displays thought bubble above ship
- Methods:
  - show_thought(text: String, duration: float = 2.5)
  - fade_in() → Tween
  - fade_out() → Tween
  - queue_thought(text: String) (if bubble already showing)
- Auto-destroys after fading out

**New File: `scripts/ai/ThoughtBubbleGenerator.gd`**
- Generates appropriate text based on AI state
- Methods:
  - get_doctrine_thought(doctrine: Doctrine) → String
  - get_target_thought(target_room_type: RoomType) → String
  - get_state_thought(combat_state: CombatState) → String
  - get_tactic_thought(tactic_type: TacticType) → String
  - get_reaction_thought(event: String, room_type: RoomType) → String
- Returns human-readable, personality-appropriate text

**Modified: `scripts/combat/Combat.gd`**
- Instantiate ThoughtBubble scenes above ships
- Call ThoughtBubbleGenerator at decision points:
  - Turn start: show doctrine thought
  - Target selected: show target thought
  - State change: show state thought
  - Tactic activated: show tactic thought
  - Room destroyed: show reaction thought

**Modified: `scripts/ui/CombatLog.gd`** (optional)
- Thought bubble text can match log entries for consistency

### Data Structures

```gdscript
class_name ThoughtBubbleGenerator

# Doctrine thought templates
const DOCTRINE_THOUGHTS = {
    Doctrine.ALPHA_STRIKE: "Hit them hard and fast!",
    Doctrine.DEFENSIVE_TURTLE: "Stay defensive, outlast them.",
    Doctrine.ADAPTIVE_RESPONSE: "Let's adapt to the situation.",
    Doctrine.BERSERKER_RUSH: "CHARGE! No holding back!",
    Doctrine.WAR_OF_ATTRITION: "Patience... wear them down.",
    Doctrine.SURGICAL_STRIKE: "Precision. Target weak points."
}

# Target thought templates
const TARGET_THOUGHTS = {
    RoomType.WEAPON: "Taking out their firepower!",
    RoomType.REACTOR: "Cut their power supply!",
    RoomType.SHIELD: "Breaking their defenses!",
    RoomType.ENGINE: "Slow them down!",
    RoomType.BRIDGE: "Going for the kill shot!",
    RoomType.ARMOR: "Chipping away at their hull."
}

# State thought templates
const STATE_THOUGHTS = {
    "momentum_gaining": "We're turning this around!",
    "momentum_losing": "They're gaining ground...",
    "desperation_critical": "All or nothing!",
    "winning": "Victory is in sight!",
    "power_crisis": "Losing power!"
}
```

### Integration Points

**Connects to:**
- Doctrine (F-AI-003): Doctrine personality text
- CombatState (F-AI-002): State change thoughts
- EmergentTactics (F-AI-011): Tactic activation thoughts
- TargetScoring (F-AI-006): Target selection thoughts
- Combat log (F-AI-004): Can share text templates

**Emits signals:**
None

**Listens for:**
- target_selected
- combat_state_changed
- tactic_activated
- room_destroyed

**Modifies:**
Nothing (display only)

### Configuration

**Tunable Constants in `BalanceConstants.gd`:**
```gdscript
const THOUGHT_BUBBLE_DURATION = 2.5  # Seconds
const THOUGHT_BUBBLE_FADE_IN_TIME = 0.3
const THOUGHT_BUBBLE_FADE_OUT_TIME = 0.3
const THOUGHT_BUBBLE_MAX_QUEUE = 3  # Max queued bubbles
const THOUGHT_BUBBLE_QUEUE_GAP = 0.5  # Seconds between queued bubbles
const THOUGHT_BUBBLE_MAX_CHARS = 40
const THOUGHT_BUBBLE_Y_OFFSET = -100  # Pixels above ship
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] Thought bubbles appear above ships during combat
- [ ] Doctrine thoughts shown at turn start (unique per doctrine)
- [ ] Target thoughts shown when targeting selected (vary by room type)
- [ ] State thoughts shown when momentum/desperation changes
- [ ] Tactic thoughts shown when tactics activate
- [ ] Bubbles fade in (0.3s), display (2.5s), fade out (0.3s)
- [ ] Bubble text max 40 characters (truncated if longer)
- [ ] Bubbles don't obstruct combat view (positioned cleanly above ships)
- [ ] Multiple bubbles queue correctly (max 3, 0.5s gap)
- [ ] Bubble visual style clear and readable (white background, black text, colored border)

---

## Testing Checklist

### Functional Tests
- [ ] **Alpha Strike doctrine**: Shows "Hit them hard and fast!" at turn start
- [ ] **Target reactor**: Shows "Cut their power supply!"
- [ ] **Desperation = CRITICAL**: Shows "All or nothing!"
- [ ] **Focus Fire tactic**: Shows "Concentrate fire!"

### Edge Case Tests
- [ ] **Text >40 characters**: Truncates to 37 + "..."
- [ ] **Multiple bubbles same turn**: Queues and shows sequentially
- [ ] **Combat ends during bubble**: Bubble fades out immediately

### Integration Tests
- [ ] Works with Doctrine (F-AI-003) for personality text
- [ ] Works with CombatState (F-AI-002) for state thoughts
- [ ] Works with EmergentTactics (F-AI-011) for tactic thoughts
- [ ] Doesn't block combat execution

### Polish Tests
- [ ] Bubbles readable and clear
- [ ] Positioning doesn't obstruct health bars or ships
- [ ] Text reflects doctrine personality (Alpha Strike aggressive, Turtle cautious)
- [ ] Players understand AI strategy from bubbles alone (playtester validation)

---

## Known Limitations

- **Simple text**: No rich formatting (bold, italics, colors)
- **Fixed positioning**: Doesn't adapt to screen size dynamically
- **No voice**: Text only (no audio narration)
- **Single bubble per ship**: Can't show multiple thoughts simultaneously

---

## Future Enhancements

*(Not for MVP)*

- Voice narration: Text-to-speech or voice acting
- Rich text formatting: Bold/italic emphasis, colored keywords
- Emotive icons: Add small emoji/icon next to text
- Dynamic positioning: Adapt to screen resolution and UI layout
- Bubble history: Click ship to see last 3 thoughts

---

## Implementation Notes

**Code Reuse:**
- Text templates can match combat log entries (F-AI-004)
- Fade tweens reuse standard Godot Tween patterns
- Queue system simple array with FIFO logic

**Performance:**
- Max 2 active bubbles at once (player + enemy)
- Lightweight UI elements (no expensive rendering)
- Auto-cleanup after display (no memory leaks)

**Compatibility:**
- Bubbles additive (doesn't affect combat logic)
- Can be toggled off via accessibility option

**Design Philosophy:**
- Bubbles add personality, not just information
- Brevity critical (instant comprehension)
- Consistent with combat log but more punchy

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
