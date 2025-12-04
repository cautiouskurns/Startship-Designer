# Component Category System - Overview

This directory contains the complete feature specifications for the Component Category System, which organizes ship components into 7 functional categories with mechanical tags for advanced filtering.

---

## What Is This?

The Component Category System is a **foundational reorganization** of how components are presented and organized in Starship Designer. It transforms a flat list of 9 components into a scalable, browsable structure that supports 40+ components while improving player understanding and strategic decision-making.

---

## Quick Links

- **Start Here:** [`00-index-roadmap.md`](00-index-roadmap.md) - Complete implementation roadmap
- **Feature Specs:**
  - [`01-seven-category-structure.md`](01-seven-category-structure.md) - The 7 categories
  - [`02-component-tags-system.md`](02-component-tags-system.md) - The 13 mechanical tags
  - [`03-category-palette-ui.md`](03-category-palette-ui.md) - The redesigned palette interface
  - [`04-component-metadata-descriptions.md`](04-component-metadata-descriptions.md) - Rich component information

---

## The Problem

**Current State (9 components):**
- Flat list in designer palette
- Minimal information (name, cost, size)
- Hard to understand component roles
- Doesn't scale beyond 15 components

**Future State (40+ components needed):**
- Impossible to browse flat list
- Players overwhelmed by choices
- No way to filter by function
- Strategic decisions unclear

---

## The Solution

### 7 Functional Categories

Organize components by primary role:

1. **⚡ Power Systems** - Generate, store, distribute power
2. **🎯 Weapons** - Deal damage to enemies
3. **🛡️ Defense** - Absorb damage, protect ship
4. **🚀 Propulsion** - Initiative, speed, maneuverability
5. **🖥️ Command & Control** - Required systems, sensors, targeting
6. **🔧 Utility & Support** - Special functions, mission-specific
7. **🏗️ Structure** - Hull framework, compartments

### 13 Mechanical Tags

Describe component properties for filtering and logic:

**Power:** REQUIRES_POWER, GENERATES_POWER, DISTRIBUTES_POWER
**Combat:** ACTIVE_COMBAT, PASSIVE_COMBAT, CONSUMES_AMMO
**Placement:** VULNERABLE_EDGE, VULNERABLE_CORE
**Special:** REQUIRED, UNIQUE
**Synergy:** SYNERGY_WEAPON, SYNERGY_DEFENSE, SYNERGY_POWER

### Category-Based UI

Redesigned palette with:
- 7 category tabs at top
- Category header showing current category
- Filtered component grid (shows only selected category)
- Enhanced component buttons with stats and descriptions

### Rich Metadata

Three-tier component information:
- **Short description** (1 sentence): Quick identification
- **Long description** (2-3 sentences): Full explanation
- **Tactical note** (1-2 sentences): Strategic placement advice

---

## Key Benefits

### For Players
- **Faster component discovery**: Know category → find component in 5 seconds
- **Better understanding**: Descriptions explain what, why, and how
- **Strategic guidance**: Tactical notes suggest optimal placement
- **Intuitive organization**: Categories match mental model (offense, defense, etc.)

### For Developers
- **Scalable structure**: Supports 40+ components without UI redesign
- **Clear categorization rules**: Primary function determines category
- **Flexible tagging**: Add new tags without restructuring categories
- **Future-proof**: Supports unlocks, tech tiers, rarity systems

### For Content Design
- **Consistent framework**: All components follow same metadata structure
- **Clear writing guidelines**: 3-tier descriptions with word limits
- **Quality standards**: Military-technical tone, strategic focus
- **Easy expansion**: Add components by filling template

---

## Implementation Summary

**Total Time:** 12-17 hours

**Phase 1: Foundation (5-7 hours)**
1. Define 7 categories
2. Define 13 tags
3. Assign categories and tags to all 9 existing components

**Phase 2: User Interface (7-10 hours)**
1. Redesign component palette with category tabs
2. Write descriptions for all 9 components
3. Implement enhanced tooltips

**Result:** Organized, scalable system ready for content expansion

---

## Current Component Mapping

