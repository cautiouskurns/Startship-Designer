# Crew Barks Sub-Feature: UI Presentation

**Status:** 🔴 Planned
**Priority:** 🔥 Critical (MVP requirement)
**Estimated Time:** 6-8 hours
**Dependencies:** Triggering System (1.1), Bark Content (1.2)
**Assigned To:** TBD
**Parent Feature:** [Anonymous Crew Barks System](crew_barks_system.md)

---

## Purpose

**Why does this feature exist?**
The best bark system in the world is useless if players can't see/hear it. UI presentation makes barks visible, readable, and immersive without distracting from combat.

**What does it enable?**
- Immediate visual feedback during combat (radio chatter box)
- Persistent record of crew reactions (combat log integration)
- Clear role identification ([ENGINEERING], [TACTICAL], etc.)
- Professional military aesthetic

**Success criteria:**
- Barks are readable at a glance (large font, good contrast)
- Radio box doesn't obscure combat view
- Barks fade smoothly without jarring transitions
- Combat log preserves all barks for review
- UI feels like military/sci-fi comm system

---

## How It Works

### Overview
When `bark_triggered` signal fires, RadioChatterBox displays the bark text with role tag in top-right corner. Text fades in over 0.3s, stays visible for 3s, fades out over 0.5s. Simultaneously, bark is added to CombatLog with timestamp and special styling to distinguish from damage numbers.

### User Flow
```
1. Combat event occurs → bark triggers
2. RadioChatterBox receives bark_triggered signal
3. Radio box fades in from transparent (0.3s tween)
4. Role tag and bark text appear: "[ENGINEERING] Main reactor offline!"
5. Text remains visible for 3 seconds
6. Radio box fades out (0.5s tween)
7. Simultaneously, CombatLog adds entry with icon and italic text
8. Player can scroll log to review past barks
```

