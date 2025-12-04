# Category-Based Component Palette UI

**Status:** 🔴 Planned
**Priority:** 🔥 Critical (Primary player interaction with categories)
**Estimated Time:** 4-6 hours
**Dependencies:** Seven-Category Structure, Component Tags System
**Assigned To:** Development Team

---

## Purpose

**Why does this feature exist?**
The current flat component list doesn't scale beyond 10-15 components. Players need a browsing interface that remains fast and intuitive with 40+ components. Category tabs provide instant filtering and clear organization.

**What does it enable?**
- Instant category switching with one click
- Visual component browsing without scrolling through everything
- Clear "where am I?" orientation (large category header)
- Fast component discovery (know category → find component in 5 seconds)
- Enhanced component information (larger buttons with stats, descriptions, tags)

**Success criteria:**
- Players can switch between 7 categories with single click
- Switching categories feels instant (< 0.2s)
- Component buttons show enough information to make informed choices without opening separate help
- New players understand category system without tutorial (self-evident design)
- System remains responsive with 40+ total components

---

## How It Works

### Overview

The Category-Based Palette replaces the current flat component list with a tabbed interface. The top of the palette shows 7 category tabs (one per category). Clicking a tab filters the component list to show only components in that category.

The interface has three visual zones:
1. **Category Tab Bar** (top): 7 buttons for switching categories
2. **Category Header** (middle): Large display showing current category name, icon, description
3. **Component Grid** (bottom, scrollable): Filtered list of components in current category

This three-zone layout provides context ("I'm in Weapons"), navigation (category tabs), and content (component buttons) in a compact space.

### User Flow

```
1. Player opens Ship Designer
2. System shows component palette, default to "Power Systems" category
3. Player sees: Tab bar (7 tabs), Header ("⚡ POWER SYSTEMS"), Component grid (Reactor, Relay, Conduit)
4. Player clicks "🎯 Weapons" tab
5. System highlights Weapons tab, updates header to "🎯 WEAPONS - Deal damage to enemy ships", filters grid to show Weapon
6. Player clicks Weapon component button
7. System selects weapon for placement on grid
8. Result: Player found weapon in 2 clicks (category + component)
```

### Rules & Constraints

- Default category on open: **Power Systems** (first category, most infrastructure)
- Empty categories (0 components): Show "No components yet - Coming soon!" message instead of empty grid
- Selected category persists: If player switches to designer → combat → back to designer, previously selected category still active
- Scrolling: Component grid scrollable if >6 components in category (keeps palette height reasonable)
- Keyboard shortcuts: Number keys 1-7 switch categories (1=Power, 2=Weapons, etc.)

### Edge Cases

