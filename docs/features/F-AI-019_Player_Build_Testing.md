# F-AI-019: Player Build Testing

**Status:** 🔴 Planned
**Priority:** 🔥 Critical
**Estimated Time:** 2 days
**Dependencies:** All Phase 1-4 features
**Phase:** 5 - Polish & Balance

---

## Purpose

**Why does this feature exist?**
Player-designed ships must feel effective and fun to fight with. Testing validates that diverse player strategies are viable and AI opponents feel fair, challenging, and beatable.

**What does it enable?**
Playtesting reveals balance issues, confusing feedback, frustrating difficulty spikes, and dominant strategies. Iteration based on real player data improves game feel.

**Success criteria:**
- 10+ unique player builds tested (covering all archetypes)
- Each build can defeat at least 2 of 3 missions
- Players understand why they won/lost (85%+ can explain)
- AI feels intelligent, not cheap or trivial (80%+ satisfaction)
- Average redesign count per mission: 2-4 attempts (not too easy, not too hard)

---

## How It Works

### Overview

**Testing Process:**

**Phase 1: Internal Testing (1 day)**
- Designer creates 10 diverse builds (Glass Cannon, Turtle, Balanced, etc.)
- Play each build through 3 missions
- Record: win rate, attempts needed, frustrations, confusions
- Identify: broken strategies, impossible builds, unclear feedback

**Phase 2: External Playtesting (1 day)**
- 5-10 external playtesters
- Each plays 2-3 missions with self-designed ships
- Survey: Did AI feel smart? Was feedback clear? Was difficulty fair?
- Collect combat logs and post-battle data

**Phase 3: Analysis & Iteration**
- Aggregate data: win rates, attempt counts, player satisfaction scores
- Identify issues: dominant builds, frustrating losses, confusing mechanics
- Propose fixes: balance tweaks, feedback improvements, tutorial hints
- Implement fixes, re-test critical issues

---

## Test Builds (Internal)

**Standard Builds:**
1. Glass Cannon (6 weapons, 2 reactors, 2 engines)
2. Defensive Turtle (2 weapons, 5 shields, 2 reactors, 3 armor)
3. Speedster (4 weapons, 2 engines, 2 reactors)
4. Balanced (3 weapons, 3 shields, 2 engines, 2 reactors)
5. Power Focus (4 reactors, 3 weapons, 2 shields)

**Edge Builds:**
6. All Weapons (8 weapons, 2 reactors) - expect power crisis
7. All Shields (8 shields, 2 reactors) - low offense
8. Minimal (Bridge + 2 weapons + 1 reactor) - fragile
9. Synergy Heavy (Weapons Array + Shield Harmonics)
10. Reactor Fortress (6 reactors, 2 weapons) - redundant power

---

## Validation Criteria

**Balance Targets:**
- [ ] Mission 1: Beatable in 1-3 attempts (beginner-friendly)
- [ ] Mission 2: Beatable in 3-5 attempts (moderate challenge)
- [ ] Mission 3: Beatable in 5-7 attempts (hard but fair)
- [ ] Redesign time: 30-90 seconds (fast iteration)
- [ ] Combat time: 15-45 seconds (engaging, not tedious)

**Player Understanding:**
- [ ] 85%+ can explain why they won/lost after reading log
- [ ] 80%+ understand AI's strategy from thought bubbles
- [ ] 75%+ correctly identify their ship archetype

**Player Satisfaction:**
- [ ] 80%+ rate AI as "intelligent" or "challenging"
- [ ] 70%+ rate combat as "interesting to watch"
- [ ] <20% report "unfair" or "frustrating" experiences

**No Dominant Strategies:**
- [ ] No single build achieves >80% win rate across all missions
- [ ] Diverse strategies viable (not just "stack weapons")

---

## Deliverables

**Playtesting Report** (docs/playtesting/Player_Build_Test_Report.md):
- Build performance matrix (win rates per mission)
- Player feedback quotes
- Satisfaction survey results
- Identified issues and proposed fixes
- Iteration change log

---

## Acceptance Criteria

- [ ] 10+ builds tested internally
- [ ] 5+ external playtesters complete testing
- [ ] Survey response rate >80%
- [ ] All validation criteria met (balance, understanding, satisfaction)
- [ ] Critical issues identified and fixed
- [ ] Re-testing confirms fixes work

---

## Implementation Notes

**Tools**: Google Forms survey, combat log exports, playtester observation sessions.
**Timeline**: 2 days for full cycle (internal + external + iteration).

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
