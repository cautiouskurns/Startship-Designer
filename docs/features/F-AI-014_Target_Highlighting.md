# F-AI-014: Target Highlighting

**Status:** 🔴 Planned
**Priority:** 🔥 Critical
**Estimated Time:** 1 day
**Dependencies:** F-AI-005 (Threat Assessment System)
**Phase:** 4 - Visual Feedback

---

## Purpose

**Why does this feature exist?**
Players need to instantly see what the AI is targeting without reading logs. Visual highlighting creates immediate understanding of AI intent and makes combat more engaging to watch.

**What does it enable?**
Colored outlines/glows on targeted rooms show AI decisions in real-time. High-threat targets glow red, selected targets flash, multi-target attacks show split focus. Combat becomes a visual story, not just numbers.

**Success criteria:**
- Target highlighting visible within 0.1s of AI decision
- 90% of playtesters correctly identify AI target from visual alone
- Highlighting doesn't obstruct room visibility
- Different highlight colors convey threat/intent clearly

---

## How It Works

### Overview

Rooms on enemy ships are highlighted with colored outlines/glows based on AI assessment:
- **Red glow**: High-threat target (threat score >70)
- **Yellow pulse**: Selected primary target
- **Orange pulse**: Selected secondary target (multi-target)
- **White flash**: Room being attacked right now
- **Gray outline**: Low-priority target (threat score <30)

Highlights update dynamically as AI makes decisions each turn.

### Rules & Constraints

**Highlight Types:**

1. **Threat Level (Pre-Attack)**:
   - Red glow (pulsing): Threat score >70 (high danger)
   - Orange outline: Threat score 40-70 (moderate)
   - Gray outline: Threat score <40 (low priority)
   - Duration: Persistent (updates each turn)

2. **Target Selection**:
   - Yellow pulse (bright): Primary target selected
   - Orange pulse: Secondary target (if multi-target)
   - Duration: 1 second before attack

3. **Attack Execution**:
   - White flash (intense): Room being attacked NOW
   - Duration: 0.3 seconds during attack animation

4. **Special Highlights**:
   - Purple outline: Tactic-driven target (Surgical Strike, Focus Fire)
   - Blue outline: Synergy room (protective priority)

**Visual Implementation:**
- Outline: 4px colored border around room sprite
- Glow: Colored shadow/emission shader (subtle pulse)
- Flash: Modulate color overlay (intense, brief)

**Highlight Priority** (if multiple apply):
1. White flash (attack) - highest
2. Yellow/Orange pulse (target selection)
3. Purple outline (tactic)
4. Red glow (threat)
5. Gray outline (low priority) - lowest

---

## User Interaction

### Controls
None (automatic highlighting)

### Visual Feedback
- Threat glows visible continuously
- Target pulses before attack (anticipation)
- Flash during attack (impact moment)
- Smooth transitions between states (0.2s)

---

## Visual Design

### Layout
- Highlights overlay on room sprites
- Z-index: Above room, below damage numbers

### Components
- ColorRect overlay (for flash)
- Shader material (for glow effect)
- Line2D (for outline)

### Visual Style
- **Red**: High threat (#E24A4A, 80% opacity)
- **Yellow**: Primary target (#E2D44A, 100% opacity, pulse)
- **Orange**: Secondary target (#E2A04A, 100% opacity, pulse)
- **White**: Attack flash (#FFFFFF, 100% opacity, brief)
- **Purple**: Tactic target (#A04AE2, 70% opacity)
- **Gray**: Low priority (#6C6C6C, 50% opacity)

---

## Technical Implementation

**New File: `scripts/ui/TargetHighlighting.gd`**
- Manages room highlight effects
- Methods:
  - highlight_threat(room_node: Node2D, threat_score: float)
  - highlight_target(room_node: Node2D, target_type: TargetType)
  - flash_attack(room_node: Node2D)
  - clear_highlights(ship_node: Node2D)

**Modified: `scripts/combat/Combat.gd`**
- After threat assessment: highlight enemy rooms by threat
- After target selection: highlight selected targets (yellow/orange)
- During attack: flash target white

### Configuration

```gdscript
const HIGHLIGHT_THREAT_HIGH_THRESHOLD = 70.0
const HIGHLIGHT_THREAT_LOW_THRESHOLD = 40.0
const HIGHLIGHT_TARGET_DURATION = 1.0  # Seconds
const HIGHLIGHT_ATTACK_FLASH_DURATION = 0.3
const HIGHLIGHT_PULSE_SPEED = 2.0  # Hz
```

---

## Acceptance Criteria

- [ ] High-threat rooms (score >70) glow red persistently
- [ ] Selected primary target pulses yellow for 1 second before attack
- [ ] Multi-target secondary target pulses orange
- [ ] Attacked room flashes white during damage
- [ ] Highlights don't obstruct room sprites
- [ ] Smooth transitions between highlight states
- [ ] Players identify targets from visual alone (90%+ in testing)

---

## Implementation Notes

**Performance**: Use shader materials for glow (GPU-accelerated), limit to 10 simultaneous highlights max.

**Design Philosophy**: Highlights should guide attention, not overwhelm. Subtle but clear.

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
