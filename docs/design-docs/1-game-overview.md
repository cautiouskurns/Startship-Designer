# Game Overview

**Last Updated:** December 2024
**Status:** Prototype Complete - Moving to Pre-Production

---

## Elevator Pitch

A tactical starship design puzzle game where you act as chief engineer for Starfleet Command. Design ships on shaped hull grids using multi-tile rooms, manage power routing and room synergies, then watch your creation fight in automated turn-based combat. Win through smart spatial design decisions, not twitch skills. Iterate rapidly (sub-2-minute cycles) until your designs conquer the galaxy.

**Genre Blend:** Spatial Puzzle + Auto-Battler + Engineering Sandbox
**Comparable To:** FTL meets Into The Breach meets Tetris

---

## Core Design Pillars

### 1. Engineering Fantasy Over Piloting
**Why it matters:** Players want to feel like brilliant designers, not skilled pilots.

- You're the architect, not the warrior
- Success comes from layout optimization, not manual dexterity
- Satisfaction from watching your design succeed autonomously
- Fast iteration loop validates/invalidates design choices quickly
- No twitch skills required - pure strategic planning

### 2. Meaningful Spatial Puzzles
**Why it matters:** Room placement must feel strategic, not arbitrary.

- Multi-tile rooms create Tetris-like constraints (1×1 to 3×2 rectangles)
- Shaped hulls add unique spatial challenges per mission
- Power routing requires efficient reactor/conduit placement
- Room synergies reward thoughtful adjacency (Weapon+Weapon = +20% damage)
- Budget constraint forces trade-offs (offense vs defense vs power efficiency)
- Rotation mechanics add another layer of optimization

### 3. Clear Feedback Through Simplicity
**Why it matters:** Players must understand why they won or lost.

- Transparent combat math (no hidden mechanics or RNG)
- Auto-combat shows exactly what happened and why
- Combat replay system with timeline scrubbing for detailed analysis
- Real-time stat displays (offense, defense, thrust, HP)
- Visual power grid shows which rooms are active
- Failure = learning opportunity, not frustration

---

## Target Audience

### Primary Audience
- **Strategy/Puzzle Gamers (25-45 years old)**
  - Played FTL, Into The Breach, Slay the Spire
  - Prefer planning over execution
  - Enjoy optimization puzzles
  - Like transparent systems (no hidden math)
  - Value "one more try" iteration loops

### Secondary Audience
- **Casual Strategy Fans**
  - Intimidated by RTS/4X complexity
  - Want meaningful decisions without micromanagement
  - Short session lengths (15-30 min)
  - Prefer turn-based to real-time

- **Creative Players**
  - Enjoy ship/base building games (Cosmoteer, Reassembly)
  - Like to experiment and optimize
  - Appreciate engineering aesthetics
  - Save/share designs with friends

### Anti-Audience
- **Action Gamers:** Real-time piloting, no combat control
- **Story-First Players:** Minimal narrative, mechanics-focused
- **Perfectionist Min-Maxers:** Some randomness in combat (room destruction targeting)
- **Multiplayer-Only:** Single-player focused (async PvP maybe later)

---

## Unique Selling Points (USPs)

### 1. Tetris Meets FTL
Multi-tile room placement on shaped hulls creates unique spatial constraints. Not just filling a rectangle - rooms have varied sizes (1×1 to 3×2), hulls have unique shapes (Frigate: 10×4, Battleship: 7×7), and rotation adds depth. **Unique in genre.**

### 2. Power Routing Puzzle Layer
Reactors power 8 adjacent tiles, conduits extend range, relays create power hubs. Efficient power grid design separates good ships from great ships. Unpowered rooms are dead weight. **Adds optimization depth without micromanagement.**

### 3. Sub-2-Minute Iteration Loop
Design (60-90s) → Combat (30-60s) → Analyze (10-20s) → Redesign. Faster than FTL (2+ hour runs), more immediate feedback than Into The Breach (longer battles). **Enables rapid experimentation.**

### 4. Transparent Auto-Battle
Watch your design fight with full combat replay, timeline scrubbing, and turn-by-turn log. Always know why you lost. No "unfair RNG" - failures point to design flaws. **Respects player intelligence.**

### 5. Room Synergy System
Adjacent room pairs create combat bonuses (Weapon+Weapon = Fire Rate, Shield+Reactor = Shield Capacity, Engine+Engine = Initiative, Weapon+Armor = Durability). **Rewards thoughtful adjacency, not just efficient packing.**

### 6. Engineering Aesthetic
Blueprint-style cyan UI, grid-based design, power line visualizations, technical readouts. Appeals to engineering fantasy. **Distinct visual identity.**

---

## Gameplay Loop

