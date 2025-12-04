# Component Category System - Implementation Roadmap

**Last Updated:** December 4, 2024
**Status:** 🔴 Planned
**Total Estimated Time:** 12-17 hours
**Overall Priority:** 🔥 Critical (Prerequisite for content expansion from 9 to 40+ components)

---

## Overview

The Component Category System organizes ship components into 7 functional categories (Power, Weapons, Defense, Propulsion, Command, Utility, Structure) with a tags system for mechanical properties. This enables scalable browsing, advanced filtering, and clear strategic guidance for players.

**Why This Matters:**
- Current flat list of 9 components doesn't scale
- Players need clear organization to find components quickly
- Strategic depth requires understanding component roles and synergies
- Future content expansion (to 40+ components) requires robust categorization

**What It Enables:**
- Intuitive category-based browsing with tabs
- Multi-dimensional filtering by tags (power, combat, placement)
- Rich component descriptions with strategic guidance
- Foundation for advanced features (search, sort, unlocks)

---

## Feature Specifications

This roadmap consists of 4 core feature specifications, each with detailed design rationale:

### 01. Seven-Category Structure
**File:** `01-seven-category-structure.md`
**Time:** 2-3 hours
**Priority:** 🔥 Critical

Defines the 7 primary categories (⚡Power, 🎯Weapons, 🛡️Defense, 🚀Propulsion, 🖥️Command, 🔧Utility, 🏗️Structure) and assigns all 9 existing components to appropriate categories.

**Key Deliverables:**
- ComponentCategory enum with 7 categories
- Category names, icons, descriptions, colors
- Component-to-category mapping for all 9 existing rooms
- Category assignment rules (primary function determines category)

**Success Criteria:**
- Every component belongs to exactly one category
- Players can explain each category's purpose in one sentence
- Categories align with existing game systems (power, combat, synergies)

---

### 02. Component Tags System
**File:** `02-component-tags-system.md`
**Time:** 3-4 hours
**Priority:** ⬆️ High

Defines 13 mechanical tags (REQUIRES_POWER, GENERATES_POWER, ACTIVE_COMBAT, VULNERABLE_CORE, etc.) that describe component properties for filtering and game logic.

**Key Deliverables:**
- ComponentTag enum with 13 tags
- Tag names, descriptions, colors, icons
- Tag assignments for all 9 existing components
- Tag-based game logic (power routing checks REQUIRES_POWER tag)

**Success Criteria:**
- Components can have multiple tags (Bridge has 4)
- Tags enable clear filtering ("show me all SYNERGY_WEAPON components")
- Tags replace hardcoded component type checks in game logic

---

### 03. Category-Based Palette UI
**File:** `03-category-palette-ui.md`
**Time:** 4-6 hours
**Priority:** 🔥 Critical

Redesigns the ship designer component palette with category tabs, filtered component grid, and enhanced component buttons showing stats and descriptions.

**Key Deliverables:**
- Category tab bar with 7 tabs (emoji icons + count badges)
- Category header showing current category name + description
- Filtered component grid (shows only components in selected category)
- Enhanced component buttons (icon + cost + size + short description)
- Smooth tab switching (<0.2s) and fade transitions

**Success Criteria:**
- Players can switch between categories with one click
- Component discovery takes <5 seconds (know category → find component)
- UI scales gracefully to 40+ total components
- Empty categories show helpful "Coming soon" message

---

### 04. Component Metadata & Descriptions
**File:** `04-component-metadata-descriptions.md`
**Time:** 3-4 hours (writing + implementation)
**Priority:** ➡️ Medium

Enriches all components with 3-tier descriptions (short, long, tactical) providing strategic guidance and gameplay context.

**Key Deliverables:**
- ComponentMetadata class with description fields
- Short descriptions for all 9 components (1 sentence)
- Long descriptions for all 9 components (2-3 sentences)
- Tactical notes for all 9 components (placement/usage tips)
- Detailed tooltips showing long descriptions + tactical notes

**Success Criteria:**
- Players can make informed decisions without leaving designer
- Descriptions focus on strategy (why use), not just mechanics (what it does)
- Writing style consistent (military-technical, concise)
- Tactical notes provide actionable advice

---

## Implementation Sequence

### Phase 1: Foundation (5-7 hours)
**Order:** 01 → 02
1. Implement Seven-Category Structure (2-3h)
2. Implement Component Tags System (3-4h)

**Why This Order:**
- Categories provide the organizational structure
- Tags build on categories (both needed for UI)
- Both are data-only (no UI changes yet)

**Deliverable:** All 9 components categorized and tagged

---

### Phase 2: User Interface (7-10 hours)
**Order:** 03 → 04
1. Implement Category-Based Palette UI (4-6h)
2. Implement Component Metadata & Descriptions (3-4h)

**Why This Order:**
- Palette UI needs categories and tags (depends on Phase 1)
- Metadata enhances palette UI (descriptions appear in buttons/tooltips)
- UI provides immediate player value (visual improvement)

**Deliverable:** Redesigned component palette with rich information

---

## Acceptance Criteria (Overall System)

Component Category System is complete when:

- [ ] **Structure:** 7 categories defined with clear purposes
- [ ] **Tags:** 13 tags defined and assigned to all components
- [ ] **UI:** Category tabs functional, switching instant, filters work
- [ ] **Metadata:** All 9 components have short/long/tactical descriptions
- [ ] **Scale:** System supports adding new components without code changes
- [ ] **Performance:** UI responsive with 40+ components (tested with dummy data)
- [ ] **UX:** Players find components in <5 seconds without tutorial
- [ ] **Polish:** Visual design consistent, animations smooth, text readable

