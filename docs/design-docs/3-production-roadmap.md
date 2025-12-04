# Production Roadmap

**Updated weekly. Tracks what's done, what's next, what's blocked.**

**Last Updated:** December 2024
**Version:** 0.1 MVP → 1.0 Launch Plan

---

## Launch Definition (v1.0)

**The game is shippable when:**
- [x] Core systems complete (ship design, power routing, synergies, combat, templates, replay)
- [x] 3 missions playable start to finish (MVP baseline)
- [ ] 10-15 missions playable with varied objectives
- [ ] Tutorial teaches all core mechanics (guided first mission)
- [ ] All components have final art (rooms, ships, UI, VFX)
- [ ] Audio fully integrated (SFX + music)
- [ ] Save/load system functional (progression persistence)
- [ ] Settings menu complete (volume, resolution, keybinds)
- [ ] Achievements system (10-15 achievements)
- [ ] Statistics tracking (ships designed, battles won, etc.)
- [ ] No critical bugs (QA pass complete)
- [ ] Steam page ready (trailer, screenshots, description)
- [ ] 80%+ of test players complete tutorial (playtest target)

**Launch Criteria: 12/13 items complete** (92%+ to ship)

---

## Current Status

**Week:** 0 (Pre-Production Planning)
**Phase:** Phase 0 - MVP Complete, Planning 1.0
**Completed:** 30% of launch criteria (core systems done)
**On Track:** Yes (MVP validated, moving to production)

### Recent Completions (MVP Phase)
- ✅ Ship design system with 9 room types (multi-tile, rotation, budget)
- ✅ Power routing (reactors, conduits, relays, cascade effects)
- ✅ Room synergy system (4 types, visual indicators)
- ✅ Auto-resolved combat (transparent, turn-based)
- ✅ Intelligent enemy AI (3 targeting strategies)
- ✅ Hull type system (3 hulls + Free Design)
- ✅ Template save/load system
- ✅ Combat replay with timeline scrubbing
- ✅ 3-mission prototype campaign
- ✅ Main menu, mission select, hull select UI

### Current Work (Week 0)
- 📝 Production roadmap finalization (this document)
- 📝 Pre-production planning (feature prioritization)
- 📝 Asset pipeline setup (art style guide, audio sourcing)

### Next Up (Weeks 1-2)
- 🎯 Tutorial system (guided Mission 1)
- 🎯 Save/load game state (progression persistence)
- 🎯 Settings menu (volume, resolution, keybinds)
- 🎯 First external playtest (friends/family)

### Blockers
- None currently (MVP complete, ready to scale up)

---

## Phase 0: MVP Complete ✅ (Completed)

**Goal:** Validate core gameplay loop

**Prototype Score: 23/25 → Build Full Game Decision ✅**

| Feature | Status | Notes |
|---------|--------|-------|
| Ship Design System | 🟢 Complete | 9 room types, multi-tile, rotation, budget |
| Power Routing | 🟢 Complete | Reactors, conduits, relays, visual indicators |
| Room Synergies | 🟢 Complete | 4 types, stacking, combat bonuses |
| Auto-Combat | 🟢 Complete | Turn-based, transparent math, 3 AI strategies |
| Hull Types | 🟢 Complete | 3 types + Free Design, shaped grids |
| Template System | 🟢 Complete | Save/load designs, auto-fill |
| Combat Replay | 🟢 Complete | Timeline scrubbing, event log |
| 3 Missions | 🟢 Complete | Scout, Raider, Dreadnought |
| UI Framework | 🟢 Complete | Main menu, mission select, hull select, designer |

**Phase Status:** ✅ COMPLETE (December 2024)

---

## Phase 1: Make It Teachable (Weeks 1-6)

**Goal:** Players understand the game without frustration, can save progress

**Duration:** 6 weeks
**Target Completion:** Week 6

