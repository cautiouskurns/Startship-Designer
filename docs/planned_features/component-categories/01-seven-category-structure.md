# Seven-Category Component Structure

**Status:** 🔴 Planned
**Priority:** 🔥 Critical (Prerequisite for content expansion)
**Estimated Time:** 2-3 hours
**Dependencies:** None (refactors existing system)
**Assigned To:** Development Team

---

## Purpose

**Why does this feature exist?**
The current flat list of 9 components lacks organization and won't scale to 30-40+ components. Players need clear functional categories to understand what components do and find them quickly in the UI.

**What does it enable?**
- Intuitive grouping of components by role (Power, Weapons, Defense, etc.)
- Scalable structure that supports 40+ components without UI redesign
- Clear mental model for players ("I need offense → look in Weapons category")
- Foundation for advanced filtering, sorting, and search features

**Success criteria:**
- All 9 existing components categorized into 7 clear groups
- Players can explain what each category does in one sentence
- New components can be added to categories without confusion
- Categories align with existing game systems (power routing, combat, synergies)

---

## How It Works

### Overview

The seven-category structure organizes all ship components into functional groups based on their primary role. Each category has a distinct purpose, visual icon, and represents a strategic choice area in ship design.

Categories are **not** hierarchical or nested—every component belongs to exactly one category. This flat structure keeps the system simple while providing enough granularity for 40+ components.

Categories serve **UI organization** purposes (what players see) while a separate tag system handles **mechanical filtering** (how the game uses component properties).

### The Seven Categories

**⊕ Power Systems** - Generate, store, and distribute power
- Current: Reactor, Relay, Conduit
- Role: Enable other systems, core puzzle mechanic
- Trade-off: Power infrastructure vs combat capability

**▶ Weapons** - Deal damage to enemy ships
- Current: Weapon (energy)
- Role: Offensive capability
- Trade-off: Damage output vs power consumption and cost

**◆ Defense** - Absorb damage and protect the ship
- Current: Shield, Armor
- Role: Survivability
- Trade-off: Shields (regenerating) vs Armor (permanent HP)

**▲ Propulsion** - Control initiative, speed, and maneuverability
- Current: Engine
- Role: Turn order, future evasion mechanics
- Trade-off: Shooting first vs other combat stats

**⭐ Command & Control** - Required systems, sensors, targeting
- Current: Bridge
- Role: Ship operation enablers
- Trade-off: Basic (Bridge only) vs enhanced (sensors, computers)

**◇ Utility & Support** - Special functions, mission-specific modules
- Current: None yet
- Role: Quality of life, optimization, campaign features
- Trade-off: Specialized capability vs combat effectiveness

**■ Structure** - Hull framework, compartments, passive systems
- Current: None yet (Armor could fit here but works better in Defense)
- Role: Low-cost filler, structural integrity
- Trade-off: Cheap HP boost vs functional rooms

### User Flow

```
1. Player opens Ship Designer
2. System displays component palette with 7 category tabs
3. Player clicks "⊕ Power" tab
4. System shows only Power components (Reactor, Relay, Conduit)
5. Player clicks "▶ Weapons" tab
6. System switches view to show only Weapons
7. Result: Player finds components intuitively by function
```

### Rules & Constraints

- Every component belongs to exactly **one** category (no overlap)
- Categories are fixed (players cannot create custom categories)
- Category assignment based on **primary function** (Reactor generates power → Power Systems)
- Components with multiple functions go in category matching their **most important** role
- Bridge always in Command & Control even though it needs power (command is its primary role)

### Edge Cases

- What if a component fits multiple categories?
  → Use primary function rule. Sensor Array gives accuracy (combat support) but goes in Command because it's a control system

- What if we add a completely new type of component that doesn't fit?
  → Utility & Support is the catch-all for novel mechanics

- What if players can't find a component?
  → Search and tag filters (separate feature) help discover components across categories

---

## User Interaction

### Controls

- **Click category tab**: Switch to that category's component list
- **Keyboard numbers (1-7)**: Quick switch between categories
- **Tab key**: Cycle through categories

### Visual Feedback

- **Selected category**: Tab highlighted in cyan, category name displayed large at top
- **Unselected categories**: Default gray/white color
- **Category description**: Subtitle text explains category purpose
- **Component count**: Badge showing "5 components" in this category

### Audio Feedback

- **Tab click**: Soft "blip" sound (UI navigation)
- **Category switch**: Quiet "whoosh" (content transition)

---

## Visual Design

### Layout

```
Category Tab Bar (spans full width):
┌───────────────────────────────────────────────────┐
│ [⊕] [▶] [◆] [▲] [⭐] [◇] [■]                      │
└───────────────────────────────────────────────────┘

Category Header:
┌───────────────────────────────────────────────────┐
│ ⊕ POWER SYSTEMS                                   │
│ Generate, store, and distribute power             │
│ 3 components available                            │
└───────────────────────────────────────────────────┘

Component List (scrollable):
┌───────────────────────────────────────────────────┐
│ [Reactor]  [Relay]  [Conduit]                     │
│                                                    │
│ (filtered to show only Power Systems)             │
└───────────────────────────────────────────────────┘
```

### Components

- **Category Tab Button**: Icon + tooltip with full category name
- **Category Header Panel**: Large category name + icon + description + count
- **Component Grid**: Scrollable list of components in this category
- **Category Badge**: Small number showing component count per category

### Visual Style

