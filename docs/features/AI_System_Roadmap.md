# AI System Implementation Roadmap

**Project:** Starship Designer - Auto-Battler AI
**Created:** December 10, 2025
**Estimated Total Time:** 8-12 weeks

---

## Overview

This roadmap transforms the basic targeting AI into a sophisticated, observable, and entertaining combat system for the auto-battler. Both player and enemy ships will use the same AI framework, creating dynamic battles where ship design determines AI behavior.

---

## Feature Phases

### **Phase 1: Foundation** _(7-8 days)_

Core AI architecture that enables all other features.

| Feature | Priority | Time | Dependencies | Status |
|---------|----------|------|--------------|--------|
| [F-AI-001: Ship Profile Analyzer](#f-ai-001) | 🔥 Critical | 2 days | None | 🔴 Planned |
| [F-AI-002: Combat State Evaluator](#f-ai-002) | 🔥 Critical | 2 days | F-AI-001 | 🔴 Planned |
| [F-AI-003: Basic Doctrine System](#f-ai-003) | 🔥 Critical | 2 days | F-AI-001 | 🔴 Planned |
| [F-AI-004: Enhanced Combat Log](#f-ai-004) | ⬆️ High | 1 day | F-AI-002, F-AI-003 | 🔴 Planned |

**Milestone:** AI can analyze ships, determine combat state, and make doctrine-based decisions with logged reasoning.

---

### **Phase 2: Threat Intelligence** _(6-7 days)_

Smart targeting that replaces current simple priority system.

| Feature | Priority | Time | Dependencies | Status |
|---------|----------|------|--------------|--------|
| [F-AI-005: Threat Assessment System](#f-ai-005) | 🔥 Critical | 3 days | F-AI-001, F-AI-002 | 🔴 Planned |
| [F-AI-006: Multi-Factor Target Scoring](#f-ai-006) | 🔥 Critical | 2 days | F-AI-005, F-AI-003 | 🔴 Planned |
| [F-AI-007: Multi-Target Distribution](#f-ai-007) | ⬆️ High | 1 day | F-AI-006 | 🔴 Planned |

**Milestone:** AI makes intelligent targeting decisions based on threat, doctrine, and combat state.

---

### **Phase 3: Advanced Behaviors** _(13-15 days)_

Depth, variety, and emergent tactics.

| Feature | Priority | Time | Dependencies | Status |
|---------|----------|------|--------------|--------|
| [F-AI-008: Predictive Planning](#f-ai-008) | ⬆️ High | 3 days | F-AI-005, F-AI-006 | 🔴 Planned |
| [F-AI-009: Synergy Exploitation](#f-ai-009) | ⬆️ High | 2 days | F-AI-003 | 🔴 Planned |
| [F-AI-010: Power Management AI](#f-ai-010) | ⬆️ High | 3 days | F-AI-002, F-AI-003 | 🔴 Planned |
| [F-AI-011: Emergent Tactics Library](#f-ai-011) | ➡️ Medium | 3 days | F-AI-005, F-AI-008 | 🔴 Planned |
| [F-AI-012: Full Doctrine Implementation](#f-ai-012) | ⬆️ High | 2 days | F-AI-003 | 🔴 Planned |

**Milestone:** AI exhibits complex behaviors, exploits synergies, and discovers tactical opportunities.

---

### **Phase 4: Visual Feedback** _(6-7 days)_

Make AI understandable and entertaining to watch.

| Feature | Priority | Time | Dependencies | Status |
|---------|----------|------|--------------|--------|
| [F-AI-013: AI Thought Bubbles](#f-ai-013) | 🔥 Critical | 2 days | F-AI-004 | 🔴 Planned |
| [F-AI-014: Target Highlighting](#f-ai-014) | 🔥 Critical | 1 day | F-AI-005 | 🔴 Planned |
| [F-AI-015: Doctrine UI Panel](#f-ai-015) | ⬆️ High | 1 day | F-AI-003 | 🔴 Planned |
| [F-AI-016: Post-Battle Analysis](#f-ai-016) | ➡️ Medium | 2 days | F-AI-004, F-AI-011 | 🔴 Planned |

**Milestone:** Players understand AI reasoning and can learn from combat observations.

---

### **Phase 5: Polish & Balance** _(8-10 days)_

Testing, balancing, and optimization.

| Feature | Priority | Time | Dependencies | Status |
|---------|----------|------|--------------|--------|
| [F-AI-017: Doctrine Balancing](#f-ai-017) | 🔥 Critical | 3 days | All Phase 1-3 | 🔴 Planned |
| [F-AI-018: AI vs AI Testing](#f-ai-018) | ⬆️ High | 2 days | All Phase 1-3 | 🔴 Planned |
| [F-AI-019: Player Build Testing](#f-ai-019) | 🔥 Critical | 2 days | All Phase 1-4 | 🔴 Planned |
| [F-AI-020: Performance Optimization](#f-ai-020) | ⬆️ High | 1 day | All Phase 1-3 | 🔴 Planned |

**Milestone:** AI is balanced, performant, and ready for players.

---

## MVP Scope (6-8 weeks)

**Recommended for initial release:**
- All of Phase 1 (Foundation)
- All of Phase 2 (Threat Intelligence)
- All of Phase 4 (Visual Feedback)
- F-AI-017, F-AI-019 (Critical balancing)

**Can defer to post-launch:**
- Phase 3 (Advanced Behaviors) - Nice to have, adds depth
- F-AI-018 (AI vs AI Testing) - Internal testing tool
- F-AI-020 (Performance Optimization) - Only if issues arise

---

## Integration with Existing Systems

### Existing Combat.gd Integration Points

**Currently using:**
```gdscript
// Combat.gd:499
var primary_target_id = _select_target_room(defender, attacker)
```

**Will replace with:**
```gdscript
// New AI system
var ai_decision = combat_ai.make_decision(attacker, defender, combat_state)
var primary_target_id = ai_decision.primary_target
var secondary_targets = ai_decision.secondary_targets
var special_actions = ai_decision.special_actions
```

**Compatibility:**
- New AI system returns target IDs in same format
- Existing `_execute_turn()` flow unchanged
- Combat log receives enhanced entries
- Visual effects receive additional metadata

---

## Feature Specification Links

### Phase 1: Foundation
- [F-AI-001: Ship Profile Analyzer](./F-AI-001_Ship_Profile_Analyzer.md)
- [F-AI-002: Combat State Evaluator](./F-AI-002_Combat_State_Evaluator.md)
- [F-AI-003: Basic Doctrine System](./F-AI-003_Basic_Doctrine_System.md)
- [F-AI-004: Enhanced Combat Log](./F-AI-004_Enhanced_Combat_Log.md)

### Phase 2: Threat Intelligence
- [F-AI-005: Threat Assessment System](./F-AI-005_Threat_Assessment_System.md)
- [F-AI-006: Multi-Factor Target Scoring](./F-AI-006_Multi_Factor_Target_Scoring.md)
- [F-AI-007: Multi-Target Distribution](./F-AI-007_Multi_Target_Distribution.md)

### Phase 3: Advanced Behaviors
- [F-AI-008: Predictive Planning](./F-AI-008_Predictive_Planning.md)
- [F-AI-009: Synergy Exploitation](./F-AI-009_Synergy_Exploitation.md)
- [F-AI-010: Power Management AI](./F-AI-010_Power_Management_AI.md)
- [F-AI-011: Emergent Tactics Library](./F-AI-011_Emergent_Tactics.md)
- [F-AI-012: Full Doctrine Implementation](./F-AI-012_Full_Doctrines.md)

### Phase 4: Visual Feedback
- [F-AI-013: AI Thought Bubbles](./F-AI-013_AI_Thought_Bubbles.md)
- [F-AI-014: Target Highlighting](./F-AI-014_Target_Highlighting.md)
- [F-AI-015: Doctrine UI Panel](./F-AI-015_Doctrine_UI.md)
- [F-AI-016: Post-Battle Analysis](./F-AI-016_Post_Battle_Analysis.md)

### Phase 5: Polish & Balance
- [F-AI-017: Doctrine Balancing](./F-AI-017_Doctrine_Balancing.md)
- [F-AI-018: AI vs AI Testing](./F-AI-018_AI_Testing.md)
- [F-AI-019: Player Build Testing](./F-AI-019_Player_Testing.md)
- [F-AI-020: Performance Optimization](./F-AI-020_Performance.md)

---

## Risk Assessment

### High Risk
- **Phase 3 complexity:** Advanced behaviors may create unpredictable AI
  - *Mitigation:* Extensive testing, ability to disable individual tactics

- **Performance:** Predictive planning could be expensive
  - *Mitigation:* Limit lookahead depth, cache calculations

### Medium Risk
- **Balance:** 6 doctrines may be difficult to balance
  - *Mitigation:* Start with 3 doctrines, add more after testing

- **Visual clutter:** Too much feedback could overwhelm player
  - *Mitigation:* Settings to disable/minimize feedback

### Low Risk
- **Integration:** New system might conflict with existing combat
  - *Mitigation:* Wrapper pattern preserves existing interface

---

## Success Metrics

**Launch Criteria:**
- [ ] AI makes predictable, learnable decisions
- [ ] Different ship builds produce visibly different AI behaviors
- [ ] Combat log clearly explains all AI decisions
- [ ] 90% of playtesters report "I understand why I won/lost"
- [ ] No doctrine has >60% or <40% win rate vs others
- [ ] Combat maintains 60fps with full AI system

**Post-Launch Goals:**
- Player retention: 80% complete 3+ missions (understand AI enough to iterate)
- Player feedback: 70%+ rate combat as "interesting to watch"
- AI variety: No two battles feel identical
- Learning curve: Players predict AI by mission 3

---

## Implementation Order Recommendation

1. **Week 1-2:** F-AI-001, F-AI-002, F-AI-003, F-AI-004
2. **Week 3-4:** F-AI-005, F-AI-006, F-AI-007
3. **Week 5:** F-AI-013, F-AI-014, F-AI-015
4. **Week 6:** F-AI-017, F-AI-019, F-AI-020
5. **Week 7-8 (Optional):** F-AI-008, F-AI-009, F-AI-010
6. **Week 9-10 (Optional):** F-AI-011, F-AI-012, F-AI-016, F-AI-018

**MVP Ready:** End of Week 6
**Full System:** End of Week 10
