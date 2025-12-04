# Crew Barks Sub-Feature: Audio System

**Status:** 🔴 Planned
**Priority:** ⬇️ Low (Phase 2, non-MVP)
**Estimated Time:** 8-10 hours
**Dependencies:** Triggering System (1.1), UI Presentation (1.3)
**Assigned To:** TBD
**Parent Feature:** [Anonymous Crew Barks System](crew_barks_system.md)

---

## Purpose

Adds audio feedback to text barks: radio static effects, optional TTS voices, and ambient sound cues that enhance immersion without requiring expensive voice acting.

---

## How It Works

When bark triggers, plays brief radio static pop (0.2s), then TTS-generated voice (if enabled), with radio distortion filter applied. Background ambience changes based on ship state (alarms at low HP, power-down hum when reactor destroyed).

---

## Technical Implementation

### Components:
- **RadioStaticSFX:** Short static pop (0.1-0.2s), plays before bark
- **TTSGenerator:** Godot TTS or external API (gTTS, Azure TTS)
- **RadioDistortionFilter:** AudioEffectFilter (bandpass 300-3000 Hz, slight distortion)
- **AmbientAudioManager:** Crossfades background sounds based on ship state

### Audio Files Needed (MVP):
- `radio_static_pop.ogg` (0.2s) - 3-4 variations
- `alarm_klaxon.ogg` (looping) - plays at <50% HP
- `power_down_hum.ogg` (3s oneshot) - plays on reactor destruction

### Integration:
```gdscript
# In RadioChatterBox.gd
func _display_bark(bark: BarkData):
    # Play static pop
    AudioManager.play_sfx("radio_static_pop")

    # Play TTS voice (if available)
    if bark.audio_file and FileAccess.file_exists(bark.audio_file):
        AudioManager.play_voice(bark.audio_file, "RadioFilter")

    # Rest of display logic...
```

---

## Acceptance Criteria

- [ ] Radio static plays before each bark (audible but not loud)
- [ ] TTS voices play correctly (if enabled)
- [ ] Radio filter applies to all bark audio
- [ ] Alarm klaxon plays when HP < 50%
- [ ] Power-down hum plays on reactor destruction
- [ ] Audio doesn't overlap (bark audio stops if new bark triggers)
- [ ] Volume adjustable via settings (separate "Crew Bark" volume slider)
- [ ] Audio syncs with text display (no desync)

---

## Testing Checklist

- [ ] Radio static audible but not jarring
- [ ] TTS voices intelligible with radio filter
- [ ] Ambient audio fades smoothly (no pops/clicks)
- [ ] No audio clicks when rapidly triggering barks
- [ ] Performance acceptable (audio doesn't drop FPS)

---

## Known Limitations

- **TTS quality variable:** Godot's TTS may sound robotic (acceptable for radio comms)
- **No interrupt:** Audio plays to completion even if bark interrupted visually
- **Mono audio only:** No spatial audio (barks not positioned)

---

## Future Enhancements

- Professional voice acting (Phase 2.2)
- Spatial audio (barks come from bridge/engineering sections)
- Dynamic mixing (louder barks at critical moments)

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-01-04 | Initial spec | Phase 2 audio feature planned |
