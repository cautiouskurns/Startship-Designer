# Crew Barks Sub-Feature: Bark Content & Selection

**Status:** 🔴 Planned
**Priority:** 🔥 Critical (MVP requirement)
**Estimated Time:** 8-10 hours
**Dependencies:** Triggering System (1.1)
**Assigned To:** TBD
**Parent Feature:** [Anonymous Crew Barks System](crew_barks_system.md)

---

## Purpose

**Why does this feature exist?**
The bark content is the actual text/voice lines that crew members speak. Good bark writing creates immersion and emotional engagement. Bad bark writing breaks immersion and feels cheesy.

**What does it enable?**
- Context-aware bark selection based on combat state
- Emotional progression (confidence → tension → desperation)
- Professional military atmosphere
- Design feedback through crew reactions

**Success criteria:**
- Barks feel authentic (military professional, not cheesy)
- Players understand what's happening from barks alone
- No repetition within a single battle
- Barks match combat intensity (stressed when losing, confident when winning)

---

## How It Works

### Overview
A database of ~50 barks organized into 5 categories. Each bark has metadata (priority, role, context requirements). BarkSelector filters barks by context (ship HP, systems remaining, battle phase) and randomly selects from eligible barks that haven't been used yet. If all barks exhausted, falls back to generic options.

### User Flow
```
1. Triggering system passes event + context to BarkSelector
2. BarkSelector queries BarkDatabase for barks matching:
   - Event type (component destroyed, HP threshold, etc.)
   - Current context (ship HP%, systems remaining, battle phase)
3. Filters out already-used barks
4. Randomly selects from remaining eligible barks
5. Returns BarkData object to triggering system
6. If no eligible barks, returns null (no bark plays)
```

### Rules & Constraints
- **Category matching:** Bark must belong to correct category for event
- **Context matching:** Bark must match current ship state (HP, systems, phase)
- **No repetition:** Same bark can't be used twice in one battle
- **Fallback chain:** Specific → Generic → Null
- **Writing style:** 3-7 words, military professional, reactive not proactive

### Edge Cases
- **All barks used:** Fall back to generic barks ("Taking damage!", "Systems failing!")
- **No matching barks:** Return null (no bark plays this event)
- **Multiple valid barks:** Random selection for variety
- **Context mismatch:** Skip bark even if category matches

---

## Bark Categories

### Category 1: DAMAGE REPORTS (System Failures)
**When:** Component destroyed or disabled
**Who:** Engineering / Damage Control
**Context:** Any HP, specific component types

```gdscript
const DAMAGE_REPORTS = [
    {
        "text": "Main reactor offline!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.HIGH,
        "component": RoomData.RoomType.REACTOR,
    },
    {
        "text": "We've lost main power!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.HIGH,
        "component": RoomData.RoomType.REACTOR,
    },
    {
        "text": "Shield generator destroyed!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.MEDIUM,
        "component": RoomData.RoomType.SHIELD,
    },
    {
        "text": "Shields are down!",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.MEDIUM,
        "component": RoomData.RoomType.SHIELD,
    },
    {
        "text": "Weapons offline!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.HIGH,
        "component": RoomData.RoomType.WEAPON,
    },
    {
        "text": "No response from weapon systems!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.HIGH,
        "component": RoomData.RoomType.WEAPON,
    },
    {
        "text": "Engines failing!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.MEDIUM,
        "component": RoomData.RoomType.ENGINE,
    },
    {
        "text": "We're dead in the water!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.MEDIUM,
        "component": RoomData.RoomType.ENGINE,
    },
    {
        "text": "Hull breach in engineering!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.MEDIUM,
        "component": null,  # Generic damage
    },
    {
        "text": "Life support failing!",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.HIGH,
        "component": null,
    },
    {
        "text": "Backup systems engaging!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.LOW,
        "component": null,
    },
]
```

---

### Category 2: TACTICAL UPDATES (Combat Progress)
**When:** Significant combat events
**Who:** Tactical / Weapons
**Context:** Damage dealt/taken, enemy status