- What if player places component while browsing different category?
  → Last selected component remains active regardless of category switch (category filter doesn't deselect)

- What if category has 1 component?
  → Still show tab and header (consistent UI). Single component displayed normally.

- What if all categories are empty (impossible but future-proof)?
  → Show message "No components available. Check game configuration." Prevents blank screen.

---

## User Interaction

### Controls

- **Click category tab**: Switch to that category, highlight tab, update header and grid
- **Keyboard 1-7**: Quick switch to category (1=Power, 2=Weapons, etc.)
- **Tab key**: Cycle through categories forward
- **Shift+Tab**: Cycle through categories backward
- **Click component button**: Select component for placement (same as current behavior)

### Visual Feedback

- **Selected tab**: Cyan glow, category signature color for icon
- **Hovered tab**: Background lightens 10%
- **Category switch**: Smooth fade transition (0.2s) between component grids
- **Component count badge**: Small number on each tab showing "3" components in that category
- **Empty category**: Grayed out tab (optional), "Coming soon" message in grid

### Audio Feedback

- **Tab click**: Soft "blip" (UI navigation)
- **Category switch**: Quiet "whoosh" (content transition)
- **Component select**: Existing sound (no change)

---

## Visual Design

### Layout

```
┌─────────────────────────────────────────────────────────┐
│ COMPONENT PALETTE                                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Category Tab Bar:                                       │
│ [⚡ 3] [🎯 1] [🛡️ 2] [🚀 1] [🖥️ 1] [🔧 0] [🏗️ 0]      │
│                                                         │
│ Category Header:                                        │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ⚡ POWER SYSTEMS                                     │ │
│ │ Generate, store, and distribute power               │ │
│ │ 3 components available                              │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ Component Grid (scrollable):                            │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ┌──────────┐  ┌──────────┐  ┌──────────┐           │ │
│ │ │ Reactor  │  │  Relay   │  │ Conduit  │           │ │
│ │ │  [4]     │  │  [3]     │  │  [1]     │           │ │
│ │ │ 3×2      │  │ 2×2      │  │ 1×1      │           │ │
│ │ │ 100 pwr  │  │ Distrib  │  │ Extends  │           │ │
│ │ └──────────┘  └──────────┘  └──────────┘           │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Components

- **Category Tab Button**: 60×40px button with emoji icon + component count badge
- **Category Header Panel**: 100px tall, full width, dark background, large category name + subtitle
- **Component Button**: 120×100px card with icon, name, cost, size, one-line description
- **Component Count Badge**: Small circle overlaying top-right of tab, shows number "3"
- **Scroll Bar**: Appears on component grid if >6 components

### Visual Style

- **Colors**:
  - Tab background (default): #2C2C2C dark gray
  - Tab background (selected): #1A1A1A darker + cyan glow
  - Header background: #0F1419 very dark blue-gray
  - Component button: #3C3C3C medium gray

- **Fonts**:
  - Category name: 24pt bold, all caps
  - Category description: 14pt regular, normal case
  - Component name: 16pt bold
  - Component stats: 12pt regular

- **Animations**:
  - Tab click: Instant highlight (no animation)
  - Grid switch: 0.2s fade out old grid, fade in new grid
  - Component hover: 0.1s lighten

### States

- **Default tab**: Dark gray background, white icon, count badge
- **Hover tab**: Background lightens to #3C3C3C
- **Active tab**: Darkest background (#1A1A1A), cyan glow (#4AE2E2), category-colored icon
- **Disabled tab** (0 components): Grayed out (optional), no hover effect
- **Default component button**: Medium gray background
- **Hover component button**: Background lightens to #4C4C4C
- **Selected component button**: Cyan border (same as current behavior)

---

## Technical Implementation

### Scene Structure

```
RoomPalette (Panel) - Existing scene, refactored
├── TitleLabel (Label) "COMPONENT PALETTE"
├── CategoryTabBar (HBoxContainer) NEW
│   ├── PowerTab (Button)
│   ├── WeaponsTab (Button)
│   ├── DefenseTab (Button)
│   ├── PropulsionTab (Button)
│   ├── CommandTab (Button)
│   ├── UtilityTab (Button)
│   └── StructureTab (Button)
├── CategoryHeader (Panel) NEW
│   ├── VBoxContainer
│   │   ├── CategoryNameLabel (Label)
│   │   ├── CategoryDescriptionLabel (Label)
│   │   └── ComponentCountLabel (Label)
└── ComponentScrollContainer (ScrollContainer) - Existing, modified
    └── ComponentGrid (VBoxContainer) - Existing, modified
        └── [ComponentButton × N] - Existing buttons, enhanced layout
```

### Script Responsibilities

- **RoomPalette.gd**: Manages category tabs, filters component list, handles tab clicks, keyboard shortcuts
- **ComponentCategory.gd**: Provides category data (names, icons, descriptions, colors)
- **RoomData.gd**: Provides component-to-category mapping
- **ComponentButton.gd**: Enhanced button layout with stats and tags (refactored from existing)

### Integration Points

- Connects to: ComponentCategory (data), RoomData (component definitions), existing component selection logic
- Emits signals: `category_changed(new_category)` when tab clicked
- Listens for: Component selection from grid (existing behavior)
- Modifies: Component grid visibility (shows/hides components based on category filter)

### Configuration

- Tab layout: Fixed 7 tabs, positions defined in scene
- Category data: ComponentCategory.gd provides all text/icons/colors
- Component buttons: Enhanced but reuse existing ComponentButton scene/script

---

## Acceptance Criteria

Feature is complete when:

- [ ] 7 category tabs visible in palette
- [ ] Clicking tab switches to that category (filters component grid)
- [ ] Selected tab visually highlighted with cyan glow
- [ ] Category header shows current category name, icon, description, component count
- [ ] Component grid displays only components in selected category
- [ ] Empty categories show "Coming soon" message instead of blank grid
- [ ] Tab switching feels instant (< 0.2s)
- [ ] Keyboard shortcuts (1-7) switch categories
- [ ] Component buttons show enhanced information (cost, size, brief description)
- [ ] Palette scales gracefully from 9 to 40+ components (no performance issues)

---

## Testing Checklist

### Functional Tests

- [ ] Click each of 7 tabs: Grid updates to show only that category's components
- [ ] Press keyboard 1: Switches to Power Systems
- [ ] Press keyboard 2: Switches to Weapons
- [ ] Press Tab key repeatedly: Cycles through all categories
- [ ] Switch to empty category (Utility or Structure): Shows "Coming soon" message
- [ ] Select component, switch category, switch back: Component selection persists
- [ ] Close and reopen designer: Last selected category remembered (if saving state)

### Edge Case Tests

- [ ] Rapid tab clicking (spam click): No visual glitches, no performance degradation
- [ ] Hold down keyboard shortcut: Doesn't spam category switches
- [ ] Switch category while dragging component: Drag operation unaffected
- [ ] Window resize: Palette adapts, tabs don't overflow

### Integration Tests

- [ ] Component selection from filtered grid: Works same as current behavior
- [ ] Template loading: Loads correctly, category doesn't affect template
- [ ] Component placement: Works regardless of which category tab is active

### Polish Tests

- [ ] Tab click animation smooth (immediate highlight)
- [ ] Grid fade transition smooth (0.2s, no flicker)
- [ ] Component buttons readable and attractive
- [ ] Category header text readable against dark background
- [ ] Count badges visible and accurate
- [ ] Empty category message clear and helpful
- [ ] UI remains responsive with 40+ components (tested by temporarily adding dummy components)

---

## Known Limitations

- **Fixed 7 categories**: Cannot add/remove categories without code changes. This is intentional—stable structure prevents confusion.
- **Tab overflow at small resolutions**: At 1024×768 or lower, 7 tabs might not fit. Solution: Minimum resolution 1280×720 (stated in game requirements).
- **Component grid scrolling**: Tall categories (10+ components) require scrolling. This is acceptable—alternative (pagination) is more complex.

---

## Future Enhancements

*(Not for MVP, but worth noting)*

- **Collapsible categories**: Click category header to collapse/expand (save vertical space)
- **Search highlights categories**: Type "reactor" → Power tab glows if match found
- **Recent components**: Small section above grid showing last 3 placed components regardless of category
- **Category reordering**: Player preference to rearrange tab order (accessibility)
- **Compact mode**: Toggle to show smaller component buttons (fit more on screen)

---

## Implementation Notes

*(For AI assistant or future you)*

- **Why tabs instead of dropdown?**: Tabs show all categories at once (faster scanning). Dropdown requires click → scan → click (slower).
- **Why horizontal tabs not vertical?**: Horizontal tabs at top are UI convention (familiar). Vertical sidebar takes more width (wastes space).
- **Why fade transition?**: Instant swap is jarring. Fade (0.2s) smooths transition without feeling slow.
- **Gotcha**: Don't animate individual component buttons appearing—animate the whole grid opacity. Animating 10+ buttons individually causes lag.
- **Alternative considered**: Accordion (collapsible sections). Rejected because requires scrolling to see all categories. Tabs provide instant access.
- **Performance note**: Filter component grid by hiding/showing existing buttons, don't recreate buttons each switch. Reuse improves performance with 40+ components.

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 4, 2024 | Initial spec | Category palette UI needed for scalable browsing |