| Component | Category | Tags | Description |
|-----------|----------|------|-------------|
| **Bridge** | Command & Control | REQUIRES_POWER, REQUIRED, UNIQUE, VULNERABLE_CORE | Command center (Required, Unique) |
| **Reactor** | Power Systems | GENERATES_POWER, VULNERABLE_CORE, SYNERGY_POWER | Generates 100 power for adjacent systems |
| **Relay** | Power Systems | REQUIRES_POWER, DISTRIBUTES_POWER, SYNERGY_POWER | Power hub, distributes to 8 adjacent tiles |
| **Conduit** | Power Systems | REQUIRES_POWER, DISTRIBUTES_POWER | Extends power connections |
| **Weapon** | Weapons | REQUIRES_POWER, ACTIVE_COMBAT, VULNERABLE_EDGE, SYNERGY_WEAPON | Deals 10 damage per turn |
| **Shield** | Defense | REQUIRES_POWER, ACTIVE_COMBAT, SYNERGY_DEFENSE | Absorbs 15 damage per turn |
| **Armor** | Defense | PASSIVE_COMBAT | +20 HP to hull |
| **Engine** | Propulsion | REQUIRES_POWER, PASSIVE_COMBAT, VULNERABLE_EDGE | Adds +1 initiative (shoot first) |

**Total:** 9 components across 4 active categories (3 categories empty until content expansion)

---

## Future Content Expansion

**Wave 1 (+6 components → 15 total):**
- Compact Reactor (Power, 2×2, 35 power)
- Torpedo Launcher (Weapons, 2×2, 30 damage burst)
- Light Shield (Defense, 2×2, 10 absorption, low power)
- Reactive Armor (Defense, 1×1, +30 HP, -50% explosive damage)
- Thrusters (Propulsion, 1×2, +5% evasion)
- Sensor Array (Command, 2×3, +10% accuracy)

**Wave 2 (+6 components → 21 total):**
- Heavy Reactor, Pulse Laser, Point Defense, Afterburner, Repair Bay, Capacitor

**Wave 3 (+9-19 components → 30-40 total):**
- Fill out all 7 categories with variants and specialty components

---

## Design Philosophy

### Categories Are For Browsing
- UI organization only
- Players scan categories to find components
- Fast, intuitive discovery

### Tags Are For Filtering
- Mechanical properties
- Game logic checks tags (REQUIRES_POWER → check power adjacency)
- Advanced filtering ("show SYNERGY_WEAPON components")

### Metadata Is For Strategy
- Descriptions explain gameplay
- Tactical notes guide decisions
- Focus on "why use" not just "what it does"

### Separation of Concerns
- **Categories** = UI (where to look)
- **Tags** = Mechanics (how it behaves)
- **Metadata** = Strategy (when to use)

Each system serves a distinct purpose, working together for comprehensive organization.

---

## Decision Log

### Why 7 Categories?
- Covers all component types without overlap
- Not too many (overwhelming) or too few (lacks granularity)
- Aligns with existing game systems (power, combat, synergies)
- Follows Miller's Law: 7±2 items optimal for human categorization

### Why Flat Structure (Not Nested)?
- Nested categories add complexity (Weapons → Energy → Lasers → Pulse)
- 40 components don't need 3-level hierarchy
- Flat structure enables 1-click access to any component

### Why Both Categories AND Tags?
- Categories: Fast browsing ("I need a weapon")
- Tags: Precise filtering ("I need a weapon that participates in synergies")
- Hybrid approach provides best of both worlds

### Why 3-Tier Descriptions?
- Short (1 sentence): Quick scanning in palette
- Long (2-3 sentences): Full understanding in tooltip
- Tactical (1-2 sentences): Strategic guidance for decisions
- Progressive disclosure matches player mental flow

---

## Success Criteria

This system succeeds when:

- ✅ Players find components in <5 seconds without help
- ✅ New players understand categories without tutorial
- ✅ Component list scales to 40+ without UI redesign
- ✅ Descriptions enable strategic decisions in-designer
- ✅ Adding new components takes <30 minutes (category, tags, descriptions, sprite)

---

## Related Documentation

- **Game Design:** [`docs/design-docs/2-core-systems.md`](../../design-docs/2-core-systems.md) - System 1: Ship Design & Room Placement
- **Balance:** Component balance reference (planned)
- **Content:** Component writing guide (planned)

---

## Questions & Feedback

**"Why not use a search box instead of categories?"**
→ Search requires knowing component name. Categories enable discovery ("What weapons exist?")

**"Can I add an 8th category?"**
→ Possible but discouraged. 7 categories already comprehensive. Consider if new components fit existing categories first.

**"What if a component fits multiple categories?"**
→ Use primary function rule. Sensor Array gives accuracy (combat) but goes in Command because it's a control system.

**"Do players see tags in-game?"**
→ Yes, in tooltips. But tags are also backend (game logic checks tags for power routing, synergies).

**"Can components have 0 tags?"**
→ Technically yes (future: basic hull plating). Most components have 1-4 tags.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Dec 4, 2024 | Initial specification complete |

---

**Next Steps:** Read `00-index-roadmap.md` for implementation plan.
