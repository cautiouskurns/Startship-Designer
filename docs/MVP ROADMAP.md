# MVP Feature Roadmap

**Project:** Starship Designer
**Status:** Active Development
**Last Updated:** November 26, 2024

This document contains feature specifications for MVP development. Each feature follows the standard specification format for clear implementation guidance.

---

# Component-Specific Targeting

**Total Time Estimate:** 4-6 hours
**Tests Critical Questions:** Q3 (Combat readable), Q2 (Placement strategic)

---

## Feature 1: Target Selection System

**Tests:** Q3 (Combat readable), Q2 (Placement strategic)
**Time:** 2 hours

### What Player Sees:
- **During combat:** Brief targeting line (2px yellow line) appears from attacker to specific target component (0.2s duration)
- **Hit component:** Target component flashes white (2 flashes) before damage animation
- **Combat log:** New line shows "Enemy [Type] targets your [Component]" in white text
- **Visual state:** Same position as existing combat UI, log panel bottom-left

### What Player Does:
- **Watch combat:** Player sees enemy deliberately targeting specific components (not random anymore)
- **Read log:** Player understands which systems are being attacked
- **Notice patterns:** After 2-3 combats, player recognizes enemy targeting preferences
- **Adjust designs:** Player moves critical components to safer positions

### How It Works:
**Core Logic:**
1. When weapon fires, instead of random component, select target based on priority
2. Enemy weapons have targeting priority: WEAPONS_FIRST, POWER_FIRST, or RANDOM
3. Filter available components by priority (e.g., WEAPONS_FIRST only considers enemy weapon rooms)
4. If priority list is empty, fall back to random selection
5. Draw targeting line from attacker center to target component center
6. Apply damage to selected component (existing damage system)

**Targeting Priorities:**
- WEAPONS_FIRST: Target enemy weapons (disarm threat)
- POWER_FIRST: Target reactors/relays (cripple ship)
- RANDOM: Any component (current behavior)

**Enemy Type Mapping:**
- Mission 0 (Scout): RANDOM (tutorial, predictable)
- Mission 1 (Raider): WEAPONS_FIRST (aggressive)
- Mission 2 (Dreadnought): POWER_FIRST (tactical)

### Acceptance Criteria:
- [ ] Visual check: See yellow targeting line appear briefly when enemy fires
- [ ] Visual check: Target component flashes white before damage
- [ ] Interaction check: Combat log shows "Enemy Raider targets your Weapon" messages
- [ ] Manual test: Fight Raider (Mission 1) with 3 weapons → enemy prioritizes destroying weapons first
- [ ] Manual test: Fight Dreadnought (Mission 2) with 2 reactors → enemy targets reactors/relays first
- [ ] Manual test: If no priority targets exist, enemy still hits something (fallback works)

