# Anonymous Crew Barks System

**Status:** 🔴 Planned
**Priority:** ➡️ Medium
**Estimated Time:** 45-60 hours (Full implementation with voice) | 20-30 hours (Text-only MVP)
**Dependencies:** Combat system, Combat log
**Assigned To:** TBD

---

## Purpose

**Why does this feature exist?**
Combat currently lacks emotional texture and human feedback. Players watch ships exchange fire but don't feel the tension of a crew struggling to keep the ship operational. Crew barks add immersion by showing professional military personnel reacting to the player's design decisions in real-time.

**What does it enable?**
- Players experience emotional investment in combat outcomes
- Design consequences feel more visceral (reactor destroyed → crew panics)
- Combat becomes a narrative experience, not just number exchanges
- Engineering fantasy payoff: "I designed this ship, now real people use it"

**Success criteria:**
- Barks appear at appropriate moments without spam
- Players report feeling more tension/excitement during combat
- Barks reinforce understanding of what's happening (not confusion)
- System can be easily disabled if players find it distracting

---

## Feature Overview

Anonymous crew members (Tactical, Engineering, Operations, Captain) provide reactive commentary during combat via brief text/voice barks. They report damage, system failures, enemy status, and ship condition - creating an emotional arc from confidence to tension to desperation as the battle progresses.

**Key Principle:** Crew comments on WHAT'S HAPPENING, not what to do. They're reactive witnesses, not advisors.

---

## Sub-Features

### Phase 1: Core System (MVP - Text Only)
**Estimated Time:** 20-30 hours
**Status:** 🔴 Planned

#### 1.1 Bark Triggering System
[See: `crew_barks_1.1_triggering_system.md`]
- Event detection (component destroyed, HP thresholds, power failures)
- Priority system (critical > medium > low)
- Cooldown management (2 second minimum between barks)
- Queue system for multiple simultaneous events

#### 1.2 Bark Selection & Content
[See: `crew_barks_1.2_bark_content.md`]
- 5 bark categories: Damage Reports, Tactical Updates, System Status, Crew Stress, Victory/Defeat
- ~50 unique barks for MVP
- Context-aware selection (ship HP, systems remaining, battle phase)
- No-repetition logic (same bark not used twice in one battle)

#### 1.3 UI Presentation
[See: `crew_barks_1.3_ui_presentation.md`]
- Radio chatter box (top-right corner with fade in/out)
- Combat log integration (barks appear alongside combat events)
- Role tags [ENGINEERING], [TACTICAL], [CAPTAIN], [OPS]
- Clean typography and readability

**Phase 1 Deliverable:** Text barks appear during combat at appropriate moments

---

### Phase 2: Audio Integration (Polish)
**Estimated Time:** 15-20 hours
**Status:** 🔴 Planned

#### 2.1 Sound Effects & Processing
[See: `crew_barks_2.1_audio_system.md`]
- Radio static SFX (brief pop before bark)
- Radio distortion/compression effect
- Background ambience (alarm klaxons at <50% HP, power-down hum)

#### 2.2 Voice Implementation (Optional)
[See: `crew_barks_2.2_voice_acting.md`]
- Text-to-Speech with radio processing (free option)
- OR: Professional voice actors (4-5 roles, ~100-150 lines, $400-800 budget)
- Voice differentiation by role (deep/high/female/authoritative)

**Phase 2 Deliverable:** Barks have audio accompaniment

---

### Phase 3: Advanced Features (Future Enhancement)
**Estimated Time:** 10-15 hours
**Status:** 🔴 Planned

#### 3.1 Context-Aware Dynamic Barks
[See: `crew_barks_3.1_dynamic_barks.md`]
- Design-quality commentary ("Power routing is solid!" vs "Who designed this thing?!")
- Mission-specific barks (escort missions, boss battles, survival)
- Ship state progression (confident → tense → desperate)

#### 3.2 Polish & Balancing
[See: `crew_barks_3.2_polish.md`]
- Frequency tuning through playtesting
- +50 bark variations for variety
- Better voice differentiation (if using audio)
- Replay system integration (barks preserved in replay timeline)

**Phase 3 Deliverable:** System feels natural and significantly enhances combat tension

---

## Design Pillars

### 1. Anonymous & Professional
- No crew names (just roles: Helm, Weapons, Engineering)
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

## Integration Points

### Connects to:
- **Combat System:** Receives combat events (damage, destruction, HP changes)
- **Combat Log:** Barks appear alongside combat event text
- **Audio Manager:** Plays bark audio and SFX
- **Replay System:** Barks preserved with timestamps for replay

### Emits signals:
- `bark_triggered(text: String, role: CrewRole, priority: int)`
- `bark_audio_complete()`

### Listens for:
- Combat events from Combat.gd
- Component destruction from ShipData
- HP threshold changes

### Modifies:
- UI state (radio chatter box visibility, combat log content)
- Audio state (plays radio SFX, voice clips)

---

## System Architecture

```
CrewBarkSystem (Autoload Singleton)
├── BarkDatabase.gd (bark content & metadata)
├── BarkSelector.gd (context-aware bark selection)
├── BarkQueue.gd (priority queue + cooldown)
└── BarkUI.gd (radio box + combat log integration)

Combat.gd
└── Emits events → CrewBarkSystem

RadioChatterBox (UI Scene)
├── Background Panel
├── Role Label ([ENG])
└── Bark Label ("Main reactor offline!")

CombatLog (Existing)
└── Extended to show bark entries
```

