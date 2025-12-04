# Anonymous Crew Barks System - Complete Design Specification

**Version:** 1.0
**Date:** 2025-01-04
**Status:** Design Complete, Implementation Planned

---

## CORE CONCEPT

**Military professionals reacting to your design's performance in real-time.**

No names, no personalities, no stories. Just tense, professional crew doing their jobs as your ship fights. Think *Star Trek bridge crew under fire* or *Battlestar Galactica damage control teams*.

**Key Principle:** Crew comments on WHAT'S HAPPENING, not what to do. They're reactive witnesses, not advisors.

---

## DESIGN PILLARS FOR THIS SYSTEM

### 1. Anonymous & Professional
- No crew names (just roles: "Helm", "Weapons", "Engineering")
- No backstories or character development
- Military/technical language
- Interchangeable voices

### 2. Reactive, Not Proactive
- ❌ "We should target their reactor!" (advice = implies control)
- ✅ "Their reactor's breached!" (observation = feedback)
- ❌ "Captain, recommend we retreat!" (strategy = wrong game)
- ✅ "Hull breach on Deck 3!" (report = atmosphere)

### 3. Reinforces Your Design Decisions
- Good design → confident crew
- Bad design → panicked crew
- Creates feedback loop: Your choices → Their reactions

### 4. Brief & Punchy
- 3-7 words per bark
- Doesn't interrupt combat flow
- Enhances, doesn't distract

---

## BARK CATEGORIES

[Full category details moved to sub-feature specs]

See detailed bark content in:
- [Bark Content & Selection](crew_barks_1.2_bark_content.md)

---

## BARK TRIGGERING SYSTEM

[Full trigger system details moved to sub-feature specs]

See technical implementation in:
- [Triggering System](crew_barks_1.1_triggering_system.md)

---

## VOICE ASSIGNMENT SYSTEM

### Roles (Not Names):

```gdscript
enum CrewRole {
    CAPTAIN,      # Commands, victory/defeat
    TACTICAL,     # Weapons, targeting updates
    HELM,         # Movement, positioning (if relevant)
    ENGINEERING,  # Power, damage control
    OPERATIONS,   # General systems status
}
```

### Voice Differentiation:

**Option A: Distinct Voice Types (No AI needed)**
- Deep male voice (Engineering)
- Higher male voice (Tactical)
- Female voice (Operations)
- Authoritative voice (Captain)

**Option B: Voice Processing (Same voice, filtered)**
- Engineering: Radio filter (static/crackle)
- Tactical: Clean, close
- Captain: Reverb (over speakers)

**Option C: Text Only with Role Tags**
```
[ENGINEERING] "Main reactor offline!"
[TACTICAL] "Enemy shields failing!"
[CAPTAIN] "Target destroyed!"
```

**Recommendation:** Start with Option C (text only), add voice later if budget allows.

---

## UI PRESENTATION

[Full UI details moved to sub-feature specs]

See UI implementation in:
- [UI Presentation](crew_barks_1.3_ui_presentation.md)

---

## AUDIO DESIGN

[Full audio details moved to sub-feature specs]

See audio implementation in:
- [Audio System](crew_barks_2.1_audio_system.md)
- [Voice Acting](crew_barks_2.2_voice_acting.md)

---

## BARK PROGRESSION (Based on Ship State)

### Healthy Ship (HP > 75%):

```
Confident, professional:
"Firing on target."
"Shields holding."
"Systems nominal."
"All stations ready."
```

### Damaged Ship (HP 50-75%):

```
Tense, focused:
"Taking damage!"
"Shields weakening!"
"Hull breach reported!"
"Stay on target!"
```

### Critical Ship (HP 25-50%):

```
Urgent, strained:
"We can't take much more!"
"Systems failing!"
"Hull integrity critical!"
"We're losing it!"
```

### Dying Ship (HP < 25%):