| Feature | Priority | Est. Time | Status | Assignee | Notes |
|---------|----------|-----------|--------|----------|-------|
| **Tutorial System** | 🔴 CRITICAL | 2 weeks | 🔴 Not Started | Solo Dev | Blocks playtesting |
| - Tutorial script writing | HIGH | 3 days | 🔴 Not Started | Solo Dev | Outline Mission 1 guidance |
| - Interactive tooltips | HIGH | 4 days | 🔴 Not Started | Solo Dev | Explain each mechanic |
| - Guided room placement | HIGH | 3 days | 🔴 Not Started | Solo Dev | Step-by-step first design |
| - Tutorial combat walkthrough | MEDIUM | 2 days | 🔴 Not Started | Solo Dev | Explain combat results |
| **Save/Load System** | 🔴 CRITICAL | 1 week | 🔴 Not Started | Solo Dev | Required for campaign |
| - Save game state to disk | HIGH | 3 days | 🔴 Not Started | Solo Dev | Mission progress, unlocks |
| - Load game state on start | HIGH | 2 days | 🔴 Not Started | Solo Dev | Restore progression |
| - Multiple save slots (3) | MEDIUM | 2 days | 🔴 Not Started | Solo Dev | Player choice |
| **Settings Menu** | 🟡 HIGH | 4 days | 🔴 Not Started | Solo Dev | Expected feature |
| - Volume controls (master, SFX, music) | HIGH | 2 days | 🔴 Not Started | Solo Dev | AudioManager ready |
| - Resolution/fullscreen toggle | MEDIUM | 1 day | 🔴 Not Started | Solo Dev | Common request |
| - Keybind remapping | LOW | 2 days | 🔴 Not Started | Solo Dev | Can defer to v1.1 |
| **Post-Battle Analysis Panel** | 🟡 HIGH | 3 days | 🔴 Not Started | Solo Dev | Helps learning |
| - Detailed stats breakdown | MEDIUM | 2 days | 🔴 Not Started | Solo Dev | Damage dealt/taken |
| - Suggestions for improvement | LOW | 1 day | 🔴 Not Started | Solo Dev | AI hints (optional) |
| **First Playtest** | 🔴 CRITICAL | 1 week | 🔴 Not Started | Solo Dev | Friends/family |

**Phase 1 Deliverables:**
- ✅ Tutorial complete (80%+ completion rate in testing)
- ✅ Save/load functional (no progress lost)
- ✅ Settings menu complete (volume + resolution minimum)
- ✅ 5+ external playtesters complete campaign
- ✅ Playtest feedback documented

**Phase Complete When:** Players can learn, save progress, and complete campaign without help

---

## Phase 2: Add Content (Weeks 7-14)

**Goal:** Enough missions for satisfying 4-6 hour campaign

**Duration:** 8 weeks
**Target Completion:** Week 14

| Feature | Priority | Est. Time | Status | Assignee | Notes |
|---------|----------|-----------|--------|----------|-------|
| **Mission Design (7-12 more)** | 🔴 CRITICAL | 3 weeks | 🔴 Not Started | Solo Dev | Core content |
| - Mission briefs + objectives | HIGH | 1 week | 🔴 Not Started | Solo Dev | 10-15 missions total |
| - Enemy layouts | HIGH | 1 week | 🔴 Not Started | Solo Dev | Handcrafted balance |
| - Budget tuning per mission | HIGH | 3 days | 🔴 Not Started | Solo Dev | Progressive challenge |
| - Mission testing/balance | HIGH | 1 week | 🔴 Not Started | Solo Dev | Playtesting each |
| **Enemy Variety (12-17 more)** | 🟡 HIGH | 2 weeks | 🔴 Not Started | Solo Dev | Archetypes |
| - Scout variants (3-4 types) | MEDIUM | 3 days | 🔴 Not Started | Solo Dev | Fast, low HP |
| - Cruiser variants (4-5 types) | MEDIUM | 4 days | 🔴 Not Started | Solo Dev | Balanced |
| - Battleship variants (3-4 types) | MEDIUM | 3 days | 🔴 Not Started | Solo Dev | Heavy, high HP |
| - Specialist enemies (2-3 types) | LOW | 3 days | 🔴 Not Started | Solo Dev | Unique gimmicks |
| **New Room Types (3-6 more)** | 🟡 HIGH | 1.5 weeks | 🔴 Not Started | Solo Dev | Variety |
| - Room design + balancing | HIGH | 1 week | 🔴 Not Started | Solo Dev | 12-15 total rooms |
| - New synergies (2-3 types) | MEDIUM | 3 days | 🔴 Not Started | Solo Dev | Strategic depth |
| - Room art integration | HIGH | 2 days | 🔴 Not Started | Solo Dev | Consistent style |
| **New Hull Types (2-3 more)** | 🟢 MEDIUM | 1 week | 🔴 Not Started | Solo Dev | Optional variety |
| - Hull shapes + bonuses | MEDIUM | 3 days | 🔴 Not Started | Solo Dev | 5-6 total hulls |
| - Hull unlock progression | MEDIUM | 2 days | 🔴 Not Started | Solo Dev | Tied to missions |
| - Hull balancing | MEDIUM | 2 days | 🔴 Not Started | Solo Dev | Test all types |
| **Mission Objectives (optional)** | 🟢 MEDIUM | 4 days | 🔴 Not Started | Solo Dev | Replayability |
| - Win with <X budget | LOW | 2 days | 🔴 Not Started | Solo Dev | Challenge mode |
| - Win in <X turns | LOW | 1 day | 🔴 Not Started | Solo Dev | Speed challenge |
| - No room type destroyed | LOW | 1 day | 🔴 Not Started | Solo Dev | Perfect run |