```gdscript
const TACTICAL_UPDATES = [
    # Player attacking enemy
    {
        "text": "Direct hit on their hull!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.MEDIUM,
        "event": "enemy_damage",
    },
    {
        "text": "Enemy shields failing!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.MEDIUM,
        "event": "enemy_shields_low",
    },
    {
        "text": "Their weapons are down!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.MEDIUM,
        "event": "enemy_weapon_destroyed",
    },
    {
        "text": "Got their reactor!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.HIGH,
        "event": "enemy_reactor_destroyed",
    },
    {
        "text": "Enemy disarmed!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.MEDIUM,
        "event": "enemy_weapon_destroyed",
    },

    # Player taking damage
    {
        "text": "Taking heavy fire!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.MEDIUM,
        "event": "player_heavy_damage",
    },
    {
        "text": "Taking damage!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.LOW,
        "event": "player_damage",
    },
    {
        "text": "We're hit!",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.LOW,
        "event": "player_damage",
    },
    {
        "text": "Multiple hits!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.MEDIUM,
        "event": "player_heavy_damage",
    },
    {
        "text": "Armor's not holding!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.MEDIUM,
        "event": "player_heavy_damage",
        "context": {"min_hp": 0, "max_hp": 75},
    },
]
```

---

### Category 3: SYSTEM STATUS (Power/Resources)
**When:** Power loss, system failures, resource depletion
**Who:** Engineering / Operations
**Context:** Power grid state

```gdscript
const SYSTEM_STATUS = [
    {
        "text": "Power grid unstable!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.MEDIUM,
        "event": "power_loss",
    },
    {
        "text": "Rerouting emergency power!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.MEDIUM,
        "event": "power_loss",
    },
    {
        "text": "All systems running on backup!",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.HIGH,
        "event": "power_cascade",
    },
    {
        "text": "No power to weapons array!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.HIGH,
        "event": "weapon_unpowered",
    },
    {
        "text": "Shields holding at 20%!",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.MEDIUM,
        "event": "shields_low",
    },
    {
        "text": "We're running on fumes!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.HIGH,
        "event": "power_cascade",
    },
    {
        "text": "Multiple systems offline!",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.HIGH,
        "event": "power_cascade",
    },
]
```

---

### Category 4: CREW STRESS (Ship State)
**When:** HP thresholds or multiple systems failing
**Who:** Various stations
**Context:** Ship HP percentage

```gdscript
const CREW_STRESS = [
    # 75% HP threshold
    {
        "text": "Hull integrity compromised!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.HIGH,
        "hp_threshold": 75,
    },
    {
        "text": "Taking damage!",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.MEDIUM,
        "hp_threshold": 75,
    },

    # 50% HP threshold
    {
        "text": "Hull integrity at 50%!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.HIGH,
        "hp_threshold": 50,
    },
    {
        "text": "We can't take much more!",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.HIGH,
        "hp_threshold": 50,
    },
    {
        "text": "This is bad...",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.MEDIUM,
        "hp_threshold": 50,
    },

    # 25% HP threshold
    {
        "text": "Critical damage!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.CRITICAL,
        "hp_threshold": 25,
    },
    {
        "text": "We're coming apart!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.CRITICAL,
        "hp_threshold": 25,
    },
    {
        "text": "Structural failure imminent!",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.CRITICAL,
        "hp_threshold": 25,
    },
    {
        "text": "We need to get out of here!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.HIGH,
        "hp_threshold": 25,
    },

    # Multiple systems lost
    {
        "text": "Half our systems are gone!",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.HIGH,
        "event": "multiple_systems_lost",
    },
    {
        "text": "We're fighting blind!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.HIGH,
        "event": "multiple_systems_lost",
    },
    {
        "text": "Nothing's responding!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.HIGH,
        "event": "multiple_systems_lost",
    },
]
```

---

### Category 5: VICTORY/DEFEAT
**When:** Battle ends
**Who:** Captain / Command
**Context:** Battle outcome

```gdscript
const VICTORY_DEFEAT = [
    # Victory
    {
        "text": "Target destroyed!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.CRITICAL,
        "outcome": "victory",
    },
    {
        "text": "Enemy down!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.CRITICAL,
        "outcome": "victory",
    },
    {
        "text": "We did it!",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.CRITICAL,
        "outcome": "victory",
    },
    {
        "text": "All stations, stand down.",
        "role": CrewRole.CAPTAIN,
        "priority": BarkPriority.CRITICAL,
        "outcome": "victory",
    },
    {
        "text": "Threat eliminated!",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.CRITICAL,
        "outcome": "victory",
    },

    # Defeat
    {
        "text": "We're losing—",
        "role": CrewRole.TACTICAL,
        "priority": BarkPriority.CRITICAL,
        "outcome": "defeat",
    },
    {
        "text": "Abandon—",
        "role": CrewRole.CAPTAIN,
        "priority": BarkPriority.CRITICAL,
        "outcome": "defeat",
    },
    {
        "text": "Brace for—",
        "role": CrewRole.OPERATIONS,
        "priority": BarkPriority.CRITICAL,
        "outcome": "defeat",
    },
]
```

