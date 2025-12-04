# Crew Barks Sub-Feature: Polish & Balancing

**Status:** 🔴 Planned
**Priority:** ⬇️ Low (Phase 3, final polish)
**Estimated Time:** 10-15 hours
**Dependencies:** All Phase 1 & 2 features
**Assigned To:** TBD
**Parent Feature:** [Anonymous Crew Barks System](crew_barks_system.md)

---

## Purpose

Final tuning pass: adjust bark frequency, add +50 bark variations to prevent repetition, improve voice differentiation, integrate with replay system, and add player-facing settings.

---

## Tasks

### Task 1: Bark Frequency Tuning (3 hours)

**Problem:** MVP cooldown (2.0s) may feel too fast or too slow depending on combat pace.

**Solution:**
- Playtesting with 5+ players
- Adjust cooldown based on feedback: 1.5s (fast), 2.0s (default), 3.0s (slow)
- Add setting: "Crew Bark Frequency" slider (1.0s - 5.0s)

**Acceptance:**
- [ ] Players report barks enhance combat (not distract)
- [ ] Frequency slider functional
- [ ] Default cooldown feels natural (not spammy, not silent)

---

### Task 2: Expanded Bark Library (5 hours)

**Problem:** 50 MVP barks feel repetitive after 10+ battles.

**Solution:**
- Write +50 additional barks across all categories
- Prioritize most common events (damage taken, component destroyed)
- Add fallback variations (3-5 generic barks per category)

**New Barks Added:**
- Damage Reports: +10 variations
- Tactical Updates: +15 variations
- System Status: +10 variations
- Crew Stress: +10 variations
- Victory/Defeat: +5 variations

**Acceptance:**
- [ ] Total bark count: 100+ unique lines
- [ ] No repetition in typical 30-turn battle
- [ ] All new barks follow writing guidelines

---

### Task 3: Voice Differentiation (2 hours)

**Problem:** If using TTS, all voices sound similar.