**Phase 2 Deliverables:**
- ✅ 10-15 missions playable
- ✅ 15-20 enemy archetypes
- ✅ 12-15 room types
- ✅ 5-6 hull types (optional)
- ✅ Mission objectives system (optional)
- ✅ Campaign balancing complete

**Phase Complete When:** 4-6 hour campaign with varied challenges

---

## Phase 3: Polish - Art & Audio (Weeks 15-20)

**Goal:** Game looks and sounds professional

**Duration:** 6 weeks
**Target Completion:** Week 20

| Feature | Priority | Est. Time | Status | Assignee | Notes |
|---------|----------|-----------|--------|----------|-------|
| **Art Pass - Rooms** | 🔴 CRITICAL | 1.5 weeks | 🔴 Not Started | Artist / Solo | Professional sprites |
| - 12-15 room sprites (64×64px) | HIGH | 1 week | 🔴 Not Started | Artist | Pixel art style |
| - Destroyed room variants | MEDIUM | 2 days | 🔴 Not Started | Artist | Gray/cracked versions |
| - Room icons for UI | MEDIUM | 1 day | 🔴 Not Started | Artist | Palette buttons |
| **Art Pass - Ships & Hulls** | 🟡 HIGH | 1 week | 🔴 Not Started | Artist / Solo | Visual variety |
| - 5-6 hull sprites | MEDIUM | 3 days | 🔴 Not Started | Artist | Shaped outlines |
| - Enemy ship sprites (3-4 types) | MEDIUM | 3 days | 🔴 Not Started | Artist | Distinct visuals |
| - Ship detail pass | LOW | 1 day | 🔴 Not Started | Artist | Greebles, details |
| **Art Pass - VFX** | 🟡 HIGH | 1 week | 🔴 Not Started | Artist / Solo | Combat juice |
| - Explosion sprites (3 variations) | HIGH | 2 days | 🔴 Not Started | Artist | Orange/yellow bursts |
| - Laser beam sprites | MEDIUM | 2 days | 🔴 Not Started | Artist | Weapon fire VFX |
| - Shield impact effects | MEDIUM | 2 days | 🔴 Not Started | Artist | Cyan/blue flashes |
| - Power line animations | LOW | 1 day | 🔴 Not Started | Solo | Energy flow effect |
| **Art Pass - UI** | 🟢 MEDIUM | 4 days | 🔴 Not Started | Artist / Solo | Professional look |
| - Button sprites (normal/hover/pressed) | MEDIUM | 2 days | 🔴 Not Started | Artist | Consistent style |
| - Panel backgrounds | LOW | 1 day | 🔴 Not Started | Artist | Blueprint theme |
| - Icon set (save, load, settings, etc.) | MEDIUM | 1 day | 🔴 Not Started | Artist | 16×16 or 32×32 |
| **Audio Integration** | 🔴 CRITICAL | 1.5 weeks | 🔴 Not Started | Solo Dev | AudioManager ready |
| - SFX sourcing (button clicks, placement, combat) | HIGH | 3 days | 🔴 Not Started | Solo | Find/buy library |
| - Music tracks (menu, combat, victory) | HIGH | 3 days | 🔴 Not Started | Solo | 3-5 tracks minimum |
| - Audio integration + testing | HIGH | 3 days | 🔴 Not Started | Solo | Volume balance |
| - Audio polish pass | MEDIUM | 2 days | 🔴 Not Started | Solo | Transitions, loops |
| **UI Polish & Animations** | 🟢 MEDIUM | 5 days | 🔴 Not Started | Solo Dev | Juice |
| - Button hover animations | MEDIUM | 2 days | 🔴 Not Started | Solo | Scale/glow tweens |
| - Scene transitions | MEDIUM | 2 days | 🔴 Not Started | Solo | Fade in/out |
| - Panel slide-in animations | LOW | 1 day | 🔴 Not Started | Solo | Stats panels |

