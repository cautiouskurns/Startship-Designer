# Component Tags System

**Status:** 🔴 Planned
**Priority:** ⬆️ High (Enables advanced filtering and mechanics)
**Estimated Time:** 3-4 hours
**Dependencies:** Seven-Category Structure
**Assigned To:** Development Team

---

## Purpose

**Why does this feature exist?**
Categories organize components for UI browsing, but components have multiple properties that don't fit into a single category. Tags provide a flexible system for describing component mechanics, enabling advanced filtering and game logic.

**What does it enable?**
- Multi-dimensional component properties (requires power AND active combat AND synergy-capable)
- Advanced filtering ("Show me all components that don't need power")
- Strategic component discovery ("Which components can go on the ship edge?")
- Future-proof mechanic flagging (add new tags without restructuring categories)
- Clear game logic (check tags instead of hardcoded component types)

**Success criteria:**
- 13 mechanical tags defined covering power, combat, placement, and special properties
- All 9 existing components tagged appropriately
- Multiple tags can apply to one component (Bridge has 4 tags)
- Tags enable clear game logic (if REQUIRES_POWER tag → check adjacency to power source)
- Players can understand tag meanings from names and tooltips

---

## How It Works

### Overview

Tags are **properties** that describe how a component behaves mechanically. Unlike categories (which group for browsing), tags are used for:

1. **Game logic**: "Does this component need power?" → Check REQUIRES_POWER tag
2. **Filtering**: "Show only components that participate in synergies"
3. **Strategic guidance**: "This component is VULNERABLE_CORE → place it in ship interior"
4. **Constraints**: "REQUIRED tag → ship must have at least one"

Components can have **0 to many** tags. Bridge has 4 tags (REQUIRES_POWER, REQUIRED, UNIQUE, VULNERABLE_CORE). Armor has 1 tag (PASSIVE_COMBAT). Conduit has 2 tags (REQUIRES_POWER, DISTRIBUTES_POWER).

Tags are **not hierarchical**—there's no parent/child relationship. They're independent flags that combine to describe component behavior.

### The 13 Core Tags

**Power-Related Tags:**
- **REQUIRES_POWER**: Component must be adjacent to power source to function (Weapons, Shields, Engines, Bridge)
- **GENERATES_POWER**: Produces power for adjacent components (Reactor)
- **DISTRIBUTES_POWER**: Routes power from generators to consumers (Relay, Conduit)

**Combat Behavior Tags:**
- **ACTIVE_COMBAT**: Directly participates in combat turns (Weapons deal damage, Shields absorb damage)
- **PASSIVE_COMBAT**: Provides always-on bonuses (Armor adds HP, Engines add initiative)
- **CONSUMES_AMMO**: Needs ammunition to function (Future: Torpedoes, Missiles)

**Placement Strategy Tags:**
- **VULNERABLE_EDGE**: Works better or is designed for hull edge placement (Weapons face forward, Engines in rear)
- **VULNERABLE_CORE**: Should be protected in ship interior (Reactor, Bridge critical to survival)

**Special Constraint Tags:**
- **REQUIRED**: Ship must have at least one to function (Bridge)
- **UNIQUE**: Only one allowed per ship (Bridge, for now)

**Synergy Participation Tags:**
- **SYNERGY_WEAPON**: Participates in weapon synergies (Fire Rate bonus when adjacent to other weapons)
- **SYNERGY_DEFENSE**: Participates in defense synergies (Shield Capacity bonus when shield adjacent to reactor)
- **SYNERGY_POWER**: Participates in power synergies (Future: reactor efficiency bonuses)

### User Flow

```
1. Player hovers over Bridge component in palette
2. System displays tooltip with tags: "🏷️ Requires Power, Required, Unique, Core Placement"
3. Player sees VULNERABLE_CORE tag
4. Player understands: "I should place this in the ship interior, not on the edge"
5. Result: Tags inform strategic placement decisions
```

### Rules & Constraints

- Tags describe **what a component is**, not what it does (ACTIVE_COMBAT tag means "participates in combat", not "deals 10 damage")
- Tags are **binary**: A component either has a tag or doesn't (no partial tags or tag intensity)
- Tags can **combine**: REQUIRES_POWER + GENERATES_POWER is valid (future: components that need startup power but then generate)
- Tags are **immutable** per component: Bridge always has REQUIRED tag, can't be removed or changed
- New tags can be added over time without breaking existing components