**Solution (Text-Only MVP):**
- Color-code roles in radio box:
  - CAPTAIN: Gold (#FFD700)
  - TACTICAL: Red (#E24A4A)
  - ENGINEERING: Yellow (#E2D44A)
  - OPERATIONS: Cyan (#4AE2E2)

**Solution (With Audio):**
- Apply different filters per role:
  - Captain: Reverb (over speakers)
  - Tactical: Clean (close mic)
  - Engineering: Radio static (field comms)
  - Operations: Slight echo (console)

**Acceptance:**
- [ ] Player can identify role by voice/color alone
- [ ] Voice differentiation doesn't confuse (still clear)

---

### Task 4: Replay Integration (3 hours)

**Problem:** Barks disappear after battle ends (can't review them).

**Solution:**
- Replay system saves bark data (text, role, timestamp)
- Replay playback triggers barks at exact timestamps
- Scrubbing timeline triggers nearest bark

**Implementation:**
```gdscript
# In ReplaySystem.gd
var replay_barks: Array[Dictionary] = []  # {time: float, bark: BarkData}

func record_bark(timestamp: float, bark: BarkData):
    replay_barks.append({"time": timestamp, "bark": bark})

func playback_at_time(time: float):
    # Find barks that should play at this time
    for entry in replay_barks:
        if abs(entry["time"] - time) < 0.1:  # 100ms tolerance
            CrewBarkSystem._display_bark(entry["bark"])
```

**Acceptance:**
- [ ] Replay includes all barks from original battle
- [ ] Barks play at correct timestamps
- [ ] Scrubbing timeline shows barks
- [ ] Replay can be exported with barks (for sharing)

---

### Task 5: Settings & Accessibility (2 hours)

**Problem:** No player control over bark system.

**Solution:**
- Add settings panel options:
  - **Enable Crew Barks:** On/Off toggle
  - **Bark Frequency:** Slider (1.0s - 5.0s cooldown)
  - **Bark Volume:** Slider (0% - 100%, if audio enabled)
  - **Show in Combat Log:** On/Off (hide barks from log)

**Implementation:**
```gdscript
# In SettingsManager.gd
var crew_barks_enabled: bool = true
var crew_bark_cooldown: float = 2.0
var crew_bark_volume: float = 0.8
var show_barks_in_log: bool = true

# In CrewBarkSystem.gd
func queue_bark(bark: BarkData):
    if not SettingsManager.crew_barks_enabled:
        return  # Skip if disabled
    # ... rest of logic
```

**Acceptance:**
- [ ] Toggle disables barks completely (no text, no audio)
- [ ] Frequency slider adjusts cooldown in real-time
- [ ] Volume slider adjusts bark audio (if enabled)
- [ ] Log toggle hides barks from combat log

---

### Task 6: Performance Optimization (2 hours)

**Problem:** Bark system adds overhead to combat (signal processing, tween animations).

**Solution:**
- Profile bark system performance (GDScript Profiler)
- Optimize bark selection (cache eligible barks per event)
- Optimize fade animations (use shader if needed)
- Batch bark queue updates (don't update UI every frame)

**Target Performance:**
- Bark triggering: <0.1ms per event
- Bark selection: <0.2ms per event
- Fade animation: <0.05ms per frame
- Total overhead: <1% of frame time

**Acceptance:**
- [ ] No frame drops when triggering 10 barks in 1 second
- [ ] Memory stable (no leaks after 100 battles)
- [ ] Profiler shows bark system <1% CPU usage

---

### Task 7: Localization Preparation (1 hour)

**Problem:** MVP is English-only, but localization planned for future.

**Solution:**
- Extract all bark text to translation CSV:
  - Column 1: Bark ID (unique key)
  - Column 2: English text
  - Column 3: Spanish text (empty for MVP)
  - Column 4: French text (empty for MVP)

**CSV Example:**
```csv
bark_id,en,es,fr
bark_reactor_offline_01,"Main reactor offline!","",""
bark_taking_fire_01,"Taking heavy fire!","",""
```

**Acceptance:**
- [ ] All bark text extracted to CSV
- [ ] BarkDatabase loads text from CSV (not hard-coded)
- [ ] Translation system supports role tags (preserves [ENGINEERING])

---

## Acceptance Criteria (Full Phase 3)

- [ ] Bark frequency feels natural (playtested with 5+ players)
- [ ] 100+ unique barks (no repetition in typical battles)
- [ ] Voice/role differentiation clear
- [ ] Replay system preserves and plays back barks
- [ ] Settings allow player customization
- [ ] Performance overhead <1% frame time
- [ ] Localization-ready (CSV extraction)

---

## Testing Checklist

### Polish Tests
- [ ] **Test 1:** Adjust frequency slider → cooldown changes immediately
- [ ] **Test 2:** Disable barks → no text or audio plays
- [ ] **Test 3:** Play 20 battles → each feels unique (variety)
- [ ] **Test 4:** Watch replay → barks play at correct times
- [ ] **Test 5:** Scrub replay timeline → barks trigger near timestamps

### Performance Tests
- [ ] **Test 6:** Trigger 50 barks in 1 minute → no lag
- [ ] **Test 7:** Play 100 battles → memory stable (no leaks)
- [ ] **Test 8:** Profile bark system → <1% CPU usage

### Accessibility Tests
- [ ] **Test 9:** Colorblind mode → role colors distinguishable
- [ ] **Test 10:** Audio-only mode → can understand barks by voice
- [ ] **Test 11:** Text-only mode → can understand barks without audio

---

## Known Limitations

- **No dynamic tuning:** Frequency slider requires manual adjustment (no adaptive system)
- **CSV translations manual:** No automatic translation (requires human translators)
- **Replay file size:** Including barks increases replay file size (~10-20%)

---

## Future Enhancements

- Adaptive bark frequency (faster during intense combat, slower during lulls)
- AI-powered translations (GPT-4 for quick localization)
- Bark summary screen (post-battle recap of crew reactions)
- Crew morale system (barks reflect cumulative win/loss history)

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-01-04 | Initial spec | Phase 3 polish tasks defined |