**Phase 3 Deliverables:**
- ✅ All rooms have final sprite art
- ✅ Ships and hulls have visual variety
- ✅ Combat VFX (explosions, lasers, shields)
- ✅ SFX for all interactions
- ✅ Music tracks integrated
- ✅ UI polish complete

**Phase Complete When:** Game looks and sounds professional (not placeholder)

---

## Phase 4: Meta-Systems & Progression (Weeks 21-24)

**Goal:** Player retention and replayability

**Duration:** 4 weeks
**Target Completion:** Week 24

| Feature | Priority | Est. Time | Status | Assignee | Notes |
|---------|----------|-----------|--------|----------|-------|
| **Progression System** | 🟡 HIGH | 1 week | 🔴 Not Started | Solo Dev | Unlocks |
| - Room unlocks (start with 6, unlock 12-15) | MEDIUM | 3 days | 🔴 Not Started | Solo | Campaign progression |
| - Hull unlocks (earn through missions) | MEDIUM | 2 days | 🔴 Not Started | Solo | Tied to victories |
| - Unlock notifications | LOW | 2 days | 🔴 Not Started | Solo | "New Room Unlocked!" |
| **Achievements System** | 🟡 HIGH | 1 week | 🔴 Not Started | Solo Dev | Steam integration |
| - Achievement definitions (10-15) | MEDIUM | 2 days | 🔴 Not Started | Solo | Win all missions, etc. |
| - Achievement tracking | HIGH | 3 days | 🔴 Not Started | Solo | Event-driven |
| - Achievement UI | MEDIUM | 2 days | 🔴 Not Started | Solo | Notification popups |
| **Statistics Tracking** | 🟢 MEDIUM | 4 days | 🔴 Not Started | Solo Dev | Player stats |
| - Track ships designed, battles won, etc. | MEDIUM | 2 days | 🔴 Not Started | Solo | Global counters |
| - Statistics screen | MEDIUM | 2 days | 🔴 Not Started | Solo | View totals |
| **Endless Mode (optional)** | 🟢 MEDIUM | 1 week | 🔴 Not Started | Solo Dev | Replayability |
| - Procedural enemy generation | MEDIUM | 3 days | 🔴 Not Started | Solo | Scaling difficulty |
| - Leaderboard integration | LOW | 2 days | 🔴 Not Started | Solo | Steam leaderboards |
| - Endless mode UI | MEDIUM | 2 days | 🔴 Not Started | Solo | Wave counter |

**Phase 4 Deliverables:**
- ✅ Progression system (unlock rooms/hulls)
- ✅ 10-15 achievements
- ✅ Statistics tracking
- ✅ Endless mode (optional)

**Phase Complete When:** Players have long-term goals and replayability

---

## Phase 5: QA & Balance (Weeks 25-28)

**Goal:** Bug-free, balanced, polished experience

**Duration:** 4 weeks
**Target Completion:** Week 28