### Edge Cases

- What if a component has conflicting tags?
  → Some combinations are logical (REQUIRES_POWER + GENERATES_POWER = conditional generator). Some are illogical (REQUIRED + UNIQUE + multiple instances = impossible). Validation catches illogical combinations.

- What if we need a tag that doesn't exist?
  → Add new tag to enum. Existing components unaffected (tags are additive).

- What if players don't understand what a tag means?
  → Each tag has tooltip explaining its gameplay effect. Example: "VULNERABLE_EDGE: Best placed on hull edge facing enemies"

---

## User Interaction

### Controls

- **Hover over component**: Tooltip shows tags with icons
- **Click tag icon**: Expands full tag description
- **Filter by tag** (separate feature): Toggle tag filters to show only components with specific tags

### Visual Feedback

- **Tags in tooltip**: Small badge icons (🏷️) with abbreviated tag names
- **Tag colors**: Color-coded by category
  - Power tags: Yellow
  - Combat tags: Red/Cyan
  - Placement tags: Orange
  - Special tags: Purple
  - Synergy tags: Green

### Audio Feedback

- **Hover over tag**: Soft "ting" (informational)
- No audio for tag assignment (happens behind the scenes)

---

## Visual Design

### Layout

**Component Tooltip with Tags:**
```
┌────────────────────────────────────┐
│ ⚡ REACTOR                          │
│ Category: Power Systems            │
│ Cost: 4 | Size: 3×2 | HP: 100      │
├────────────────────────────────────┤
│ Generates 100 power for adjacent   │
│ systems. Essential for powering    │
│ weapons, shields, and engines.     │
├────────────────────────────────────┤
│ 🏷️ Tags:                           │
│   • Generates Power [⚡]            │
│   • Vulnerable Core [🔒]           │
│   • Power Synergy [🔗]             │
└────────────────────────────────────┘
```

### Components

- **Tag Badge**: Small rounded rectangle with icon + abbreviated name
- **Tag List**: Vertical list in tooltip, bullet points
- **Tag Icon**: Emoji or symbol representing tag category

### Visual Style

- **Colors**: Tags colored by type (power = yellow, combat = red, etc.)
- **Fonts**: Tag names in 10pt, regular weight
- **Animations**: None (static display in tooltip)

### States

- **Default**: Tag shown as text with icon
- **Hover** (if clickable): Underline + expand full description
- **Active** (in filter): Highlighted in cyan

---

## Technical Implementation

### Scene Structure

(No new scenes—tags are data properties)

### Script Responsibilities

- **ComponentTag.gd**: Enum defining 13 tags + helper functions (get_name, get_description, get_color, get_icon)
- **RoomData.gd**: Extended with `get_tags(room_type)` function returning Array of tags for each component
- **ComponentMetadata.gd**: Stores tags as part of component data

### Data Structures

```gdscript
enum Tag {
    REQUIRES_POWER,
    GENERATES_POWER,
    DISTRIBUTES_POWER,
    ACTIVE_COMBAT,
    PASSIVE_COMBAT,
    CONSUMES_AMMO,
    VULNERABLE_EDGE,
    VULNERABLE_CORE,
    REQUIRED,
    UNIQUE,
    SYNERGY_WEAPON,
    SYNERGY_DEFENSE,
    SYNERGY_POWER,
}
```

### Integration Points

- Connects to: RoomData (component definitions), Combat system (checks ACTIVE_COMBAT tag), Power system (checks REQUIRES_POWER tag)
- Emits signals: None (tags are passive data)
- Listens for: None
- Modifies: Component validation logic (REQUIRED tag enforces Bridge rule)

### Configuration

- Tag definitions: `scripts/data/ComponentTag.gd`
- Component tag assignments: `scripts/data/RoomData.gd` (get_tags function)
- Tag colors/icons: Constants in ComponentTag.gd

---

## Acceptance Criteria

Feature is complete when:

- [ ] 13 tags defined with clear names, descriptions, and icons
- [ ] All 9 existing components have appropriate tags assigned
- [ ] Multiple tags can apply to one component (Bridge has 4)
- [ ] Component tooltips display tags in readable format
- [ ] Game logic uses tags instead of hardcoded component checks (e.g., power routing checks REQUIRES_POWER tag)
- [ ] Adding new components automatically includes their tags in tooltips
- [ ] Tags provide strategic guidance to players (placement hints, synergy potential)

