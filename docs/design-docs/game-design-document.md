# Deep Ship Designer - Game Design Document

**Version:** 1.0
**Last Updated:** [Date]
**Status:** In Production
**Target Launch:** [Date]

---

## DOCUMENT MAP

This GDD is split into modular documents for easy maintenance:

### Core Documents (Stable)
1. **[Game Overview](1-game-overview.md)** - Concept, pillars, audience
2. **[Core Systems](2-core-systems.md)** - How main mechanics work
3. **[Production Roadmap](3-production-roadmap.md)** - What to build, priority order
4. **[Design Reference](4-design-reference.md)** - Rules, balance, testing

### Feature Documentation (Just-in-Time)
- **[Implemented Features](features/implemented/)** - Specs for completed features
- **[Planned Features](features/planned/)** - Specs for upcoming features

---

## QUICK REFERENCE

**What is this game?**
A tactical starship design puzzle where players design ships on a grid, watch automated combat, and iterate until victory. Engineering fantasy, not piloting.

**Core Loop:**
Design ship (60-90s) → Watch battle (30-60s) → Analyze result (10-20s) → Iterate

**Current State:**
- Prototype complete (23/25 validation score)
- Power system with relays implemented
- 3 missions playable
- Combat + replay working

**Next Priorities:**
1. Tutorial system (Week 1-2)
2. Save system (Week 3)
3. Content expansion (Week 4-8)
4. Polish (Week 9-12)

**Launch Criteria:**
See [Production Roadmap](3-production-roadmap.md) for complete definition of "done"

---

## HOW TO USE THIS GDD

### When Building a New Feature:
1. Check if spec exists in `features/planned/`
2. If not, create new spec document (use template below)
3. Write spec (1-2 hours)
4. Give spec to AI assistant
5. Build feature
6. Move spec to `features/implemented/`
7. Update [Core Systems](2-core-systems.md) if needed

### When Changing Design:
1. Update affected documents
2. Note version change
3. Update "Last Updated" date
4. Keep old version in git history

### When Onboarding Someone:
1. Read [Game Overview](1-game-overview.md) (10 min)
2. Read [Core Systems](2-core-systems.md) (20 min)
3. Check [Production Roadmap](3-production-roadmap.md) (5 min)
4. Done - they understand the game

---

## FEATURE SPEC TEMPLATE

When creating new feature spec in `features/planned/`:
```markdown
# [Feature Name]

**Status:** Planned | In Progress | Implemented
**Priority:** Critical | High | Medium | Low
**Estimated Time:** X hours/days
**Dependencies:** [Other features this needs]

## Purpose
Why does this feature exist? What problem does it solve?

## How It Works
Detailed description of the feature behavior.

## User Interaction
How does the player interact with this?

## Visual Design
What does it look like?

## Implementation Notes
Technical considerations for AI assistant.

## Acceptance Criteria
- [ ] Criteria 1
- [ ] Criteria 2
- [ ] Criteria 3

## Testing Checklist
- [ ] Test case 1
- [ ] Test case 2
```

---

## VERSION HISTORY

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | [Date] | Initial GDD structure created |