| Feature | Priority | Est. Time | Status | Assignee | Notes |
|---------|----------|-----------|--------|----------|-------|
| **Bug Fixing Pass** | 🔴 CRITICAL | 2 weeks | 🔴 Not Started | Solo Dev | All known issues |
| - Critical bugs (crashes, softlocks) | HIGH | 1 week | 🔴 Not Started | Solo | Zero tolerance |
| - Major bugs (broken features) | HIGH | 3 days | 🔴 Not Started | Solo | Must fix |
| - Minor bugs (visual glitches) | MEDIUM | 2 days | 🔴 Not Started | Solo | Fix if time |
| - Polish bugs (typos, UI alignment) | LOW | 2 days | 🔴 Not Started | Solo | Nice to fix |
| **Balance Tuning** | 🔴 CRITICAL | 1.5 weeks | 🔴 Not Started | Solo Dev | Playtest-driven |
| - Mission difficulty curve | HIGH | 1 week | 🔴 Not Started | Solo | 70% clear rate target |
| - Room cost balancing | HIGH | 2 days | 🔴 Not Started | Solo | No dominant strategies |
| - Enemy stat tuning | MEDIUM | 2 days | 🔴 Not Started | Solo | Fair but challenging |
| - Hull bonus balancing | MEDIUM | 1 day | 🔴 Not Started | Solo | All viable |
| **External Playtesting** | 🔴 CRITICAL | 1 week | 🔴 Not Started | Solo Dev | 20+ testers |
| - Recruit playtesters | HIGH | 2 days | 🔴 Not Started | Solo | Reddit, Discord |
| - Collect feedback | HIGH | 3 days | 🔴 Not Started | Solo | Surveys, sessions |
| - Iterate on feedback | HIGH | 2 days | 🔴 Not Started | Solo | Fix common issues |
| **Performance Optimization** | 🟡 HIGH | 3 days | 🔴 Not Started | Solo Dev | 60 FPS target |
| - Profile performance | MEDIUM | 1 day | 🔴 Not Started | Solo | Find bottlenecks |
| - Optimize hotspots | MEDIUM | 2 days | 🔴 Not Started | Solo | Fix slowdowns |

**Phase 5 Deliverables:**
- ✅ Zero critical bugs
- ✅ Balanced mission difficulty (70% clear rate for Mission 1-3)
- ✅ 20+ external playtesters
- ✅ 60 FPS on target hardware
- ✅ Feedback incorporated

**Phase Complete When:** Game is polished, balanced, bug-free

---

## Phase 6: Launch Prep (Weeks 29-32)

**Goal:** Marketing materials, store pages, launch

**Duration:** 4 weeks
**Target Completion:** Week 32 (Launch!)

| Task | Priority | Est. Time | Status | Assignee | Notes |
|------|----------|-----------|--------|----------|-------|
| **Trailer Production** | 🔴 CRITICAL | 1 week | 🔴 Not Started | Solo Dev | 60-90 seconds |
| - Script/storyboard | HIGH | 2 days | 🔴 Not Started | Solo | Show gameplay loop |
| - Capture footage | HIGH | 2 days | 🔴 Not Started | Solo | Best moments |
| - Edit/polish | HIGH | 2 days | 🔴 Not Started | Solo | Music, pacing |
| - Upload to YouTube | MEDIUM | 1 day | 🔴 Not Started | Solo | Public embed |
| **Screenshots** | 🔴 CRITICAL | 3 days | 🔴 Not Started | Solo Dev | 10-15 images |
| - Gameplay screenshots | HIGH | 2 days | 🔴 Not Started | Solo | Designer, combat |
| - UI screenshots | MEDIUM | 1 day | 🔴 Not Started | Solo | Menus, stats |
| **Steam Store Page** | 🔴 CRITICAL | 1 week | 🔴 Not Started | Solo Dev | Or itch.io |
| - Description copy | HIGH | 2 days | 🔴 Not Started | Solo | Pitch, features |
| - Upload assets (trailer, screenshots) | HIGH | 1 day | 🔴 Not Started | Solo | Steam format |
| - Pricing decision | HIGH | 1 day | 🔴 Not Started | Solo | $10-15 range |
| - Tag selection | MEDIUM | 1 day | 🔴 Not Started | Solo | Strategy, puzzle, etc. |
| - Steam page review | MEDIUM | 2 days | 🔴 Not Started | Solo | Feedback from community |
| **Press Kit** | 🟡 HIGH | 2 days | 🔴 Not Started | Solo Dev | Media outreach |
| - Fact sheet | MEDIUM | 1 day | 🔴 Not Started | Solo | Game overview |
| - Press release | MEDIUM | 1 day | 🔴 Not Started | Solo | Launch announcement |
| **Community Building** | 🟡 HIGH | Ongoing | 🔴 Not Started | Solo Dev | Pre-launch |
| - Reddit posts (r/ftlgame, r/IntoTheBreach) | MEDIUM | Ongoing | 🔴 Not Started | Solo | Build interest |
| - Discord server setup | LOW | 2 days | 🔴 Not Started | Solo | Community hub |
| - Dev blog/Twitter updates | MEDIUM | Ongoing | 🔴 Not Started | Solo | Transparency |
| **Launch Day** | 🔴 CRITICAL | 1 day | 🔴 Not Started | Solo Dev | Go live! |
| - Publish to Steam/itch.io | HIGH | 1 hour | 🔴 Not Started | Solo | Press button |
| - Announce on social media | HIGH | 1 hour | 🔴 Not Started | Solo | Reddit, Twitter |
| - Monitor reviews/issues | HIGH | All day | 🔴 Not Started | Solo | Rapid response |

