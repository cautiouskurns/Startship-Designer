# Crew Barks Sub-Feature: Triggering System

**Status:** 🔴 Planned
**Priority:** 🔥 Critical (MVP requirement)
**Estimated Time:** 8-10 hours
**Dependencies:** Combat system
**Assigned To:** TBD
**Parent Feature:** [Anonymous Crew Barks System](crew_barks_system.md)

---

## Purpose

**Why does this feature exist?**
The triggering system is the brain of the crew barks feature - it detects combat events and decides when, what, and how to play barks. Without intelligent triggering, barks would spam constantly or never play at all.

**What does it enable?**
- Automatic bark playback at appropriate moments
- Priority-based bark selection (critical events always heard)
- Spam prevention through cooldown system
- Queue management for multiple simultaneous events

**Success criteria:**
- Barks trigger on correct combat events
- No bark spam (minimum 2 seconds between barks)
- Critical events always take priority
- Multiple simultaneous events queue correctly

---

## How It Works

### Overview
The triggering system listens for combat events from Combat.gd, evaluates each event's priority, and queues appropriate barks. A cooldown timer prevents spam, and a priority queue ensures critical events are never missed. The system tracks which barks have been used to prevent repetition within a battle.

### User Flow
```
1. Combat event occurs (e.g., reactor destroyed)
2. Combat.gd emits event signal → CrewBarkSystem
3. BarkSelector chooses appropriate bark based on event + context
4. Bark added to priority queue
5. Queue processor checks cooldown timer
6. If cooldown expired: play highest priority bark, restart cooldown
7. If cooldown active: bark waits in queue
8. When cooldown expires, next queued bark plays
```

### Rules & Constraints
- **Cooldown:** Minimum 2.0 seconds between bark starts
- **Queue limit:** Maximum 5 queued barks (oldest low-priority dropped if exceeded)
- **Priority override:** HIGH priority barks can interrupt MEDIUM/LOW if queued
- **No repetition:** Same bark text can't be used twice in one battle
- **Battle reset:** Queue cleared and repetition tracking reset when new battle starts

### Edge Cases
- **Multiple simultaneous events:** Queue all, play in priority order
- **Battle ends mid-bark:** Current bark finishes, queue cleared
- **Same event repeated quickly:** Cooldown prevents duplicate barks
- **All barks for event used:** Falls back to generic bark ("Taking damage!" → "We're hit!")

---

## Combat Event Types

### Event → Bark Mapping

```gdscript
# Events that trigger barks
const COMBAT_EVENTS = {
    # Component destruction
    "player_component_destroyed": {
        "priority": BarkPriority.HIGH,
        "category": BarkCategory.DAMAGE_REPORT,
    },

    "enemy_component_destroyed": {
        "priority": BarkPriority.MEDIUM,
        "category": BarkCategory.TACTICAL_UPDATE,
    },

    # HP thresholds
    "player_hp_threshold_crossed": {
        "priority": BarkPriority.HIGH,
        "category": BarkCategory.CREW_STRESS,
    },

    # Power events
    "power_grid_failure": {
        "priority": BarkPriority.HIGH,
        "category": BarkCategory.SYSTEM_STATUS,
    },

    "power_cascade": {
        "priority": BarkPriority.HIGH,
        "category": BarkCategory.SYSTEM_STATUS,
    },

    # Battle outcomes
    "player_victory": {
        "priority": BarkPriority.CRITICAL,
        "category": BarkCategory.VICTORY_DEFEAT,
    },

    "player_defeat": {
        "priority": BarkPriority.CRITICAL,
        "category": BarkCategory.VICTORY_DEFEAT,
    },

    # Damage taken
    "player_heavy_damage": {  # >30 damage in one hit
        "priority": BarkPriority.MEDIUM,
        "category": BarkCategory.TACTICAL_UPDATE,
    },

    "player_minor_damage": {  # <15 damage
        "priority": BarkPriority.LOW,
        "category": BarkCategory.TACTICAL_UPDATE,
    },
}
```

---

## Technical Implementation