---

## Acceptance Criteria (MVP - Phase 1)

Feature is complete when:

- [ ] Barks trigger on correct combat events (component destroyed, HP thresholds)
- [ ] Priority system works (critical events always heard, low priority can be skipped)
- [ ] Cooldown prevents bark spam (minimum 2 seconds between barks)
- [ ] No bark repetition within a single battle
- [ ] Radio chatter box displays bark text with role tags
- [ ] Combat log shows bark entries alongside combat events
- [ ] At least 50 unique barks cover all 5 categories
- [ ] Emotional arc feels natural (confidence → tension → desperation)
- [ ] Barks sync correctly with events (no desync or wrong context)
- [ ] System can be disabled via settings toggle

---

## Testing Checklist

### Functional Tests
- [ ] Component destruction triggers correct bark category
- [ ] HP thresholds (75%, 50%, 25%) trigger stress barks
- [ ] Victory/defeat barks play at battle end
- [ ] Power cascade failure triggers multiple relevant barks
- [ ] Enemy component destruction triggers tactical update barks

### Edge Case Tests
- [ ] Multiple simultaneous events queue correctly (priority order)
- [ ] Bark queue doesn't overflow (max 5 queued barks)
- [ ] Final bark before defeat plays completely (not cut off)
- [ ] No barks play after battle ends
- [ ] Cooldown resets between battles

### Integration Tests
- [ ] Works with existing combat system (no crashes)
- [ ] Combat log integration doesn't break log scrolling
- [ ] Doesn't affect combat turn timing
- [ ] Replay system preserves barks with correct timestamps

### Polish Tests
- [ ] Radio chatter box fade in/out smooth
- [ ] Text readable at all screen sizes
- [ ] Bark timing feels natural (not too fast/slow)
- [ ] No overlapping text in radio box
- [ ] Performance acceptable (60 FPS maintained)

---

## Known Limitations

- **MVP uses text only:** Voice acting requires budget, deferred to Phase 2
- **Fixed bark count:** MVP ships with ~50 barks, can feel repetitive in long sessions (Phase 3 adds +50)
- **No localization:** English only for MVP (translation system Phase 4)
- **Simple role assignment:** Barks assigned to roles manually, not procedurally (acceptable for MVP)

---

## Future Enhancements (Post-MVP)

*(Not for initial release, but worth noting)*

- **Localization:** Translate barks to other languages
- **Expanded bark library:** 200+ barks for greater variety
- **Crew customization:** Let players choose voice types (optional personality)
- **Dynamic bark generation:** AI-generated barks based on exact combat state (experimental)
- **Crew morale system:** Barks reflect crew confidence based on win/loss history
- **Tutorial integration:** Crew explains mechanics during tutorial missions

---

## Implementation Strategy

### Recommended Approach: **Phased Rollout**

1. **Week 1-2:** Build Phase 1 (text-only MVP)
   - Low investment, easy to test
   - Can ship without Phase 2 if needed
   - Validates core concept before voice investment

2. **Week 3:** Test with players
   - Do players like the system?
   - Is bark frequency correct?
   - Are barks helpful or distracting?

3. **Week 4-5:** Conditionally build Phase 2 (audio)
   - Only if Phase 1 tests well
   - Start with TTS + radio processing (free)
   - Upgrade to professional VO if budget available

4. **Week 6+:** Phase 3 polish (if time permits)

### Alternative Approach: **Post-Launch Update**

- Ship game without barks
- Gather player feedback on combat experience
- Add barks in v1.1 update if players want more immersion

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Barks feel cheesy/unprofessional | Medium | High | Strict writing guidelines, playtesting |
| Bark spam distracts from combat | Medium | Medium | Cooldown system, priority queue |
| Voice acting sounds bad | Low | High | Start with text, use TTS or hire pros |
| Players disable it immediately | Low | Low | Make it opt-in, not forced |
| Development time exceeds estimate | Medium | Medium | Ship Phase 1 only, defer Phase 2/3 |

---

## Budget & Resources

### Phase 1 (Text Only):
- **Development time:** 20-30 hours
- **Cost:** $0
- **Resources needed:** Designer + programmer

### Phase 2 (Audio):
- **Development time:** 15-20 hours
- **Cost:** $0 (TTS) or $400-800 (professional VO)
- **Resources needed:** Audio engineer, voice actors (optional)

### Phase 3 (Polish):
- **Development time:** 10-15 hours
- **Cost:** $0
- **Resources needed:** Designer + programmer

**Total (Full System):** 45-60 hours, $0-800

---

## Writing Guidelines

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

## Example Battle Arc

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

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-01-04 | Initial spec created | Feature planned based on design document |

---

## Related Documents

- [Full Design Specification](crew_barks_design_spec.md) - Complete design rationale
- [Sub-Feature: Triggering System](crew_barks_1.1_triggering_system.md)
- [Sub-Feature: Bark Content](crew_barks_1.2_bark_content.md)
- [Sub-Feature: UI Presentation](crew_barks_1.3_ui_presentation.md)
- [Sub-Feature: Audio System](crew_barks_2.1_audio_system.md)
- [Sub-Feature: Voice Acting](crew_barks_2.2_voice_acting.md)
- [Sub-Feature: Dynamic Barks](crew_barks_3.1_dynamic_barks.md)
- [Sub-Feature: Polish](crew_barks_3.2_polish.md)
