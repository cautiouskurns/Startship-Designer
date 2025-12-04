# Crew Barks Sub-Feature: Dynamic Context-Aware Barks

**Status:** 🔴 Planned
**Priority:** ⬇️ Low (Phase 3, polish)
**Estimated Time:** 6-8 hours
**Dependencies:** Bark Content (1.2)
**Assigned To:** TBD
**Parent Feature:** [Anonymous Crew Barks System](crew_barks_system.md)

---

## Purpose

Adds barks that react to player's design quality, mission type, and combat situation. Creates dynamic feedback loop where crew comments on your design decisions ("Power routing is solid!" vs "Who designed this thing?!").

---

## How It Works

BarkSelector evaluates ship design quality (power coverage, synergy count, budget efficiency) and selects barks that reflect crew's assessment. Adds mission-specific barks (escort, boss battle) and design-commentary barks that trigger once per battle.

---

## Bark Categories Added

### Design Quality Barks (once per battle)

**Good Design (>80% powered, multiple synergies):**
```gdscript
{
    "text": "Power routing is solid!",
    "role": CrewRole.ENGINEERING,
    "trigger": "battle_start",
    "context": {"min_power_coverage": 80, "min_synergies": 3},
},
{
    "text": "All systems at full capacity!",
    "role": CrewRole.OPERATIONS,
    "trigger": "battle_start",
    "context": {"min_power_coverage": 90},
},
{
    "text": "This ship's a beast!",
    "role": CrewRole.TACTICAL,
    "trigger": "battle_start",
    "context": {"min_synergies": 5},
},
```

**Bad Design (<50% powered, no synergies):**
```gdscript
{
    "text": "Why isn't this powered?!",
    "role": CrewRole.ENGINEERING,
    "trigger": "battle_start",
    "context": {"max_power_coverage": 50},
},
{
    "text": "I've got nothing here!",
    "role": CrewRole.TACTICAL,
    "trigger": "first_weapon_fire",
    "context": {"powered_weapons": 0},
},
{
    "text": "Who designed this thing?!",
    "role": CrewRole.OPERATIONS,
    "trigger": "battle_start",
    "context": {"max_power_coverage": 30},
},
```

### Mission-Specific Barks

**Escort Mission:**
```gdscript
{
    "text": "The convoy's taking fire!",
    "role": CrewRole.TACTICAL,
    "trigger": "convoy_damaged",
},
{
    "text": "Protect those transports!",
    "role": CrewRole.CAPTAIN,
    "trigger": "battle_start",
},
```

**Boss Battle:**
```gdscript
{
    "text": "That thing is massive!",
    "role": CrewRole.TACTICAL,
    "trigger": "battle_start",
    "context": {"enemy_size": "large"},
},
{
    "text": "Our weapons aren't even scratching it!",
    "role": CrewRole.TACTICAL,
    "trigger": "low_damage_dealt",
    "context": {"enemy_armor": "heavy"},
},
```

---

## Technical Implementation

### Design Quality Evaluation

```gdscript
# In BarkSelector.gd
static func get_design_quality_context(ship_data: ShipData) -> Dictionary:
    var total_rooms = ship_data.get_total_rooms()
    var powered_rooms = ship_data.get_powered_rooms()
    var synergies = ship_data.calculate_synergy_bonuses()["counts"]
    var synergy_count = 0
    for s in synergies.values():
        synergy_count += s

    var power_coverage = (powered_rooms / float(total_rooms)) * 100 if total_rooms > 0 else 0

    return {
        "power_coverage": power_coverage,
        "synergy_count": synergy_count,
        "powered_weapons": ship_data.get_powered_weapon_count(),
        "design_quality": _calculate_design_quality(power_coverage, synergy_count),
    }

static func _calculate_design_quality(power_coverage: float, synergies: int) -> String:
    if power_coverage >= 80 and synergies >= 3:
        return "excellent"
    elif power_coverage >= 60 and synergies >= 1:
        return "good"
    elif power_coverage >= 40:
        return "acceptable"
    else:
        return "poor"

# Select design-quality bark at battle start
static func select_design_commentary_bark(ship_data: ShipData) -> BarkData:
    var context = get_design_quality_context(ship_data)
    var eligible_barks = []

    for bark_dict in BarkDatabase.DESIGN_COMMENTARY:
        if _matches_context(bark_dict, context):
            eligible_barks.append(bark_dict)

    if eligible_barks.is_empty():
        return null

    return _bark_dict_to_data(eligible_barks.pick_random())
```

---

## Acceptance Criteria

- [ ] Design-quality barks trigger once at battle start
- [ ] Good design (>80% powered, 3+ synergies) → positive bark
- [ ] Bad design (<50% powered, 0 synergies) → negative bark
- [ ] Mission-specific barks only play in correct mission types
- [ ] Boss battle barks trigger when fighting large enemies
- [ ] Barks reflect actual ship state (no false positives)
- [ ] Design commentary doesn't repeat in same battle

---

## Testing Checklist

- [ ] Design ship with 100% power + 5 synergies → hear "This ship's a beast!"
- [ ] Design ship with 30% power + 0 synergies → hear "Who designed this thing?!"
- [ ] Play escort mission → hear "Protect those transports!"
- [ ] Fight dreadnought → hear "That thing is massive!"

---

## Known Limitations

- **Static evaluation:** Design quality calculated once at battle start (doesn't update mid-battle)
- **Limited mission types:** Only supports generic, escort, boss (no others)
- **No sarcasm:** Can't detect intentionally bad designs for humor

---

## Future Enhancements

- Dynamic quality updates (crew comments when design flaws revealed mid-battle)
- Player reputation system (crew trusts you more after wins)
- Expanded mission types (survival, stealth, siege)

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-01-04 | Initial spec | Phase 3 dynamic barks feature |