**Phase 6 Deliverables:**
- ✅ Trailer live on YouTube
- ✅ 10-15 screenshots
- ✅ Steam/itch.io page complete
- ✅ Press kit ready
- ✅ Game launched publicly
- ✅ Initial reviews monitored

**Phase Complete When:** Game is live and selling

---

## Post-Launch: Support & Updates (Weeks 33+)

**Goal:** Bug fixes, community engagement, DLC planning

**Ongoing Tasks:**
- 🔄 Monitor reviews and feedback
- 🔄 Hot-fix critical bugs (within 24 hours)
- 🔄 Balance patches (monthly)
- 🔄 Community engagement (Discord, Reddit)
- 🔄 Steam Workshop integration (v1.1 feature)
- 🔄 Mission editor (v1.2 feature)
- 🔄 Async PvP (v1.3 feature - if successful)

**Success Metrics:**
- 80%+ positive Steam reviews
- 1,000+ copies sold in first month
- 40%+ campaign completion rate
- 15%+ Day 30 retention

---

## Buffer Time: 4 weeks

Embedded across phases for unexpected issues:
- **Weeks 6-7:** After Phase 1 (tutorial/save system)
- **Weeks 14-15:** After Phase 2 (content expansion)
- **Weeks 20-21:** After Phase 3 (art/audio)
- **Weeks 28-29:** After Phase 5 (QA)

**Total Timeline:** 32 weeks (8 months) from MVP to launch

---

## Risk Tracking

| Risk | Impact | Likelihood | Mitigation | Status |
|------|--------|------------|------------|--------|
| **Tutorial takes longer than planned** | HIGH | MEDIUM | Start early, get feedback, iterate quickly | 🟡 Monitor |
| **Art quality below target** | HIGH | LOW | Contract professional pixel artist if needed | 🟢 Low risk |
| **Balance issues found late** | MEDIUM | MEDIUM | Playtest early and often, JSON-driven tuning | 🟡 Monitor |
| **Scope creep (feature bloat)** | HIGH | MEDIUM | Strict prioritization, refer to scope doc | 🟡 Monitor |
| **Solo dev burnout** | HIGH | MEDIUM | Sustainable pace, 40hr weeks max, take breaks | 🟡 Monitor |
| **Save system complexity** | MEDIUM | LOW | Use Godot's built-in serialization | 🟢 Low risk |
| **Audio licensing issues** | MEDIUM | LOW | Source royalty-free or commission original | 🟢 Low risk |
| **Platform export bugs** | MEDIUM | LOW | Godot exports natively, test early | 🟢 Low risk |
| **Market saturation (competing releases)** | MEDIUM | MEDIUM | Unique genre blend, clear marketing | 🟡 Monitor |
| **Low wishlist count** | MEDIUM | MEDIUM | Build community pre-launch, trailer quality | 🟡 Monitor |

**Risk Mitigation Strategy:**
- Weekly check-ins on progress vs timeline
- Monthly risk review and adjustment
- Clear scope cut candidates ready
- External playtesting early (Week 6)