### Rules & Constraints
- **Positioning:** Top-right corner (doesn't block combat view)
- **Size:** 400×80 pixels (readable but not dominating)
- **Fade timing:** In 0.3s, display 3s, out 0.5s (total 3.8s per bark)
- **Queue behavior:** New bark waits for current bark to fade out completely
- **Log preservation:** All barks saved to combat log (never deleted)
- **Combat log limit:** Max 100 entries (oldest deleted if exceeded)

### Edge Cases
- **Bark during fade-out:** Current bark finishes fade-out, new bark starts immediately
- **Battle ends during bark:** Bark completes normally (not cut off)
- **Very long bark text:** Text wraps to 2 lines (never clips)
- **Player scrolls combat log:** Bark entries persist and remain readable

---

## Visual Design

### Layout: Radio Chatter Box

```
┌─────────────────────────────────────┐
│  [ENGINEERING] Main reactor offline!│
└─────────────────────────────────────┘

Position: Top-right corner
Offset: -420, 20 (from top-right)
Size: 400×80 pixels
```

**Hierarchy:**
```
RadioChatterBox (Panel)
├── Background (StyleBoxFlat)
├── RoleLabel ([ENGINEERING])
└── BarkLabel (Main reactor offline!)
```

### Components

**Background Panel:**
- **Color:** Dark semi-transparent (#0F1419, 85% opacity)
- **Border:** 1px cyan (#4AE2E2)
- **Corner radius:** 4px
- **Shadow:** 2px black drop shadow

**Role Label:**
- **Font:** Monospace, 14pt, bold
- **Color:** Cyan (#4AE2E2)
- **Position:** Left-aligned, 10px padding
- **Format:** `[ROLE]` (brackets always included)

**Bark Label:**
- **Font:** Sans-serif, 16pt, regular
- **Color:** White (#FFFFFF)
- **Position:** Right of role label, 5px separation
- **Wrap:** Enabled (2 lines max)
- **Alignment:** Left

### Visual Style

**Colors:**
- Background: `#0F1419` (dark navy) @ 85% opacity
- Border: `#4AE2E2` (cyan)
- Role text: `#4AE2E2` (cyan)
- Bark text: `#FFFFFF` (white)

**Fonts:**
- Role: `res://assets/fonts/RobotoMono-Bold.ttf` (14pt)
- Bark: `res://assets/fonts/Roboto-Regular.ttf` (16pt)

**Animations:**
- Fade in: Modulate alpha 0.0 → 1.0, 0.3s, ease-out
- Fade out: Modulate alpha 1.0 → 0.0, 0.5s, ease-in

### States

**Default (Hidden):**
- Modulate: (1, 1, 1, 0) - fully transparent
- Visible: false
- Position: Fixed top-right

**Fading In:**
- Modulate: (1, 1, 1, 0.0 → 1.0) - alpha interpolating
- Visible: true
- Duration: 0.3s

**Active (Displaying):**
- Modulate: (1, 1, 1, 1) - fully opaque
- Visible: true
- Duration: 3.0s

**Fading Out:**
- Modulate: (1, 1, 1, 1.0 → 0.0) - alpha interpolating
- Visible: true → false at end
- Duration: 0.5s

---

## Combat Log Integration

### Visual Style in Log

**Standard log entry:**
```
Turn 5 - Enemy attacks for 40 damage
```

**Bark log entry:**
```
Turn 5 ◈ [TACTICAL] "Taking heavy fire!"
```

**Differences:**
- **Icon:** ◈ (communication symbol) before role tag
- **Italic:** Bark text in italics to differentiate from combat text
- **Indented:** Slight indent (10px) to show subordinate to turn event
- **Color:** Bark text in light cyan (#75E8E8) vs white combat text

### CombatLog Modification

**Add bark entry method:**
```gdscript
# In CombatLog.gd
func add_bark_entry(turn: int, role: String, bark_text: String):
    var label = Label.new()
    label.text = "Turn %d ◈ [%s] \"%s\"" % [turn, role, bark_text]
    label.add_theme_font_override("font", italic_font)
    label.add_theme_color_override("font_color", Color(0.46, 0.91, 0.91))  # Light cyan
    label.add_theme_constant_override("margin_left", 10)  # Indent
    log_container.add_child(label)

    # Auto-scroll to bottom
    await get_tree().process_frame
    scroll_to_bottom()
```

---

## Technical Implementation

### Scene Structure

```
RadioChatterBox.tscn
└── Panel (Control)
    ├── MarginContainer
    │   └── HBoxContainer
    │       ├── RoleLabel (Label)
    │       └── BarkLabel (Label)
    └── AnimationPlayer (optional, for complex animations)

Existing: CombatLog.tscn
└── ScrollContainer
    └── VBoxContainer (log entries)
```

### Script Responsibilities

**RadioChatterBox.gd:**
- Listens for `CrewBarkSystem.bark_triggered` signal
- Displays bark with fade-in animation
- Holds for 3 seconds
- Fades out
- Emits `bark_display_complete` when done

**CombatLog.gd (modifications):**
- Add `add_bark_entry()` method
- Load italic font resource
- Apply special styling to bark entries

### Integration Points

**Listens for:**
```gdscript
# RadioChatterBox.gd
func _ready():
    CrewBarkSystem.bark_triggered.connect(_on_bark_triggered)

func _on_bark_triggered(bark: BarkData):
    _display_bark(bark)
```

**Emits:**
```gdscript
signal bark_display_complete()
```

**Modifies:**
- Own visibility and modulate (fade in/out)
- Own label text (role + bark)
- CombatLog container (adds bark entry)

---

## Animation Implementation

### Tween-Based Fade

```gdscript
# RadioChatterBox.gd
var display_tween: Tween = null
var is_displaying: bool = false

func _display_bark(bark: BarkData):
    # Cancel any existing tween
    if display_tween:
        display_tween.kill()

    # Set text
    role_label.text = "[%s]" % _role_to_string(bark.role)
    bark_label.text = bark.text

    # Start fade sequence
    visible = true
    modulate.a = 0.0

    # Create tween
    display_tween = create_tween()

    # Fade in (0.3s)
    display_tween.tween_property(self, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)

    # Hold (3.0s)
    display_tween.tween_interval(3.0)

    # Fade out (0.5s)
    display_tween.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)

    # Hide and signal complete
    display_tween.tween_callback(func():
        visible = false
        bark_display_complete.emit()
    )

func _role_to_string(role: CrewRole) -> String:
    match role:
        CrewRole.CAPTAIN:
            return "CAPTAIN"
        CrewRole.TACTICAL:
            return "TACTICAL"
        CrewRole.ENGINEERING:
            return "ENGINEERING"
        CrewRole.OPERATIONS:
            return "OPS"
    return "UNKNOWN"
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] RadioChatterBox displays in top-right corner
- [ ] Bark text is clearly readable (good contrast, large font)
- [ ] Role tags are visible and color-coded (cyan)
- [ ] Fade-in animation smooth (0.3s)
- [ ] Bark holds for 3 seconds (readable duration)
- [ ] Fade-out animation smooth (0.5s)
- [ ] Multiple barks queue correctly (no overlap)
- [ ] Combat log shows bark entries with special styling
- [ ] Combat log preserves all barks (can scroll back)
- [ ] Radio box doesn't block important UI elements
- [ ] Performance acceptable (fade doesn't drop FPS)

---

## Testing Checklist

### Functional Tests
- [ ] **Test 1:** Trigger bark → radio box fades in, displays text, fades out
- [ ] **Test 2:** Trigger 2 barks rapidly → second waits for first to complete
- [ ] **Test 3:** Scroll combat log → bark entries visible with correct formatting
- [ ] **Test 4:** Battle with 20 barks → all preserved in log
- [ ] **Test 5:** Battle ends mid-bark → bark completes normally

### Visual Tests
- [ ] **Test 6:** Radio box positioned correctly at 1920×1080
- [ ] **Test 7:** Radio box positioned correctly at 1280×720
- [ ] **Test 8:** Long bark text (20 words) wraps without clipping
- [ ] **Test 9:** Role tag and bark text aligned correctly
- [ ] **Test 10:** Fade animations smooth (no stuttering)

### Integration Tests
- [ ] **Test 11:** Works with existing combat UI (no z-index issues)
- [ ] **Test 12:** Combat log scrolling doesn't break bark entries
- [ ] **Test 13:** Radio box doesn't block health bars or ship displays
- [ ] **Test 14:** Barks appear in log at correct turn number

### Polish Tests
- [ ] **Test 15:** Radio box has professional sci-fi aesthetic
- [ ] **Test 16:** Text readable at arm's length (accessibility)
- [ ] **Test 17:** Animations feel natural (not too fast/slow)
- [ ] **Test 18:** Combat log icon (◈) renders correctly

---

## Known Limitations

- **No audio visual:** MVP is text-only (Phase 2 adds waveform animation)
- **Fixed position:** Radio box can't be moved by player (Phase 3: draggable)
- **2-line limit:** Very long barks truncate (acceptable for MVP - barks should be brief)
- **No fade interruption:** New bark can't interrupt current bark mid-display (Phase 3: interrupt system)

---

## Future Enhancements

*(Not for MVP, but worth noting)*

- **Audio waveform animation:** Radio box shows animated waveform when voice plays
- **Draggable position:** Player can move radio box to preferred location
- **Customizable size:** Player can resize radio box (small/medium/large)
- **Toggle visibility:** Option to hide radio box, keep log integration only
- **Combat log filtering:** Show only barks, hide damage numbers (or vice versa)
- **Bark history panel:** Dedicated UI showing last 5 barks (always visible)

---

## Implementation Notes

**Important details:**
- Use `modulate.a` for fade (don't animate `position`, causes jitter)
- Radio box must be above combat UI in z-index (but below pause menu)
- Combat log uses `ScrollContainer` - must call `scroll_to_bottom()` after adding entry
- Role colors can be added later (ENGINEERING = yellow, TACTICAL = red, etc.) - MVP uses uniform cyan

**Gotchas to watch out for:**
- Tween must be killed before starting new one (memory leak if not)
- `visible = false` must happen AFTER fade-out completes (not before)
- Combat log can overflow if too many entries - enforce limit (100 entries max)
- Italics font must be loaded as separate resource (can't apply italic style to regular font in Godot)

**Alternative approach considered but rejected:**
- **AnimationPlayer instead of Tween:** Rejected (tweens more flexible, easier to interrupt)
- **Floating text above ship:** Rejected (blocks combat view, hard to read)
- **Center-screen toast:** Rejected (too intrusive, blocks action)

---

## Code Example

```gdscript
# RadioChatterBox.gd
extends Panel

signal bark_display_complete()

@onready var role_label: Label = $MarginContainer/HBoxContainer/RoleLabel
@onready var bark_label: Label = $MarginContainer/HBoxContainer/BarkLabel

var display_tween: Tween = null

func _ready():
    visible = false
    modulate.a = 0.0

    # Connect to bark system
    CrewBarkSystem.bark_triggered.connect(_on_bark_triggered)

func _on_bark_triggered(bark: BarkData):
    _display_bark(bark)

func _display_bark(bark: BarkData):
    # Cancel existing tween
    if display_tween:
        display_tween.kill()

    # Set content
    role_label.text = "[%s]" % _role_to_string(bark.role)
    bark_label.text = bark.text

    # Reset state
    visible = true
    modulate.a = 0.0

    # Create fade sequence
    display_tween = create_tween()
    display_tween.tween_property(self, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
    display_tween.tween_interval(3.0)
    display_tween.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
    display_tween.tween_callback(_on_display_complete)

    # Add to combat log
    _add_to_combat_log(bark)

func _on_display_complete():
    visible = false
    bark_display_complete.emit()

func _add_to_combat_log(bark: BarkData):
    var combat_log = get_node_or_null("../../CombatLog")  # Adjust path as needed
    if combat_log and combat_log.has_method("add_bark_entry"):
        var current_turn = Combat.current_turn  # Assuming Combat autoload tracks turn
        combat_log.add_bark_entry(current_turn, _role_to_string(bark.role), bark.text)

func _role_to_string(role: CrewRole) -> String:
    match role:
        CrewRole.CAPTAIN: return "CAPTAIN"
        CrewRole.TACTICAL: return "TACTICAL"
        CrewRole.ENGINEERING: return "ENGINEERING"
        CrewRole.OPERATIONS: return "OPS"
    return "UNKNOWN"
```

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-01-04 | Initial spec | Sub-feature defined for crew barks MVP |