---

## Testing Strategy

### Integration Testing
1. **Category ↔ UI**: Changing component's category updates palette display
2. **Tags ↔ Logic**: Power routing checks REQUIRES_POWER tag correctly
3. **Metadata ↔ Tooltips**: Descriptions appear in correct locations
4. **Categories ↔ Content**: Adding new component to category shows in correct tab

### Scale Testing
1. Create 30 dummy components distributed across categories
2. Test palette performance (tab switching, scrolling, hover tooltips)
3. Verify UI remains responsive and readable
4. Test at 1280×720 and 1920×1080 resolutions

### Usability Testing
1. Give player task: "Find the component that generates power"
2. Measure time to complete (<5 seconds = success)
3. Ask: "What does the Weapons category contain?" (should answer correctly without checking)
4. Observe: Do players understand tag meanings from names alone?

---

## Dependencies

### External Dependencies
- None (refactors existing room system)

### Internal Dependencies
- 01 Seven-Category Structure → 02 Component Tags System (tags reference categories)
- 01+02 → 03 Category Palette UI (UI displays categories and tags)
- 03 → 04 Component Metadata (metadata appears in palette UI)

### Blocking Features
This system **blocks**:
- Content expansion beyond 15 components (UI becomes unusable)
- Advanced filtering/search features (need categories + tags as foundation)
- New component types (need clear categorization before adding)

---

## Success Metrics

### Quantitative
- Time to find component: <5 seconds (measured with stopwatch)
- UI responsiveness: <0.2s tab switching (measured with profiler)
- Component capacity: Supports 40+ components without redesign (tested with dummies)
- Description coverage: 100% components have short descriptions (checklist)

### Qualitative
- Player understanding: Can explain category purposes without documentation (survey)
- Strategic guidance: Tactical notes help placement decisions (player feedback)
- Visual clarity: Categories visually distinct and recognizable (observation)
- Consistency: Writing style uniform across all descriptions (editorial review)

---

## Risk Mitigation

### Risk: Empty Categories Look Bad
- **Mitigation:** Show "Coming soon" message with examples of future components
- **Fallback:** Hide empty categories until they have at least 1 component

### Risk: Players Don't Understand Tags
- **Mitigation:** Clear tag names + tooltips explaining gameplay effects
- **Fallback:** Add in-game glossary explaining all tags with examples

### Risk: Descriptions Too Long
- **Mitigation:** Strict word limits (short: 10 words, long: 60 words, tactical: 40 words)
- **Fallback:** Progressive disclosure (click "Read more" to expand tactical note)

### Risk: Category Assignment Disputes
- **Mitigation:** Clear assignment rule: primary function determines category
- **Documentation:** Rationale document explaining each component's category choice

---

## Future Expansion Path

After MVP implementation, system supports:

### Wave 2: Advanced Filtering (4-6 hours)
- Search box (filter components by name/description)
- Tag filter toggles (show only components with specific tags)
- Sort options (by cost, size, power consumption, name)

### Wave 3: Content Expansion (4-6 hours per 6 components)
- Add 6 new components (Compact Reactor, Torpedo Launcher, Light Shield, Reactive Armor, Thrusters, Sensor Array)
- Each new component: category, tags, descriptions, sprite, gameplay mechanics
- Total components: 15 (9 + 6)

### Wave 4: Meta Features (6-8 hours)
- Component unlocking (start with basic, unlock advanced)
- Tech tiers (basic, advanced, prototype)
- Rarity system (common, rare, legendary)
- Component upgrades (Mark I → Mark II → Mark III)

---

## Alternative Approaches Considered

### Hierarchical Categories (Rejected)
**Approach:** Nested categories (Weapons → Energy Weapons → Lasers → Pulse Lasers)
**Pros:** Very organized, scalable to 100+ components
**Cons:** Too complex for 40 components, requires 3+ clicks to find component, adds cognitive load
**Decision:** Flat 7 categories sufficient for target scale

### Pure Tag System (Rejected)
**Approach:** No categories, only tags. Filter by multiple tags to find components.
**Pros:** Maximum flexibility, future-proof
**Cons:** Requires too many filter clicks for basic browsing, no quick scanning
**Decision:** Categories for browsing, tags for filtering (hybrid approach)

### Fixed 3 Categories (Rejected)
**Approach:** Just 3 categories: Offense, Defense, Utility
**Pros:** Simple, easy to understand
**Cons:** Categories too broad (Offense includes weapons AND engines?), loses strategic clarity
**Decision:** 7 categories provide right balance of simplicity and granularity

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 4, 2024 | Initial roadmap created | Component category system specification complete |

---

## Quick Start Guide

**To implement this system:**

1. Read feature specs in order: 01 → 02 → 03 → 04
2. Start with Phase 1 (Foundation): Implement categories and tags
3. Test: Verify all 9 components categorized and tagged correctly
4. Move to Phase 2 (UI): Implement palette and metadata
5. Test: Play through full ship design workflow
6. Iterate: Gather feedback, refine descriptions

**Estimated Timeline:**
- Week 1 (8-10h): Phase 1 Foundation + initial Phase 2 UI
- Week 2 (4-7h): Complete Phase 2 UI + polish + testing
- Week 3 (Optional): Add first 6 new components (Wave 3)

---

## Contact & Questions

For questions about this roadmap:
- **Design rationale:** See individual feature spec files
- **Technical implementation:** See "Technical Implementation" sections in each spec
- **Content writing:** See 04-component-metadata-descriptions.md content checklist
- **Testing procedures:** See "Testing Checklist" sections in each spec

**Remember:** This is a living document. Update as design evolves.