---

## Testing Checklist

### Functional Tests

- [ ] Bridge has tags: REQUIRES_POWER, REQUIRED, UNIQUE, VULNERABLE_CORE (4 tags)
- [ ] Reactor has tags: GENERATES_POWER, VULNERABLE_CORE, SYNERGY_POWER (3 tags)
- [ ] Weapon has tags: REQUIRES_POWER, ACTIVE_COMBAT, VULNERABLE_EDGE, SYNERGY_WEAPON (4 tags)
- [ ] Shield has tags: REQUIRES_POWER, ACTIVE_COMBAT, SYNERGY_DEFENSE (3 tags)
- [ ] Engine has tags: REQUIRES_POWER, PASSIVE_COMBAT, VULNERABLE_EDGE (3 tags)
- [ ] Armor has tags: PASSIVE_COMBAT (1 tag)
- [ ] Conduit has tags: REQUIRES_POWER, DISTRIBUTES_POWER (2 tags)
- [ ] Relay has tags: REQUIRES_POWER, DISTRIBUTES_POWER, SYNERGY_POWER (3 tags)
- [ ] All components have at least 1 tag

### Edge Case Tests

- [ ] Component with 0 tags: Should be allowed (future: basic hull plating)
- [ ] Component with 5+ tags: Should work (no arbitrary limit)
- [ ] Tag validation: REQUIRED + UNIQUE but multiple instances → caught and flagged
- [ ] New tag added: Existing components unaffected (backward compatible)

### Integration Tests

- [ ] Power routing checks REQUIRES_POWER tag to determine if component needs power
- [ ] Combat system checks ACTIVE_COMBAT vs PASSIVE_COMBAT to determine behavior
- [ ] Synergy detection checks SYNERGY_* tags to identify synergy participants
- [ ] Ship validation checks REQUIRED tag to enforce Bridge rule

### Polish Tests

- [ ] Tag icons clear and distinguishable
- [ ] Tag descriptions helpful for gameplay decisions
- [ ] Tag colors consistent with category scheme
- [ ] Tooltip layout clean (tags don't clutter other information)

---

## Known Limitations

- **Tag explosion risk**: If we add too many tags (50+), system becomes unwieldy. Solution: Keep tags at high level (ACTIVE_COMBAT, not DEALS_DAMAGE_TYPE_ENERGY)
- **Tag conflicts**: Some tag combinations don't make sense (REQUIRED + UNIQUE + placed multiple times). Validation catches this but doesn't prevent assignment.
- **Tag vs property overlap**: Some tags duplicate existing properties (GENERATES_POWER tag vs power_generation = 100 property). This is intentional—tags are for **filtering/logic**, properties are for **numeric values**.

---

## Future Enhancements

*(Not for MVP, but worth noting)*

- **Tag-based filtering UI**: Filter components by tag (show only REQUIRES_POWER components)
- **Tag-based sort**: Sort components by number of tags or specific tag type
- **Tag descriptions in-game glossary**: Reference document listing all tags with examples
- **Visual tag indicators on grid**: Show VULNERABLE_CORE components with shield icon when placed
- **Tag-based achievements**: "Place 10 SYNERGY_WEAPON components in one ship"

---

## Implementation Notes

*(For AI assistant or future you)*

- **Why 13 tags?**: Covers essential mechanics without being overwhelming. Can grow to 20-25 as game expands.
- **Why separate tags from categories?**: Categories = UI organization (browsing), Tags = mechanics (filtering, logic). Separation keeps each system focused.
- **Why not use tags as categories?**: Too many tags (13) for browsing. Players would need to memorize which tags group which components. Categories provide faster discovery.
- **Alternative considered**: Properties only (no tags). Rejected because checking `if component.power_generation > 0` is less clear than `if component.has_tag(GENERATES_POWER)`. Tags are explicit, self-documenting.
- **Gotcha**: Don't over-rely on tags for game logic. If logic is complex (e.g., "weapons deal damage = weapon_count × 10"), use properties. Tags are for **categorization**, not **calculation**.

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 4, 2024 | Initial spec | Tag system needed for flexible component mechanics |