---

## Context-Aware Selection Logic

### BarkSelector Algorithm

```gdscript
# BarkSelector.gd
class_name BarkSelector

static func select_for_component_destroyed(component_type: RoomData.RoomType) -> BarkData:
    var eligible_barks = []

    # Get all damage report barks for this component
    for bark_dict in BarkDatabase.DAMAGE_REPORTS:
        if bark_dict["component"] == component_type or bark_dict["component"] == null:
            # Check if not already used
            if not CrewBarkSystem.used_barks.has(bark_dict["text"]):
                eligible_barks.append(bark_dict)

    # No eligible barks? Try generic
    if eligible_barks.is_empty():
        for bark_dict in BarkDatabase.DAMAGE_REPORTS:
            if bark_dict["component"] == null:  # Generic
                if not CrewBarkSystem.used_barks.has(bark_dict["text"]):
                    eligible_barks.append(bark_dict)

    # Still none? Return null (no bark)
    if eligible_barks.is_empty():
        return null

    # Random selection from eligible
    var selected = eligible_barks.pick_random()
    return _bark_dict_to_data(selected)

static func select_for_hp_threshold(threshold: int) -> BarkData:
    var eligible_barks = []

    # Get all crew stress barks for this HP threshold
    for bark_dict in BarkDatabase.CREW_STRESS:
        if bark_dict.get("hp_threshold") == threshold:
            if not CrewBarkSystem.used_barks.has(bark_dict["text"]):
                eligible_barks.append(bark_dict)

    if eligible_barks.is_empty():
        return null

    var selected = eligible_barks.pick_random()
    return _bark_dict_to_data(selected)

static func select_for_event(event_type: String, context: Dictionary = {}) -> BarkData:
    var eligible_barks = []

    # Search all categories for matching event
    for category in [BarkDatabase.DAMAGE_REPORTS, BarkDatabase.TACTICAL_UPDATES,
                     BarkDatabase.SYSTEM_STATUS, BarkDatabase.CREW_STRESS]:
        for bark_dict in category:
            if bark_dict.get("event") == event_type:
                # Check context requirements
                if _matches_context(bark_dict, context):
                    if not CrewBarkSystem.used_barks.has(bark_dict["text"]):
                        eligible_barks.append(bark_dict)

    if eligible_barks.is_empty():
        return null

    var selected = eligible_barks.pick_random()
    return _bark_dict_to_data(selected)

static func _matches_context(bark_dict: Dictionary, context: Dictionary) -> bool:
    # Check HP context if specified
    if bark_dict.has("context"):
        var bark_context = bark_dict["context"]
        if bark_context.has("min_hp") and context.has("hp_percent"):
            if context["hp_percent"] < bark_context["min_hp"]:
                return false
        if bark_context.has("max_hp") and context.has("hp_percent"):
            if context["hp_percent"] > bark_context["max_hp"]:
                return false

    return true

static func _bark_dict_to_data(bark_dict: Dictionary) -> BarkData:
    var bark = BarkData.new()
    bark.text = bark_dict["text"]
    bark.role = bark_dict["role"]
    bark.priority = bark_dict["priority"]
    bark.audio_file = bark_dict.get("audio_file", "")
    return bark
```

---

## Technical Implementation

### Scene Structure
```
BarkDatabase.gd (Static class, no scene)
BarkSelector.gd (Static class, no scene)
```

### Data Structures

```gdscript
# BarkDatabase.gd
class_name BarkDatabase

# All bark dictionaries (50 total for MVP)
const DAMAGE_REPORTS: Array = [...]
const TACTICAL_UPDATES: Array = [...]
const SYSTEM_STATUS: Array = [...]
const CREW_STRESS: Array = [...]
const VICTORY_DEFEAT: Array = [...]

# Helper to get all barks for a category
static func get_barks_for_category(category: BarkCategory) -> Array:
    match category:
        BarkCategory.DAMAGE_REPORT:
            return DAMAGE_REPORTS
        BarkCategory.TACTICAL_UPDATE:
            return TACTICAL_UPDATES
        BarkCategory.SYSTEM_STATUS:
            return SYSTEM_STATUS
        BarkCategory.CREW_STRESS:
            return CREW_STRESS
        BarkCategory.VICTORY_DEFEAT:
            return VICTORY_DEFEAT
    return []
```

---

