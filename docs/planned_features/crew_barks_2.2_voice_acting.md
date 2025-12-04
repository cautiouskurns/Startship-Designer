# Crew Barks Sub-Feature: Professional Voice Acting

**Status:** 🔴 Planned
**Priority:** ⬇️ Low (Phase 2, optional upgrade)
**Estimated Time:** 15-20 hours (recording + integration)
**Dependencies:** Audio System (2.1)
**Assigned To:** TBD
**Budget:** $400-800 (voice actors)
**Parent Feature:** [Anonymous Crew Barks System](crew_barks_system.md)

---

## Purpose

Replaces TTS with professional voice actors for higher production value. Creates distinct voice identities for crew roles while maintaining anonymous/professional tone.

---

## How It Works

Record 100-150 lines with 4-5 voice actors (one per role). Each bark gets unique audio file. Audio processed with radio filter and normalized. BarkDatabase updated with audio_file paths.

---

## Voice Actor Requirements

### Roles & Voice Types:
- **CAPTAIN:** Authoritative, mature (male or female, 40-50 years)
- **TACTICAL:** Sharp, focused (male, 25-35 years)
- **ENGINEERING:** Technical, urgent (male or female, 30-45 years)
- **OPERATIONS:** Professional, calm under pressure (female, 25-40 years)

### Recording Specs:
- **Format:** 48kHz, 16-bit, mono WAV
- **Duration:** 100-150 lines × 2-4 seconds each = ~10 minutes total per actor
- **Delivery:** Military professional, no emotion acting (factual reports)
- **Takes:** 2-3 takes per line (pick best)

### Voice Direction:
- **Tone:** Military radio comms (clipped, efficient)
- **Emotion:** Controlled stress, not panic
- **Pacing:** Quick but intelligible
- **Examples:** *Alien* (Nostromo crew), *BSG* (bridge crew)

---

## Budget Breakdown

| Item | Cost (Low) | Cost (High) |
|------|------------|-------------|
| 4 voice actors @ $100-200 each | $400 | $800 |
| Audio engineer / editor | $0 (DIY) | $200 |
| Recording studio rental (optional) | $0 (remote) | $150 |
| **Total** | **$400** | **$1150** |

**Recommendation:** $400-600 budget (remote recording, DIY editing)

---

## Technical Implementation

### File Structure:
```
res://audio/barks/
├── captain/
│   ├── victory_01.ogg
│   ├── victory_02.ogg
│   └── ...
├── tactical/
│   ├── taking_fire_01.ogg
│   ├── enemy_down_01.ogg
│   └── ...
├── engineering/
│   ├── reactor_offline_01.ogg
│   ├── power_grid_failure_01.ogg
│   └── ...
└── operations/
    ├── shields_down_01.ogg
    ├── systems_failing_01.ogg
    └── ...
```

### BarkDatabase Integration:
```gdscript
const DAMAGE_REPORTS = [
    {
        "text": "Main reactor offline!",
        "role": CrewRole.ENGINEERING,
        "priority": BarkPriority.HIGH,
        "component": RoomData.RoomType.REACTOR,
        "audio_file": "res://audio/barks/engineering/reactor_offline_01.ogg",  # NEW
    },
    # ... rest of barks
]
```

---

## Acceptance Criteria

- [ ] All 100-150 barks have corresponding audio files
- [ ] Audio quality professional (no background noise, clear speech)
- [ ] Voice types match roles (tactical sounds different from engineering)
- [ ] All audio normalized to consistent volume (LUFS -16)
- [ ] Radio filter applied to all files (bandpass 300-3000 Hz)
- [ ] File sizes optimized (OGG compression, ~50-100 KB per file)
- [ ] Audio syncs with text display (lip-sync not required, just timing)
- [ ] No voice actor names in credits (anonymous crew)

---

## Testing Checklist

- [ ] Play 20 random barks → all audio clear and professional
- [ ] Voice differentiation works (can identify role by voice alone)
- [ ] No audio artifacts (clipping, distortion, pops)
- [ ] Performance acceptable (loading 150 audio files doesn't lag)

---

## Known Limitations

- **No dynamic line generation:** Fixed 100-150 lines, can't generate new barks
- **English only:** Localization requires re-recording in other languages (expensive)
- **No voice modulation:** Same voice per role (can't vary pitch/tone per bark)

---

## Future Enhancements

- Localized voice acting (Spanish, French, German)
- Expanded bark library (200+ lines)
- Dynamic pitch/speed modulation for variety

---

## Procurement Notes

**Where to find voice actors:**
- **Fiverr:** $50-150 per actor (remote, fast turnaround)
- **Voices.com:** $200-500 per actor (higher quality)
- **Local talent:** Check local theater/radio (often cheaper)

**Contract terms:**
- Buyout rights (own audio forever)
- Commercial use allowed
- No royalties (flat fee)

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-01-04 | Initial spec | Phase 2 voice acting optional upgrade |