---

## Scope Cut Candidates

**If timeline slips, cut these first (in order):**

### Tier 1: Nice-to-Have (Save 2-3 weeks)
1. **Mission objectives** (win with <X budget, etc.)
   - Impact: Reduces replayability slightly
   - Saves: 4 days
   - Can add in v1.1

2. **Endless mode**
   - Impact: Less long-term replayability at launch
   - Saves: 1 week
   - Can add in v1.2

3. **Additional hull types** (beyond 5 total)
   - Impact: Less variety, but 5 is sufficient
   - Saves: 1 week
   - Can add post-launch

4. **Keybind remapping**
   - Impact: Minor QOL loss
   - Saves: 2 days
   - Can add in v1.1

### Tier 2: Defer to Post-Launch (Save 1-2 weeks)
5. **Progression/unlock system**
   - Impact: All rooms/hulls available from start
   - Saves: 1 week
   - Not critical for MVP

6. **Advanced VFX** (particles, screen shake)
   - Impact: Less visual polish
   - Saves: 3 days
   - Still looks good without

7. **Ship detail sprites** (greebles, variations)
   - Impact: Ships look simpler
   - Saves: 3 days
   - Functional over aesthetic

### Tier 3: Reduce Scope (Save 1-2 weeks)
8. **Reduce mission count** (10 instead of 15)
   - Impact: Shorter campaign (3-4 hours instead of 5-6)
   - Saves: 1 week
   - Still satisfying

9. **Fewer room types** (12 instead of 15)
   - Impact: Less variety, but 12 is solid
   - Saves: 3 days
   - Core types covered

10. **Fewer enemy archetypes** (15 instead of 20)
    - Impact: Less variety, but sufficient
    - Saves: 3 days
    - Good balance

**TOTAL CUTS AVAILABLE: 6-8 weeks if needed**

---

## DO NOT CUT (Critical Path)

**These features are mandatory for 1.0 launch:**

1. ✅ **Core systems** (already complete)
2. 🔴 **Tutorial** - Players will bounce off without it
3. 🔴 **Save system** - Expected feature for campaign game
4. 🔴 **Settings menu** - Volume control minimum
5. 🔴 **Room art pass** - Placeholder sprites = unprofessional
6. 🔴 **Audio integration** - Silent game feels unfinished
7. 🔴 **10+ missions** - Minimum for 4-hour campaign
8. 🔴 **QA pass** - Broken game = bad launch/reviews
9. 🔴 **Trailer & screenshots** - Can't market without these
10. 🔴 **Steam page** - Required to sell

**Launch blockers: 10 items** (cannot ship without)

---

## Status Key

- 🟢 Complete
- 🟡 In Progress
- 🔴 Not Started
- ⚫ Blocked
- ❌ Cut from scope
- ✅ Done
- 🔄 Ongoing

---

## Weekly Update Template

**Copy this section each week for status updates:**

```markdown
## Week X Update (Date)

**Phase:** [Current Phase]
**Progress:** X% complete

### Completed This Week
- [Feature completed]
- [Bug fixed]

### In Progress
- [Feature being worked on]
- [Current focus]

### Blockers
- [Anything preventing progress]

### Next Week Goals
- [Goal 1]
- [Goal 2]

### Risks/Concerns
- [Any new risks]

### Metrics
- Playtests this week: X
- Bugs fixed: X
- Bugs remaining: X
```

---

**Timeline Summary:**
- **Weeks 0:** Pre-production planning (current)
- **Weeks 1-6:** Make It Teachable (tutorial, save, settings)
- **Weeks 7-14:** Add Content (missions, enemies, rooms)
- **Weeks 15-20:** Polish (art, audio, UI)
- **Weeks 21-24:** Meta-Systems (progression, achievements)
- **Weeks 25-28:** QA & Balance
- **Weeks 29-32:** Launch Prep
- **Week 32:** LAUNCH! 🚀

**Total:** 32 weeks (8 months) from MVP to 1.0 launch

**Target Launch Date:** Q2-Q3 2025 (July-August 2025)

---

**This roadmap is a living document. Update weekly with actual progress, blockers, and timeline adjustments.**