```
Panicked, desperate:
"We're coming apart!"
"ABANDON SHIP!"
"This is it!"
[STATIC]
```

**This creates narrative arc:** Confidence → Tension → Fear → Desperation

---

## IMPLEMENTATION PHASES

### Phase 1: Core System (Week 1) - MVP

**Text-only implementation:**
- Bark triggering system
- Priority/cooldown logic
- UI: Radio chatter box (top-right)
- Combat log integration
- ~50 barks across 5 categories

**Deliverable:** Barks appear as text during combat

**Scope:** 20-30 hours

**Sub-features:**
1. [Triggering System](crew_barks_1.1_triggering_system.md)
2. [Bark Content](crew_barks_1.2_bark_content.md)
3. [UI Presentation](crew_barks_1.3_ui_presentation.md)

---

### Phase 2: Audio Integration (Week 2) - Optional

**Add sound:**
- Radio static SFX
- TTS with radio processing (free)
- Or: Contract 1-2 voice actors for priority barks ($200-400)
- Background audio cues (alarms, power-down)

**Deliverable:** Barks have voice/audio

**Scope:** 15-20 hours

**Sub-features:**
1. [Audio System](crew_barks_2.1_audio_system.md)
2. [Voice Acting](crew_barks_2.2_voice_acting.md) (optional upgrade)

---

### Phase 3: Polish (Week 3) - Future Enhancement

**Refinement:**
- Balance bark frequency (playtesting)
- Add 50 more bark variations
- Better voice differentiation
- Contextual barks (mission-specific)

**Deliverable:** System feels natural and adds tension

**Scope:** 10-15 hours

**Sub-features:**
1. [Dynamic Barks](crew_barks_3.1_dynamic_barks.md)
2. [Polish & Balancing](crew_barks_3.2_polish.md)

---

## WRITING GUIDELINES

### DO:
- ✅ Keep it brief (3-7 words)
- ✅ Use technical/military language
- ✅ Report facts, not opinions
- ✅ Show stress through tone, not purple prose
- ✅ Make it sound like people doing jobs

### DON'T:
- ❌ Give advice ("We should target their shields!")
- ❌ Use names ("Stevens, get that power back on!")
- ❌ Tell jokes or quip (no Whedon-esque banter)
- ❌ Break character (stay professional military)
- ❌ Make it chatty (not a conversation, just reports)

---

## EXAMPLE BARK SCRIPTS

### Full Battle Arc:

```
TURN 1 (Opening salvo):
[TACTICAL] "Enemy in range!"
[WEAPONS] "All weapons locked on target!"

TURN 3 (Player takes first hit):
[TACTICAL] "Taking fire!"
[ENGINEERING] "Minor damage, decks 2 and 3!"

TURN 5 (Enemy destroys your shield):
[ENGINEERING] "Shield generator down!"
[OPS] "We're exposed!"

TURN 7 (Player destroys enemy weapon):
[TACTICAL] "Got their weapons!"
[CAPTAIN] "Stay on them!"

TURN 9 (Player HP critical):
[ENGINEERING] "Hull integrity at 20%!"
[HELM] "We can't take another hit like that!"

TURN 11 (Player destroys enemy reactor):
[TACTICAL] "Direct hit on their reactor!"
[WEAPONS] "Enemy power grid failing!"

TURN 12 (Victory):
[TACTICAL] "Target destroyed!"
[CAPTAIN] "All stations, stand down."
[ENGINEERING] "Damage control teams, report."
```

**Creates story through reactions:** Initial confidence → Taking hits → Critical moment → Turning point → Victory

---

## CONTEXTUAL BARKS

### Mission-Specific:

**Escort Mission:**
```
"The convoy's taking fire!"
"We need to protect those transports!"
"Convoy still intact!"
```

**Survival Mission:**
```
"More enemies inbound!"
"How many are there?!"
"Just hold together a little longer!"
```