## Writing Guidelines

### DO:
- ✅ Keep it brief (3-7 words)
- ✅ Use technical/military language ("Hull breach", "Reactor offline")
- ✅ Report facts, not opinions ("Shields at 20%", not "Shields are weak")
- ✅ Show stress through word choice, not exclamation spam
- ✅ Make it sound like people doing jobs

### DON'T:
- ❌ Give advice ("We should target their shields!")
- ❌ Use names ("Stevens, get that power back on!")
- ❌ Tell jokes or quip ("Well, that's not good...")
- ❌ Break character (stay professional military)
- ❌ Make it chatty ("Hey guys, we got a problem here...")

### Examples:

**GOOD:**
- "Main reactor offline!" (factual, brief, professional)
- "Taking heavy fire!" (urgent but controlled)
- "Enemy shields failing!" (tactical observation)

**BAD:**
- "Oh no, the reactor's down!" (unprofessional, emotional)
- "Hey, we should probably target their reactor next!" (strategic advice)
- "Stevens, can you get that reactor back online?" (uses names, conversational)

---

## Acceptance Criteria

Feature is complete when:

- [ ] BarkDatabase contains at least 50 unique barks across 5 categories
- [ ] BarkSelector correctly filters barks by event type
- [ ] BarkSelector respects context requirements (HP, component type)
- [ ] BarkSelector prevents repetition (checks used_barks)
- [ ] BarkSelector falls back to generic barks when specific exhausted
- [ ] Returns null when no eligible barks (doesn't crash)
- [ ] Random selection provides variety across multiple playthroughs
- [ ] All bark text follows writing guidelines (3-7 words, professional)
- [ ] Role assignments make sense (Engineering for reactor, Tactical for weapons)
- [ ] Priority assignments match event severity

---

## Testing Checklist

### Functional Tests
- [ ] **Test 1:** Destroy reactor 3 times in 3 battles → different barks each time
- [ ] **Test 2:** Destroy reactor 5 times in 1 battle (if possible) → no repetition
- [ ] **Test 3:** Cross 50% HP → stress bark plays
- [ ] **Test 4:** Victory → victory bark plays
- [ ] **Test 5:** Exhaust all reactor barks → generic backup plays

### Content Quality Tests
- [ ] **Test 6:** All barks are 3-7 words
- [ ] **Test 7:** No barks give strategic advice
- [ ] **Test 8:** No barks use crew names
- [ ] **Test 9:** Tone matches ship state (confident at 100% HP, desperate at 10% HP)
- [ ] **Test 10:** Role assignments feel logical (read 10 random barks, check roles)

### Context Tests
- [ ] **Test 11:** HP-specific barks only play at correct HP thresholds
- [ ] **Test 12:** Component-specific barks only play for correct components
- [ ] **Test 13:** Generic barks play for any event when specific unavailable

---

## Known Limitations

- **Limited variety at MVP:** 50 barks total, can feel repetitive in long play sessions (Phase 3 adds +50)
- **No dynamic generation:** Barks are hand-written, not procedurally generated
- **English only:** No localization for MVP (Phase 4)
- **No gender-neutral option:** Assumes gendered voice roles (future: gender-neutral voices)

---

## Future Enhancements

*(Not for MVP, but worth noting)*

- **Expanded bark library:** 200+ barks for greater variety
- **Localization:** Translate barks to Spanish, French, German, etc.
- **Dynamic bark composition:** Combine fragments ("Multiple systems" + "offline" = "Multiple systems offline!")
- **Player-customizable writing style:** Choose between "military professional" vs "casual crew"
- **AI-generated contextual barks:** GPT integration for unique barks per battle (experimental)

---

## Implementation Notes

**Important details:**
- Store barks as static constants (no need for JSON files for MVP - adds complexity)
- Use dictionaries for easy extension (adding "audio_file" field later is trivial)
- Role assignment matters for voice differentiation (even if text-only MVP)

**Gotchas to watch out for:**
- `pick_random()` on empty array crashes - always check `is_empty()` first
- Context matching can fail silently - test thoroughly with debug prints
- Generic fallbacks can run out too - need ultimate fallback (return null, no bark)

**Alternative approach considered but rejected:**
- **JSON bark database:** Rejected for MVP (adds file loading complexity, harder to debug)
- **Procedural generation:** Rejected (requires AI, out of scope)
- **Role-specific databases:** Rejected (harder to maintain, no benefit for MVP)

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-01-04 | Initial spec | Sub-feature defined for crew barks MVP |