- **Colors**: Each category has signature color
  - Power: Yellow/gold (#E2D44A)
  - Weapons: Red (#E24A4A)
  - Defense: Cyan (#4AE2E2)
  - Propulsion: Orange (#E2A04A)
  - Command: Blue (#4A90E2)
  - Utility: Green (#4AE24A)
  - Structure: Gray (#6C6C6C)

- **Fonts**: Category names in bold, all caps. Descriptions in normal case, smaller size.

- **Animations**: Smooth fade (0.2s) when switching categories

### States

- **Default tab**: Gray background, white icon
- **Hover tab**: Lighten background 10%
- **Active tab**: Cyan glow, category signature color for icon
- **Disabled tab**: Grayed out (if category has 0 components, future)

---

## Technical Implementation

### Scene Structure

```
RoomPalette (Panel)
├── CategoryTabContainer (HBoxContainer)
│   ├── PowerTab (Button)
│   ├── WeaponsTab (Button)
│   ├── DefenseTab (Button)
│   ├── PropulsionTab (Button)
│   ├── CommandTab (Button)
│   ├── UtilityTab (Button)
│   └── StructureTab (Button)
├── CategoryHeader (Panel)
│   ├── CategoryNameLabel (Label)
│   ├── CategoryDescLabel (Label)
│   └── ComponentCountLabel (Label)
└── ComponentScrollContainer (ScrollContainer)
    └── ComponentGrid (VBoxContainer)
```

### Script Responsibilities

- **ComponentCategory.gd**: Enum defining 7 categories + helper functions (get_name, get_icon, get_description, get_color)
- **RoomData.gd**: Extended with `get_category(room_type)` function mapping each component to its category
- **RoomPalette.gd**: Manages category tab UI, filters component list by selected category

### Data Structures

```gdscript
enum Category {
    POWER_SYSTEMS,
    WEAPONS,
    DEFENSE,
    PROPULSION,
    COMMAND_CONTROL,
    UTILITY_SUPPORT,
    STRUCTURE,
}
```

### Integration Points

- Connects to: Existing RoomData system (extends it with categories)
- Emits signals: `category_changed(new_category)` when player switches tabs
- Listens for: None (top-level UI organization)
- Modifies: Room palette display filter (shows/hides components)

### Configuration

- Category definitions: `scripts/data/ComponentCategory.gd`
- Component-to-category mapping: Added to existing `scripts/data/RoomData.gd`
- UI styling: Category colors in theme constants

---

## Acceptance Criteria

Feature is complete when:

- [ ] 7 categories defined with names, icons, descriptions, and colors
- [ ] All 9 existing components assigned to appropriate categories
- [ ] Category tabs appear in ship designer palette
- [ ] Clicking tab filters components to show only that category
- [ ] Selected tab visually highlighted
- [ ] Category header shows current category name + description + count
- [ ] Players can understand what each category contains without reading documentation
- [ ] System supports adding new components to any category without code changes

---

## Testing Checklist

### Functional Tests

- [ ] Click each of 7 category tabs: Component list updates to show only that category's components
- [ ] Click Power tab: Shows Reactor, Relay, Conduit (3 components)
- [ ] Click Weapons tab: Shows only Weapon (1 component)
- [ ] Click Defense tab: Shows Shield, Armor (2 components)
- [ ] Click Propulsion tab: Shows Engine (1 component)
- [ ] Click Command tab: Shows Bridge (1 component)
- [ ] Click Utility tab: Shows empty or "No components yet" message (0 components)
- [ ] Click Structure tab: Shows empty or "No components yet" message (0 components)

### Edge Case Tests

- [ ] Switch rapidly between tabs: No lag, no visual glitches
- [ ] Switch categories while placing a component: Previous selection cleared or maintained appropriately
- [ ] Add new component type to codebase: Appears in correct category automatically

### Integration Tests

- [ ] Works with existing room placement system (selecting component from filtered list still works)
- [ ] Doesn't break existing ship designer workflows (load template, place rooms, etc.)
- [ ] Category system doesn't interfere with synergy detection or power routing

### Polish Tests

- [ ] Tab switching animation smooth (0.2s fade)
- [ ] Category icons clearly visible and distinguishable
- [ ] Category descriptions helpful and concise
- [ ] Component count badge accurate
- [ ] UI responsive at 1280×720 and higher resolutions

---

## Known Limitations

- **Empty categories show no guidance**: Utility and Structure start empty. Future: Show "Coming soon" message with example components
- **No custom categories**: Players cannot create their own categories. This is intentional—fixed structure prevents organizational chaos
- **Category assignment can be subjective**: Sensor Array could be Weapons (accuracy boost) or Command (sensor system). Resolution: Primary function rule + clear documentation

---

## Future Enhancements

*(Not for MVP, but worth noting)*

- **Category unlocking**: Start with 4 categories, unlock Utility/Structure/advanced categories as progression
- **Favorite components**: Pin frequently-used components to appear in all categories
- **Recent components**: Show last 5 placed components regardless of category
- **Category badges**: Visual indicator on tab showing "3 new" or "1 upgraded" for new/updated components
- **Custom category colors**: Player preference for category color scheme (accessibility)

---

## Implementation Notes

*(For AI assistant or future you)*

- **Why 7 categories?**: Not too many (overwhelming), not too few (lacks organization). 7±2 is optimal for human categorization (Miller's Law)
- **Why flat structure?**: Nested categories (Energy Weapons → Lasers → Pulse Lasers) add complexity for minimal benefit at 40 components
- **Why geometric icons?**: Simple symbols that match existing room icons (⊕ for Reactor, ▶ for Weapon, etc.), clear even at small sizes, no emoji rendering issues
- **Alternative considered**: Functional tags only (no categories). Rejected because pure tag filtering requires too many clicks to find components. Categories provide faster browsing.
- **Gotcha**: Don't use category as a filter for game logic (use tags instead). Categories are UI-only. Example: Don't check "if component.category == WEAPONS" to calculate damage—check tags or component properties directly.

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 4, 2024 | Initial spec | Component organization needed for scalability |