**Boss Battle:**
```
"That thing is massive!"
"Our weapons aren't even scratching it!"
"Wait— we got through their armor!"
```

---

## DYNAMIC BARKS (Based on Design)

### If Player Has Good Design:

```
"Power routing is solid!"
"All systems at full capacity!"
"This ship's a beast!"
```

### If Player Has Bad Design:

```
"Why isn't this powered?!"
"I've got nothing here!"
"Who designed this thing?!"
```

**Meta-commentary on your design choices = engineering fantasy payoff**

---

## INTEGRATION WITH EXISTING SYSTEMS

### Synergy with Combat Log:

```
Combat Log (Text):
Turn 5 - Enemy destroys Main Reactor
         Your Weapons go offline
         Your Shields go offline

Radio Bark (Audio/Text):
[ENGINEERING] "Main reactor offline!"
[TACTICAL] "All weapons down!"
[OPS] "Shields are gone!"
```

**Log = data, Barks = human reaction to data**

### Synergy with Replay System:

- Replay includes all barks at exact timestamps
- Scrubbing timeline replays barks
- Helps player understand emotional flow of battle
- "Oh, THAT'S when they panicked— my reactor died"

---

## TESTING CHECKLIST

Before shipping:

- [ ] Barks don't overlap/spam
- [ ] Priority system works (critical events always heard)
- [ ] Cooldown feels natural (not too fast/slow)
- [ ] Voices are distinguishable (if using audio)
- [ ] Text is readable (good font, contrast)
- [ ] Barks match events (no desync)
- [ ] No repetition in single battle
- [ ] Emotional arc feels right (confidence → tension → resolution)
- [ ] Doesn't distract from combat visualization
- [ ] Replay includes all barks

---

## SCOPE ESTIMATE

### Minimal Implementation (Text Only):
- **Time:** 20-30 hours
- **Cost:** $0 (no voice actors)
- **Deliverable:** Text barks in combat + log

### Full Implementation (With Voice):
- **Time:** 45-60 hours
- **Cost:** $400-800 (voice actors)
- **Deliverable:** Voiced barks + text + polish

### Recommendation: **Start minimal, upgrade later**

Build text system first. If players love it and ask for voice, add it post-launch or for 1.1 update.

---

## VERDICT: WORTH BUILDING

This system **fits your game well** IF you keep it:
1. **Anonymous** (no character attachment)
2. **Brief** (doesn't slow combat)
3. **Reactive** (no strategy advice)
4. **Professional** (military crew, not quippy)

**Benefits:**
- Adds emotional texture to combat
- Makes battles feel alive
- Reinforces design consequences ("your reactor died → crew panics")
- Engineering fantasy payoff ("I designed this, now real people use it")

**Risks:**
- Could feel cheesy if writing is bad
- Could distract from combat if too frequent
- Could create cognitive dissonance if barks imply control

**Mitigation:**
- Start text-only (low investment)
- Test bark frequency carefully
- Keep writing technical/professional
- Don't introduce crew as characters

---

## IMPLEMENTATION ROADMAP

See full roadmap: [crew_barks_system.md](crew_barks_system.md)

**Sub-feature specifications:**
- Phase 1 (MVP):
  - [1.1 Triggering System](crew_barks_1.1_triggering_system.md)
  - [1.2 Bark Content](crew_barks_1.2_bark_content.md)
  - [1.3 UI Presentation](crew_barks_1.3_ui_presentation.md)

- Phase 2 (Audio):
  - [2.1 Audio System](crew_barks_2.1_audio_system.md)
  - [2.2 Voice Acting](crew_barks_2.2_voice_acting.md)

- Phase 3 (Polish):
  - [3.1 Dynamic Barks](crew_barks_3.1_dynamic_barks.md)
  - [3.2 Polish & Balancing](crew_barks_3.2_polish.md)

---

## DOCUMENT VERSION HISTORY

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-04 | Initial design spec, extracted from feature notes |
