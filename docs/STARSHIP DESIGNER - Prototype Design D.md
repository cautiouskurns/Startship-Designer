# STARSHIP DESIGNER - Prototype Design Document

**Version:** 0.1 - Weekend Prototype

**Goal:** Test if "design ship → auto-battle → iterate" loop is satisfying for puzzle-combat genre

**Timeline:** One weekend (12-16 hours)

**Date:** November 22, 2024

---

## 1. CONCEPT

### Elevator Pitch

You're the chief starship designer for Starfleet Command during wartime - design ships on a grid, launch them into auto-battle, and iterate on failures until your designs win the war.

### Design Pillars

**Engineering Fantasy Over Piloting**

- Player is designer/engineer, not pilot or captain
- Success comes from smart layout decisions, not twitch skills
- Watch your creations fight (validation of design choices)
- Iterate quickly: redesign takes 60 seconds, test takes 30 seconds

**Meaningful Spatial Puzzles**

- Room placement physically matters (weapons forward, engines back)
- Power routing creates optimization puzzle (reactor powers adjacent)
- Damage location affects functionality (lose weapons = less damage)
- Trade-offs forced by budget constraint (can't have everything)

**Clear Feedback Through Simplicity**

- Auto-combat shows exactly why you won/lost
- No hidden mechanics (all stats visible, math is transparent)
- Immediate iteration (fail → redesign → retest in 90 seconds)
- Visual damage shows which rooms failed you

### Primary Influences

**FTL: Faster Than Light**

- Grid-based ship design with rooms affecting performance
- Applies: Room placement and damage disabling systems, but simplified (no crew, no real-time control)

**Into The Breach**

- Puzzle-combat where you preview outcomes
- Applies: Auto-resolved combat with clear cause-effect, iterate on losses

**Zachtronics Games (SpaceChem, Opus Magnum)**

- Engineering optimization puzzles with visual validation
- Applies: Design → test → optimize loop, satisfaction from watching your solution work

**Advance Wars**

- Unit design affects auto-resolved battles
- Applies: Pre-combat design phase determines outcome, not player execution during battle

---

## 2. WHAT WE'RE TESTING

### Critical Questions

**Q1: Is the design → watch → iterate loop satisfying?**

- Success = Player excited to redesign after loss, "one more try" feeling
- Failure = Player frustrated by opaque failures or bored by repetition

**Q2: Does room placement feel strategic (not arbitrary)?**

- Success = Player discusses placement choices, tries different layouts
- Failure = Player randomly places rooms, doesn't see pattern impact

**Q3: Is auto-combat readable enough to understand failures?**

- Success = After battle, player says "I lost because X, I'll fix Y"
- Failure = Player says "I don't know why I lost" or "combat is random"

**Q4: Does the 30-point budget create interesting trade-offs?**

- Success = Player agonizes over choices, removes rooms to fit others
- Failure = Player maxes out budget without thinking, or can't fill budget

**Q5: Is the engineering fantasy compelling?**

- Success = Player feels like designer/engineer, wants to optimize
- Failure = Player wishes they could pilot/control ship during battle

### Success Criteria

After Sunday night playtest, score each question 1-5:

- 1 = Doesn't work at all
- 3 = Works but needs improvement
- 5 = Works great, build full game

**Decision Threshold:**

- 20-25 points (4-5 avg): Build full game
- 15-19 points (3-4 avg): Iterate and retest
- <15 points (<3 avg): Pivot or kill

---

## 3. CORE MECHANICS

### Grid-Based Ship Design

Players place rooms on an 8×6 tile grid to create their starship. Each room costs points from a 30-point budget. Placement is constrained: weapons face forward (top 2 rows), engines face back (bottom 2 rows), reactors power adjacent tiles.

**Specifics:**

- Grid: 8 tiles wide × 6 tiles tall = 48 total positions
- Tile size: 64×64 pixels each, total grid = 512×384 pixels
- Budget: 30 points per mission
- Click empty tile → cycle through room types (Bridge → Weapon → Shield → Engine → Reactor → Armor → Empty)
- Right-click tile → remove room, refund points

**Interactions:**

- Must place Bridge (can't launch without it)
- Reactors "activate" adjacent rooms (visually shown with glow/connection lines)
- Unpowered rooms show as "inactive" (grayed out)

### Six Room Types

**Bridge (2 points)**

- Must have exactly 1, controls ship
- Can be placed anywhere
- If destroyed → instant loss

**Weapons (3 points)**

- Must be placed in top 2 rows (faces forward)
- Each weapon deals 10 damage per shot
- Destroyed weapons reduce damage output

**Shield (3 points)**

- Can be placed anywhere
- Each shield absorbs 15 HP of damage
- Destroyed shields reduce protection

**Engine (2 points)**

- Must be placed in bottom 2 rows (faces backward)
- Each engine adds +1 to initiative
- More engines = shoot first
- Destroyed engines lose initiative

**Reactor (2 points)**

- Can be placed anywhere
- Powers 4 adjacent tiles (up/down/left/right)
- Rooms not adjacent to reactor = inactive (shown grayed)
- Destroyed reactor deactivates connected rooms

**Armor (1 point)**

- Can be placed anywhere
- Adds +20 HP to hull
- No special function, just buffer health
- Cheap filler for unused budget

### Auto-Resolved Combat

Turn-based combat calculation that plays out automatically. Player watches but doesn't control. Initiative determines who shoots first, then ships trade volleys until one is destroyed.

**Combat Sequence:**

1. Initiative Check: Count engines (more = shoot first, tie = player wins)
2. Active Ship Shoots: Damage = (Active Weapons Count × 10)
3. Target Shields Absorb: Reduction = (Active Shields Count × 15), max damage absorbed
4. Remaining Damage Hits Hull: Hull HP decreases
5. Damage Destroys Random Room: Each 20 damage = 1 room destroyed (random selection from active rooms)
6. Switch Active Ship: Repeat steps 2-5 for other ship
7. Check Win Condition: If hull ≤ 0 → destroyed, if Bridge destroyed → instant loss
8. Next Turn: Return to step 2

**Example:**

- Player: 3 weapons, 2 shields, 2 engines, 80 hull HP
- Enemy: 2 weapons, 3 shields, 1 engine, 60 hull HP
- Turn 1: Player shoots first (2 engines > 1 engine)
    - Player deals 30 damage (3 weapons × 10)
    - Enemy shields absorb 45 (3 shields × 15, but only 30 needed)
    - 0 damage to hull, no rooms destroyed
- Turn 2: Enemy shoots
    - Enemy deals 20 damage (2 weapons × 10)
    - Player shields absorb 20 (2 shields × 15, enough)
    - 0 damage to hull
- Turn 3: Player shoots
    - Player deals 30 damage
    - Enemy shields absorb 45 (still full)
    - 0 damage to hull
- *Combat continues until shields are overwhelmed...*

### Power Routing System

Reactors create a "power grid" by activating adjacent rooms. Rooms not connected to power are inactive (don't contribute to ship stats). Destroyed reactors break the chain.

**Specifics:**

- Reactor powers tiles: [x-1,y], [x+1,y], [x,y-1], [x,y+1]
- Visual: Green lines connect reactor to powered rooms
- Unpowered rooms: Gray overlay, don't count in combat
- Example: 5 weapons placed, only 3 powered → only 3 count (3×10 = 30 damage)

**Strategic Depth:**

- Cheap build: Few reactors, tightly clustered rooms
- Spread build: Multiple reactors, rooms distributed
- Risk: Reactor destroyed = multiple rooms deactivate

### Budget Constraint System

30 points to spend per mission. Creates forced trade-offs: offense vs defense, raw power vs efficiency.

**Costs:**

- Bridge: 2 (required)
- Weapons: 3 each
- Shields: 3 each
- Engines: 2 each
- Reactors: 2 each
- Armor: 1 each

**Example Builds:**

- "Glass Cannon": 1 Bridge (2), 6 Weapons (18), 2 Reactors (4), 3 Armor (3) = 27 points
- "Turtle": 1 Bridge (2), 2 Weapons (6), 5 Shields (15), 2 Reactors (4), 2 Engines (4) = 31 ❌ over budget!
- "Balanced": 1 Bridge (2), 3 Weapons (9), 3 Shields (9), 2 Engines (4), 2 Reactors (4), 2 Armor (2) = 30 ✓

### Mission Structure

Three sequential missions with increasing difficulty. Each mission has a brief, an enemy ship design, and a win condition. Lose = redesign and retry, win = unlock next mission.

**Mission 1: "Patrol Duty"**

- Brief: "Pirates raiding supply lines. Need fast interceptor."
- Enemy: Scout (4×4 grid, 2 weapons, 1 shield, 2 engines, 40 HP)
- Player Budget: 20 points (reduced for tutorial)
- Win: Destroy enemy, advance to Mission 2

**Mission 2: "Convoy Defense"**

- Brief: "Enemy cruiser attacking convoy. Engage and destroy."
- Enemy: Raider (6×5 grid, 3 weapons, 2 shields, 1 engine, 60 HP)
- Player Budget: 25 points
- Win: Destroy enemy, advance to Mission 3

**Mission 3: "Fleet Battle"**

- Brief: "Capital ship inbound. This is our final stand."
- Enemy: Dreadnought (8×6 grid, 5 weapons, 3 shields, 2 engines, 100 HP)
- Player Budget: 30 points (full budget)
- Win: Destroy enemy, victory screen

### Hull HP System

Each ship has base hull HP. Armor rooms add +20 HP each. When damage exceeds shields, hull HP decreases. Hull ≤ 0 = ship destroyed.

**Specifics:**

- Base Hull: 60 HP (player and all enemies)
- Armor Bonus: +20 HP per armor room
- Example: 60 base + 3 armor rooms = 120 HP total
- Damage Calculation: (Incoming Damage - Shield Absorption) → subtract from Hull HP
- Death: Hull ≤ 0 OR Bridge destroyed = combat loss

**Visual:**

- Health bar above ship (green → yellow → red)
- Current HP / Max HP displayed numerically

---

## 4. PROTOTYPE SCOPE

### What's IN (Minimum Viable)

**Ship Designer:**

- 8×6 clickable grid (512×384 pixels)
- 6 room types (Bridge, Weapon, Shield, Engine, Reactor, Armor)
- Room placement/removal (left-click cycle, right-click remove)
- Budget display (30 points, updates in real-time)
- Power connection visual (green lines from reactor to adjacent)
- Launch button (disabled if no Bridge or over budget)

**Combat System:**

- Auto-resolved turn-based calculation
- 2 ships face each other (player left, enemy right)
- Health bars (green/yellow/red gradient)
- Turn indicator ("Player Turn" / "Enemy Turn" text)
- Damage numbers pop up on hit
- Room destruction visual (sprite explodes/grays out)
- Win/Lose screen (text + Redesign button)

**Content:**

- 3 missions with escalating difficulty
- Mission briefs (2-3 sentences text)
- 3 preset enemy ship designs (Scout, Raider, Dreadnought)
- Victory condition (beat all 3 missions)

**UI/Menus:**

- Mission select screen (shows 3 missions, locked/unlocked)
- Ship designer screen (grid + budget + launch)
- Combat screen (ships + health + turn info)
- Win/Lose screen (message + retry/continue button)

### What's OUT (Not for Prototype)

**❌ Multiple Player Ship Designs**

- Reason: Testing one design iteration loop, not ship variety
- Prototype: Design 1 ship per mission attempt

**❌ Crew Management**

- Reason: Not testing crew mechanics, too complex for weekend
- Prototype: Rooms just exist, no people to manage

**❌ Resource Gathering / Meta-Progression**

- Reason: Testing core combat loop, not economy
- Prototype: Fixed budget per mission, no carry-over

**❌ Ship Customization (Names/Colors)**

- Reason: Not testing expression, testing mechanics
- Prototype: Generic blue player ship, red enemy ships

**❌ Real-Time Combat Control**

- Reason: Testing auto-battle iteration, not piloting skill
- Prototype: Watch-only combat, no pause/target/maneuver

**❌ Procedural Enemies**

- Reason: Testing if handcrafted difficulty curve works
- Prototype: 3 preset enemy designs, not generated

**❌ Sound Effects / Music**

- Reason: Not testing audio, focus on mechanics
- Prototype: Silent (add if time permits Sunday afternoon)

**❌ Save System**

- Reason: 3 missions playable in one 15-minute session
- Prototype: Complete in single sitting or restart

**❌ Advanced UI (Tooltips, Tutorials, Settings)**

- Reason: Not testing onboarding, testing core loop
- Prototype: Assume player understands grid placement

---

## 5. IMPLEMENTATION PHASES

### Phase 1: Grid System (Saturday Morning - 4 hours)

**Goal:** Clickable grid where player can place/remove rooms and see budget update

**Deliverables:**

- 8×6 grid of tiles (64×64px each)
- Click tile → cycle through 7 states (6 room types + empty)
- Right-click tile → clear to empty
- Budget counter display (updates on placement)
- Room cost validation (can't place if over budget)

**Test:** Can place rooms, see budget, can't exceed 30 points

### Phase 2: Combat Math (Saturday Afternoon - 4 hours)

**Goal:** Auto-battle calculation that shows ships fighting with health bars

**Deliverables:**

- Combat screen with 2 ship sprites (player left, enemy right)
- Count rooms from grid → calculate stats (weapons, shields, engines, hull)
- Turn-based loop: initiative → damage → shields → hull → room destruction
- Health bars above ships (visual feedback)
- Win/Lose detection + screen

**Test:** Launch battle, watch ships trade hits, one ship wins

### Phase 3: Power System (Saturday Evening - 4 hours)

**Goal:** Reactors power adjacent rooms, unpowered rooms don't count

**Deliverables:**

- Reactor placement highlights adjacent tiles (green glow/lines)
- Combat counts only powered rooms
- Visual feedback (unpowered rooms grayed out)

**Test:** Place reactor, see powered tiles, remove reactor, see rooms deactivate

### Phase 4: Mission Structure (Sunday Morning - 3 hours)

**Goal:** 3 missions with enemy designs and progression

**Deliverables:**

- Mission select screen (3 buttons: Mission 1/2/3)
- Mission briefs (text overlay before designer)
- 3 enemy ship presets (Scout 4×4, Raider 6×5, Dreadnought 8×6)
- Mission unlock (beat 1 → unlock 2 → unlock 3)
- Victory screen (beat mission 3)

**Test:** Play through 3 missions, progression feels escalating

### Phase 5: Polish & Playtesting (Sunday Afternoon - 3 hours)

**Goal:** Visual feedback, balance tuning, playtest

**Deliverables:**

- Damage numbers pop on hit
- Room destruction animation (explosion sprite)
- Turn indicator text ("Player Turn")
- Balance pass (test all 3 missions beatable but challenging)
- Playtest with friend, gather feedback

**Test:** Friend can understand game, beat missions with iteration

---

## 6. SUCCESS METRICS

### Playtester Observations (Sunday Evening)

**During Design Phase:**

- Do they think about placement? (Good: "I'll put engines here because..." Bad: Random clicking)
- Do they mention trade-offs? (Good: "I wish I could fit more shields" Bad: Silent placement)
- Do they understand power? (Good: Cluster near reactor. Bad: Spread rooms, don't notice gray)

**During Combat:**

- Do they watch attentively? (Good: Lean in, watch health. Bad: Look away, bored)
- Do they understand outcome? (Good: "I lost because no shields" Bad: "Why did I lose?")
- Do they want to retry? (Good: "Let me try again" Bad: "Whatever, next mission")

**After Session:**

- Ask: "Did you feel like a designer or pilot?" (Want: Designer)
- Ask: "Could you tell why you won/lost?" (Want: Yes, very clear)
- Ask: "Would you play 10 missions like this?" (Want: Yes)

### Quantitative Targets

- Mission 1: Win within 3 attempts (tutorial difficulty)
- Mission 2: Win within 5 attempts (learning curve)
- Mission 3: Win within 7 attempts (peak challenge)
- Total session: 15-20 minutes (short enough to retest)
- Redesign speed: 60 seconds (fast iteration)

---

## 7. RISK MITIGATION

**Risk: Combat is opaque, player doesn't understand losses**

- Mitigation: Show damage numbers, health bars, turn-by-turn breakdown
- Fallback: Add post-battle "Combat Log" text summary

**Risk: Placement feels arbitrary, no strategy**

- Mitigation: Force weapon/engine constraints, require power routing
- Fallback: Add tooltips explaining optimal placement

**Risk: Budget too restrictive or too loose**

- Mitigation: Playtest Saturday night, tune costs before Sunday
- Fallback: Allow budget adjustment per mission (20/25/30)

**Risk: Auto-combat too slow or too fast**

- Mitigation: Prototype with 1 second per turn, adjust based on feel
- Fallback: Add "Fast Forward" button for repeat playthroughs

**Risk: 3 missions not enough to test loop**

- Mitigation: 3 missions = 30-60 min content with retries, sufficient for prototype
- Fallback: If time permits, add Mission 4 as stretch goal

---

## 8. POST-PROTOTYPE DECISION TREE

### If Score 20-25 (Build Full Game)

**Immediate Next Steps:**

- Design 10 total missions (full campaign)
- Add 4 more room types (Repair Bay, Scanner, Hangar, ECM)
- Implement special mission conditions (asteroids, ambush, multi-battle)
- Create mission briefings with light narrative
- Build meta-progression (unlock advanced rooms)

**Timeline:** 12 weeks to v1.0

### If Score 15-19 (Iterate)

**Identified Issues → Solutions:**

- Combat unclear → Add detailed combat log
- Placement too simple → Add more room interactions
- Budget wrong → Rebalance costs after more testing
- Not enough content → Prototype 3 more missions before committing

**Timeline:** 1 week iteration, retest, reassess

### If Score <15 (Pivot/Kill)

**Exit Criteria:**

- Core loop not fun after fixes
- Fantasy doesn't resonate (player wants to pilot)
- Optimization puzzle not engaging (placement feels random)

**Pivot Options:**

- Keep grid system, add real-time control (make it FTL-like)
- Keep auto-battle, make it deck-builder (card-based ship design)
- Keep engineering fantasy, make it puzzle-only (no combat, pure optimization challenges)

---

**END OF DESIGN DOCUMENT**

This prototype tests the absolute core: Can "design ship → watch it fight → iterate on failure" sustain a full game? By Sunday night, you'll know.