### Scene Structure
```
CrewBarkSystem (Autoload Singleton - no scene)
├── BarkTrigger.gd (event detection)
├── BarkQueue.gd (priority queue)
├── CooldownTimer (Timer node)
└── UsedBarks dictionary
```

### Script Responsibilities

**CrewBarkSystem.gd (Main controller):**
- Receives combat event signals
- Delegates to BarkTrigger for event processing
- Manages cooldown timer
- Emits `bark_triggered` signal when bark should play

**BarkTrigger.gd (Event processor):**
- Maps combat events to bark categories
- Determines event priority
- Passes event + context to BarkSelector

**BarkQueue.gd (Queue manager):**
- Maintains priority queue of pending barks
- Enforces queue size limit (5 max)
- Drops lowest priority when full
- Provides `get_next_bark()` method

### Data Structures

```gdscript
# BarkData.gd
class_name BarkData

var text: String              # "Main reactor offline!"
var role: CrewRole            # CrewRole.ENGINEERING
var priority: BarkPriority    # BarkPriority.HIGH
var category: BarkCategory    # BarkCategory.DAMAGE_REPORT
var audio_file: String        # "res://audio/barks/reactor_down.ogg" (optional)

# Priority levels
enum BarkPriority {
    LOW = 0,       # Minor hits, low-consequence events
    MEDIUM = 1,    # System damage, moderate hits
    HIGH = 2,      # Critical systems, HP thresholds
    CRITICAL = 3,  # Battle start/end, player death
}

# Categories (affects which barks are eligible)
enum BarkCategory {
    DAMAGE_REPORT,
    TACTICAL_UPDATE,
    SYSTEM_STATUS,
    CREW_STRESS,
    VICTORY_DEFEAT,
}

# Crew roles (for voice differentiation)
enum CrewRole {
    CAPTAIN,
    TACTICAL,
    ENGINEERING,
    OPERATIONS,
}
```

### Integration Points

**Listens for (from Combat.gd):**
```gdscript
# Existing combat signals (or create new ones)
Combat.component_destroyed.connect(_on_component_destroyed)
Combat.hp_changed.connect(_on_hp_changed)
Combat.battle_started.connect(_on_battle_started)
Combat.battle_ended.connect(_on_battle_ended)

# New signals to add to Combat.gd:
signal component_destroyed(ship: String, component_type: RoomData.RoomType)
signal hp_threshold_crossed(ship: String, threshold: int)
signal power_grid_failed(ship: String, affected_count: int)
```

**Emits:**
```gdscript
signal bark_triggered(bark: BarkData)
signal bark_queue_updated(queue_size: int)
```

**Modifies:**
- `used_barks` dictionary (tracks which barks played this battle)
- `current_cooldown` float (time since last bark)

---

## Priority System Logic

### Priority Queue Processing

```gdscript
func queue_bark(bark: BarkData) -> void:
    # Check if this bark was already used this battle
    if used_barks.has(bark.text):
        return  # Skip duplicate

    # Add to queue
    bark_queue.append(bark)

    # Sort by priority (highest first)
    bark_queue.sort_custom(_compare_priority)

    # Enforce queue size limit (5 max)
    while bark_queue.size() > MAX_QUEUE_SIZE:
        bark_queue.pop_back()  # Drop lowest priority

    # Try to process queue immediately
    _process_queue()

func _compare_priority(a: BarkData, b: BarkData) -> bool:
    return a.priority > b.priority
```

### Cooldown Management

```gdscript
func _process_queue() -> void:
    # Can't play if queue empty
    if bark_queue.is_empty():
        return

    # Can't play if cooldown active
    if cooldown_timer.time_left > 0:
        return

    # Get highest priority bark
    var bark = bark_queue.pop_front()

    # Mark as used (prevent repetition)
    used_barks[bark.text] = true

    # Emit bark
    bark_triggered.emit(bark)

    # Start cooldown
    cooldown_timer.start(BARK_COOLDOWN)

    # Update queue UI (if visible)
    bark_queue_updated.emit(bark_queue.size())

# When cooldown expires, process next bark
func _on_cooldown_timeout() -> void:
    _process_queue()
```