### Shortcuts for This Phase:
- Hard-code 3 priority types (don't make it data-driven yet)
- Simple line drawing (no arc or animated beam)
- Target line disappears instantly (no fade-out animation)
- Don't calculate line-of-sight or armor blocking yet (always hit selected target)
- Combat log shows targeting, but don't add filtering/search

---

## Feature 2: Component Exposure & Protection

**Tests:** Q2 (Placement strategic), Q4 (Budget trade-offs)
**Time:** 2.5 hours

### What Player Sees:
**In Combat:**
- **Exposed components:** Edge components get hit more often (observable pattern over multiple fights)
- **Protected components:** Interior components targeted less frequently
- **Armor shields:** When armor adjacent to target, damage message shows "Armor absorbs hit!"

**In Designer (Future Enhancement - Phase 2):**
- **Exposure overlay:** Toggle button shows color-coded exposure levels
  - Red tiles: High exposure (hull edge)
  - Yellow tiles: Medium exposure (1 tile from edge)
  - Green tiles: Low exposure (2+ tiles interior)

### What Player Does:
- **Notice vulnerability:** After losing edge-mounted reactors repeatedly, player learns placement matters
- **Bury critical systems:** Player places reactor/bridge in ship interior
- **Use armor tactically:** Player places armor adjacent to critical components
- **Iterate designs:** Player redesigns after seeing which components die first

### How It Works:
**Exposure Calculation:**
1. For each component, calculate distance to nearest hull edge
2. Edge (0 tiles away): High exposure = +20% targeting weight
3. Near-edge (1 tile away): Medium exposure = Normal targeting weight
4. Interior (2+ tiles away): Low exposure = -20% targeting weight
5. When selecting target, multiply base chance by exposure modifier

**Armor Protection Logic:**
1. After selecting target component, check adjacent tiles for armor
2. If armor found adjacent to target, 50% chance armor absorbs hit instead
3. Damage goes to armor component, not original target
4. Combat log shows "Armor protects [Component]!"

**Exposure Formula:**
```
exposure_modifier = 1.0
if distance_to_edge == 0: exposure_modifier = 1.2
elif distance_to_edge >= 2: exposure_modifier = 0.8

target_weight = base_priority * exposure_modifier
```

### Acceptance Criteria:
- [ ] Manual test: Place reactor on ship edge → gets targeted more frequently than interior reactor
- [ ] Manual test: Place reactor 3 tiles from edge → survives longer than edge reactor
- [ ] Manual test: Place armor adjacent to weapon → some hits absorbed by armor instead
- [ ] Visual check: Combat log shows "Armor protects Weapon!" messages
- [ ] Manual test: Fight 5 times with edge reactor vs 5 times with interior reactor → interior survives ~30% more often

### Shortcuts for This Phase:
- Simple distance-to-edge calculation (Manhattan distance, not true shortest path)
- Only check 4 adjacent tiles for armor (not diagonal)
- 50% armor block chance (don't make it depend on armor count)
- Don't add exposure overlay to designer yet (defer to polish phase)
- Don't weight targeting by component size (all components equal weight for now)

---

## Feature 3: Enhanced Visual Feedback

**Tests:** Q3 (Combat readable), Q5 (Engineering fantasy)
**Time:** 1.5 hours

### What Player Sees:
- **Targeting beam:** Yellow line animates from attacker → target (0.3s duration, fades out)
- **Target locked:** Small crosshair sprite appears over target component (0.2s before hit)
- **Hit feedback:** Larger flash + "CRITICAL" text if hitting a power/weapon component
- **Combat log colors:**
  - Red text: "Enemy targets your Reactor" (critical system)
  - Yellow text: "Enemy targets your Weapon" (important system)
  - White text: "Enemy targets your Armor" (expendable)
- **Pause option:** "PAUSE" button appears during combat (player can read log at own pace)

### What Player Does:
- **Watch beam:** Player follows visual line to see what enemy is aiming at
- **Read critical hits:** Player immediately notices when reactor/bridge targeted
- **Use pause:** Player clicks PAUSE to read combat log details mid-fight
- **Learn patterns:** After 3 fights, player predicts enemy targeting from beam direction

### How It Works:
**Beam Animation:**
1. Create Line2D from attacker center to target center
2. Animate alpha: 0 → 1.0 over 0.1s, hold at 1.0 for 0.2s, fade 1.0 → 0 over 0.1s
3. Width = 3px, color = yellow #FFDD00

**Crosshair Indicator:**
1. Small sprite (16×16px) with crosshair icon
2. Position = target component center
3. Appears 0.2s before damage applied
4. Disappears after damage flash

**Critical System Detection:**
- If target is REACTOR or BRIDGE or RELAY: show "CRITICAL" red text above component
- If target is WEAPON or SHIELD: show "HIT" yellow text
- If target is ARMOR or CONDUIT: show "DAMAGE" white text

**Combat Log Colors:**
- Add theme color overrides to RichTextLabel
- Use BBCode: `[color=red]Enemy targets your Reactor[/color]`

### Acceptance Criteria:
- [ ] Visual check: See animated yellow beam from enemy to target component
- [ ] Visual check: Small crosshair appears over target 0.2s before hit
- [ ] Visual check: "CRITICAL" red text appears when reactor/bridge hit
- [ ] Visual check: Combat log shows red text for critical systems, yellow for weapons/shields
- [ ] Interaction check: Click PAUSE button → combat freezes, can read log
- [ ] Manual test: Watch 3 consecutive fights → can predict which component will be hit by watching beam

### Shortcuts for This Phase:
- Crosshair is simple sprite (not animated spinning)
- Beam is straight line (no arc or laser effect)
- Pause stops all animation (don't add step-by-step controls)
- Critical text appears above component (don't add dramatic screen shake)
- Combat log doesn't save history (clears each fight)

---

## IMPLEMENTATION ORDER

**Day 1 (2.5 hours):**
1. Feature 1 basic targeting (1.5h)
2. Combat log integration (0.5h)
3. Test with all 3 missions (0.5h)

**Day 2 (2 hours):**
1. Feature 2 exposure calculation (1h)
2. Feature 2 armor protection (1h)

**Day 3 (1.5 hours):**
1. Feature 3 visual feedback (1h)
2. Polish & balance testing (0.5h)

---

## SUCCESS METRICS

After implementation, test 5 critical questions:

1. **Can player explain why they lost?** → "Enemy kept hitting my reactor" (not "bad luck")
2. **Does placement feel strategic?** → Player moves reactor from edge to interior
3. **Is armor now valuable?** → Player adds armor around critical components
4. **Is combat more readable?** → Player follows targeting beams, understands flow
5. **Does redundancy matter?** → Player adds backup reactors/weapons

**Target:** All 5 questions score 4+/5 after feature complete

---

## FUTURE ENHANCEMENTS (Out of Scope)

- ❌ Line-of-sight blocking (components behind others harder to hit)
- ❌ Component size weighting (larger components easier to hit)
- ❌ Player weapon targeting control (player chooses enemy targets)
- ❌ Exposure overlay in designer (show risk levels before combat)
- ❌ Targeting AI learning (enemy adapts to player strategy)

These defer to post-prototype or full game development.

---

# Future Features

*Add new feature specifications below following the same format*

---

## Feature Template

**Tests:** [Which critical question from design doc]
**Time:** [Hours estimate]

### What Player Sees:
- **Position & size:** Where on screen, dimensions
- **Colors & appearance:** Visual style, theme
- **Visual states:** Normal/hover/active/disabled

### What Player Does:
- **Action 1:** Click/hover/input description
- **Action 2:** Resulting immediate feedback
- **Action 3:** Learning outcome

### How It Works:
**Core Logic:**
1. Step by step explanation
2. Key formulas or rules
3. Connection to existing systems

**Important Numbers:**
- Value 1: Description and source (from GDD or testing)
- Value 2: Why this value matters

### Acceptance Criteria:
- [ ] Visual check: Can see [X] at [Y position]
- [ ] Interaction check: Click [A] → see [B] happen
- [ ] Manual test: Do [steps], expect [result]

### Shortcuts for This Phase:
- Hard-code [X] instead of making it configurable
- Use placeholder [Y] instead of final art
- Don't implement [Z] until later phase
- Defer [W] to polish

---

**END OF MVP ROADMAP**