```
Main Menu
    ↓
Mission Select (3 missions, unlock sequentially)
    ↓
Hull Selection (Frigate, Cruiser, Battleship)
    ↓
Ship Designer (60-90 seconds)
├─ Place 9 room types on shaped grid
├─ Manage budget (20-50 points)
├─ Route power (reactors → conduits → rooms)
├─ Maximize synergies (adjacent room pairs)
└─ Save template for reuse (optional)
    ↓
Auto-Combat (30-60 seconds)
├─ Turn-based resolution (initiative → attack → damage → destroy)
├─ Watch your design fight
├─ Enemy uses intelligent targeting (WEAPONS_FIRST, POWER_FIRST, RANDOM)
└─ Visual feedback (damage numbers, explosions, flashes)
    ↓
Results
├─ VICTORY → Unlock next mission → Mission Select
└─ DEFEAT → Replay available → Redesign
         ↓
    Ship Designer (iterate with replay insights)
```

**Core Loop:** Design → Test → Analyze → Iterate (under 2 minutes)

**Meta Loop:** Mission 1 → Mission 2 → Mission 3 → Victory Screen

---

## Competitive Analysis

| Game | Similar | Different | Our Advantage |
|------|---------|-----------|---------------|
| **FTL: Faster Than Light** | Room-based ship design, combat with system damage, spatial layout matters | Real-time combat (we're turn-based auto), crew management (we don't have), 2+ hour runs (we're 15-30 min sessions) | Faster iteration, clearer failure feedback, focus on puzzle over simulation |
| **Into The Breach** | Puzzle-combat, transparent systems, iterative design, clear cause-effect | Grid-based mech tactics (we're ship design + auto-battle), unit positioning (we're room placement) | Spatial room placement puzzle, power routing depth, synergy system |
| **Cosmoteer** | Detailed ship design, modular rooms, power systems, part placement | Real-time action combat, ship piloting (we're auto-battle), physics simulation | Faster sessions, strategic depth without simulation complexity, clearer feedback |
| **Reassembly** | Ship design with block placement, modular construction | Action gameplay, physics-based combat (we're turn-based), sandbox focus | Puzzle-focused, mission structure, clear win conditions |
| **Autonauts** | Grid-based building, automation, watch creations work | Resource gathering, base building (we're combat-focused) | Combat-focused, faster sessions, clearer failure feedback |

**Market Position:**
- **Niche:** Strategy/puzzle gamers who prefer planning over execution
- **Session Length:** 15-30 minutes (vs FTL's 2+ hours, ITB's 45+ min)
- **Price Point:** $10-15 (similar to Into The Breach)
- **Differentiator:** Multi-tile Tetris puzzle + power routing + synergies = unique depth

---

## Success Metrics

### Prototype Validation
- **Score:** 23/25 (avg 4.6/5) ✅
- **Critical Questions:**
  - Q1: Design → iterate loop satisfying? **5/5** ✅
  - Q2: Placement feels strategic? **5/5** ✅
  - Q3: Combat readable? **4/5** ✅
  - Q4: Budget creates trade-offs? **5/5** ✅
  - Q5: Engineering fantasy compelling? **4/5** ✅
- **Decision:** Build Full Game ✅

### Target Retention (Post-Launch)
- **Day 1:** 60%+ (tutorial completion)
- **Day 7:** 30%+ (finish 3-mission campaign)
- **Day 30:** 15%+ (complete all content or endless mode)

### Target Session Metrics
- **Session Length:** 15-30 minutes (single mission attempt)
- **Sessions to Beat Game:** 5-10 (with learning/iteration)
- **Total Playtime to "Beat":** 2-4 hours (3-mission campaign)
- **Replay Value:** 10+ hours (different hull types, optimization challenges, endless mode)

### Quality Targets
- **Tutorial Completion:** 80%+
- **Mission 1 Clear Rate:** 70%+ (within 5 attempts)
- **Campaign Completion:** 40%+ (beat all 3 missions)
- **Steam Rating:** 85%+ Positive (Very Positive)

---

## Platform & Tech

### Engine & Tools
- **Engine:** Godot 4.5
- **Language:** GDScript (41 files, ~5-6K lines of code)
- **Version Control:** Git
- **Asset Creation:** Aseprite (pixel art), Audacity (audio), Tiled (level design)
- **Data Format:** JSON (rooms, missions, hulls - easy balancing)

### Target Platforms
- **Primary:** Windows, macOS, Linux (native Godot export)
- **Secondary:** Steam (Steamworks integration for achievements/workshop)
- **Future:** Mobile (requires UI redesign), Console (requires controller support)

### Performance Targets
- **FPS:** 60 FPS locked
- **Resolution:** 1920×1080 native, scales to 1280×720+
- **RAM:** <500 MB
- **Storage:** <200 MB installed
- **Load Times:** <2 seconds (scene transitions instant)

### Development Approach
- **Team Size:** Solo developer with AI assistance (Claude Code)
- **Methodology:** Iterative prototyping → MVP → Pre-production → Alpha → Beta → Launch
- **Timeline:** 6-9 months from MVP to 1.0 launch (estimated)

---

## Scope Boundaries

### In Scope (MVP → 1.0 Launch)

**Core Systems:**
- ✅ Multi-tile room placement (9 room types)
- ✅ Power routing (reactors, conduits, relays)
- ✅ Room synergies (4 types)
- ✅ Shaped hulls (3 types: Frigate, Cruiser, Battleship)
- ✅ Auto-resolved turn-based combat
- ✅ Intelligent enemy AI (3 targeting strategies)
- ✅ Template save/load system
- ✅ Combat replay with timeline scrubbing

**Content:**
- ✅ 3-mission prototype campaign (MVP complete)
- 🔲 10-15 mission campaign (1.0 target)
- 🔲 15-20 enemy archetypes (currently 3)
- 🔲 5-6 hull types (currently 3)
- 🔲 12-15 room types (currently 9)

**Polish:**
- 🔲 Tutorial system (guided first mission)
- 🔲 Audio (SFX + music)
- 🔲 Sprite art (rooms, ships, VFX)
- 🔲 Settings menu (volume, resolution, keybinds)

**Meta-Systems:**
- 🔲 Save/load game state
- 🔲 Progression system (unlock rooms/hulls)
- 🔲 Achievements
- 🔲 Statistics tracking (ships designed, battles won, etc.)

### Post-Launch Features (1.1+)

**Expansion Content:**
- 🔲 Endless mode with procedural enemies
- 🔲 Daily/weekly challenges
- 🔲 Additional campaigns (community, seasonal)

**Advanced Features:**
- 🔲 Mission editor (create/share custom missions)
- 🔲 Steam Workshop integration
- 🔲 Async PvP (design ship, submit to matchmaking)
- 🔲 Sandbox mode (infinite budget, test environments)

**Quality of Life:**
- 🔲 Multiple save slots
- 🔲 Cloud saves
- 🔲 Leaderboards (fastest wins, lowest budget, etc.)
- 🔲 Replays (save/share battle recordings)

### Never In Scope

**Out of Scope (Breaks Core Design):**
- ❌ **Real-time combat control** - Violates "auto-battler" pillar
- ❌ **Crew management** - Adds micromanagement, slows iteration loop
- ❌ **Resource gathering/economy** - Not a 4X/management game
- ❌ **Open-world exploration** - Mission-based structure is core
- ❌ **Complex narrative** - Mechanics-first, story is flavor text
- ❌ **3D graphics** - 2D grid is core, 3D would be costly redesign
- ❌ **Multiplayer co-op** - Single-player design experience is core
- ❌ **Ship piloting/movement** - We're designers, not pilots
- ❌ **Random map generation** - Hand-crafted missions ensure balance
- ❌ **Permadeath roguelike** - Players should iterate on designs, not lose progress

**Reasoning:** These features either slow down the iteration loop, add unwanted complexity, or violate the "engineering fantasy" pillar. We're laser-focused on spatial puzzle + auto-battle + fast iteration.

---

## Risk Assessment

### Design Risks

**Risk:** Spatial puzzle too complex for average player
**Mitigation:** Tutorial, tooltips, easier starting missions, optional hints

**Risk:** Auto-combat feels too passive (players want control)
**Mitigation:** Emphasize design phase satisfaction, replay system engagement, fast pacing (30-60s battles)

**Risk:** Budget balance makes game too easy/hard
**Mitigation:** Extensive playtesting, JSON-based tuning (no code changes), difficulty settings

### Technical Risks

**Risk:** Godot 4.5 stability issues
**Mitigation:** Already stable for 2D, active community, can fallback to 4.4 if needed

**Risk:** Performance with large grids/ships
**Mitigation:** Grids are small (<50 rooms typical), turn-based (not real-time), tested at scale

**Risk:** Cross-platform export issues
**Mitigation:** Godot exports natively, test early on all platforms

### Market Risks

**Risk:** Niche genre appeal (puzzle + auto-battler)
**Mitigation:** Clear marketing ("FTL meets Into The Breach"), demo/wishlist campaign, targeted communities (r/ftlgame, r/IntoTheBreach)

**Risk:** Solo dev scope creep
**Mitigation:** Strict MVP scope, modular architecture (can ship without advanced features), prioritized backlog

**Risk:** Competitive indie strategy market
**Mitigation:** Unique genre blend, focus on polish and tight core loop, distinctive visual identity

---

## Version History

- **v0.1 MVP** (December 2024) - Prototype complete, 23/25 validation score
- **v1.0 Target** (Q2-Q3 2025) - Full campaign, tutorial, audio, art pass, save system

---

**This document defines WHAT the game is. Other docs define HOW to build it.**

**Next Steps:** See MVP_SUMMARY.md for detailed pre-production roadmap.