---

## Combat Integration

### Combat.gd Changes Required

**Add signals:**
```gdscript
# At top of Combat.gd with other signals
signal component_destroyed(ship: String, component_type: RoomData.RoomType)
signal hp_threshold_crossed(ship: String, threshold: int, current_hp: int)
signal power_grid_failed(ship: String, affected_count: int)
signal heavy_damage_dealt(ship: String, damage: int)
```

**Emit signals at appropriate locations:**

```gdscript
# In _destroy_room() after room destroyed:
func _destroy_room(ship: String, room_id: int):
    # ... existing destruction logic ...

    # NEW: Emit signal for crew barks
    var room_type = destroyed_room.room_type
    component_destroyed.emit(ship, room_type)

# In _apply_damage_to_hull() after HP changed:
func _apply_damage_to_hull(ship: String, damage: int):
    var ship_data = get_ship_data(ship)
    ship_data.hull_hp -= damage

    # NEW: Check HP thresholds
    var hp_percent = (ship_data.hull_hp / ship_data.max_hp) * 100
    if hp_percent <= 75 and not _threshold_crossed[ship]["75"]:
        hp_threshold_crossed.emit(ship, 75, ship_data.hull_hp)
        _threshold_crossed[ship]["75"] = true
    elif hp_percent <= 50 and not _threshold_crossed[ship]["50"]:
        hp_threshold_crossed.emit(ship, 50, ship_data.hull_hp)
        _threshold_crossed[ship]["50"] = true
    elif hp_percent <= 25 and not _threshold_crossed[ship]["25"]:
        hp_threshold_crossed.emit(ship, 25, ship_data.hull_hp)
        _threshold_crossed[ship]["25"] = true

    # NEW: Heavy damage bark (>30 damage in one hit)
    if damage >= 30:
        heavy_damage_dealt.emit(ship, damage)
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] All combat events emit appropriate signals
- [ ] CrewBarkSystem receives and processes events correctly
- [ ] Bark queue maintains correct priority order
- [ ] Cooldown prevents barks more frequent than 2 seconds
- [ ] Queue limit enforced (5 max, drops lowest priority)
- [ ] No bark repetition within a battle
- [ ] Battle reset clears queue and used_barks tracking
- [ ] Critical priority barks never dropped from queue
- [ ] System handles 10+ simultaneous events without crashing
- [ ] Performance impact negligible (<0.1ms per frame)

---

## Testing Checklist

### Functional Tests
- [ ] **Test 1:** Destroy player reactor → bark triggers immediately
- [ ] **Test 2:** Destroy 3 components rapidly → all 3 barks queue and play sequentially
- [ ] **Test 3:** HP crosses 75%, 50%, 25% → stress barks trigger at each threshold
- [ ] **Test 4:** Player wins battle → victory bark plays
- [ ] **Test 5:** Same component destroyed twice → only first triggers bark (no repeat)

### Edge Case Tests
- [ ] **Edge 1:** 10 events in same frame → queue caps at 5, drops lowest priority
- [ ] **Edge 2:** Battle ends mid-cooldown → queue cleared, new battle starts fresh
- [ ] **Edge 3:** Critical priority event during cooldown → waits correctly (doesn't interrupt)
- [ ] **Edge 4:** All barks for event type used → fallback generic bark plays

### Integration Tests
- [ ] Works with existing Combat.gd (no errors)
- [ ] Combat turn timing unaffected by bark system
- [ ] Signal connections don't leak memory
- [ ] Autoload singleton initializes correctly on game start

### Performance Tests
- [ ] 100 combat events in 1 second → no frame drops
- [ ] Queue processing takes <0.1ms per frame
- [ ] Memory usage stable (no leaks after 10 battles)

---

## Known Limitations

- **Generic fallbacks limited:** If all barks for event used, only 2-3 generic fallbacks available (acceptable for MVP)
- **No interrupt system:** Critical barks wait for cooldown, don't interrupt current bark (Phase 2 enhancement)
- **Fixed cooldown:** 2.0 second cooldown not adjustable by player (settings toggle Phase 3)
- **HP threshold tracking requires manual reset:** Combat.gd must reset `_threshold_crossed` dictionary each battle

---

## Future Enhancements

*(Not for MVP, but worth noting)*

- **Interrupt system:** CRITICAL priority can interrupt current bark
- **Dynamic cooldown:** Adjusts based on combat pace (slow combat = longer cooldown)
- **Context stacking:** Multiple related events combine into one bark ("Reactor and weapons offline!")
- **Bark cancellation:** Battle end immediately stops current bark (no finish)

---

## Implementation Notes

**Important details:**
- Use autoload singleton (not scene instance) for global access
- Combat.gd signals must pass ship identifier ("player" / "enemy") for correct context
- Queue must be sorted on every insertion, not just at processing time
- Don't forget to reset `used_barks` dictionary when battle starts

**Gotchas to watch out for:**
- Signal connections between autoload singletons can be tricky - test thoroughly
- Cooldown timer must be a child of the autoload node (can't be standalone)
- Used barks dictionary grows unbounded if not cleared (memory leak)

**Alternative approach considered but rejected:**
- **Immediate playback (no queue):** Rejected because simultaneous events would overlap
- **Event pooling:** Rejected because adds complexity for marginal performance gain

---

## Code Example

```gdscript
# CrewBarkSystem.gd (Autoload Singleton)
extends Node

signal bark_triggered(bark: BarkData)
signal bark_queue_updated(queue_size: int)

const BARK_COOLDOWN = 2.0  # seconds
const MAX_QUEUE_SIZE = 5

var bark_queue: Array[BarkData] = []
var used_barks: Dictionary = {}  # {bark_text: true}
var cooldown_timer: Timer

func _ready():
    # Create cooldown timer
    cooldown_timer = Timer.new()
    cooldown_timer.one_shot = true
    cooldown_timer.timeout.connect(_on_cooldown_timeout)
    add_child(cooldown_timer)

    # Connect to combat signals
    var combat = get_node_or_null("/root/Combat")
    if combat:
        combat.component_destroyed.connect(_on_component_destroyed)
        combat.hp_threshold_crossed.connect(_on_hp_threshold_crossed)
        combat.battle_started.connect(_on_battle_started)
        combat.battle_ended.connect(_on_battle_ended)

func _on_component_destroyed(ship: String, component_type: RoomData.RoomType):
    # Only bark for player ship
    if ship != "player":
        return

    # Select appropriate bark
    var bark = BarkSelector.select_for_component_destroyed(component_type)
    if bark:
        queue_bark(bark)

func _on_hp_threshold_crossed(ship: String, threshold: int, current_hp: int):
    if ship != "player":
        return

    var bark = BarkSelector.select_for_hp_threshold(threshold)
    if bark:
        queue_bark(bark)

func queue_bark(bark: BarkData) -> void:
    # Skip if already used
    if used_barks.has(bark.text):
        return

    # Add to queue
    bark_queue.append(bark)
    bark_queue.sort_custom(func(a, b): return a.priority > b.priority)

    # Enforce size limit
    while bark_queue.size() > MAX_QUEUE_SIZE:
        bark_queue.pop_back()

    # Try to process
    _process_queue()
    bark_queue_updated.emit(bark_queue.size())

func _process_queue() -> void:
    if bark_queue.is_empty() or cooldown_timer.time_left > 0:
        return

    var bark = bark_queue.pop_front()
    used_barks[bark.text] = true

    bark_triggered.emit(bark)
    cooldown_timer.start(BARK_COOLDOWN)
    bark_queue_updated.emit(bark_queue.size())

func _on_cooldown_timeout() -> void:
    _process_queue()

func _on_battle_started():
    # Reset state for new battle
    bark_queue.clear()
    used_barks.clear()
    cooldown_timer.stop()

func _on_battle_ended():
    # Clear queue but let current bark finish
    bark_queue.clear()
```

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-01-04 | Initial spec | Sub-feature defined for crew barks MVP |
