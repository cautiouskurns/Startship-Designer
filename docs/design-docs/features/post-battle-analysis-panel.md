# Post-Battle Analysis Panel

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 2-3 weeks
**Dependencies:** Battle system must be complete with stat tracking
**Assigned To:** AI assistant

---

## Purpose

**Why does this feature exist?**
Players need feedback on their ship's combat performance to understand what worked, what didn't, and how to improve their designs for future battles.

**What does it enable?**
Players can review detailed combat statistics, identify weaknesses in their ship design, and receive actionable suggestions for improvements based on their battle performance.

**Success criteria:**
Players can view comprehensive post-battle stats, understand their ship's strengths/weaknesses, and make informed design decisions based on the analysis and suggestions provided.

---

## How It Works

### Overview
After a battle concludes (win, loss, or retreat), the Post-Battle Analysis Panel displays automatically. The panel shows a breakdown of combat performance across multiple categories: damage output, defensive performance, resource efficiency, and tactical execution. Each stat category includes visualizations (charts/graphs) and compares performance against baseline expectations.

The system analyzes the collected stats and generates 3-5 contextual suggestions for ship improvements. Suggestions are prioritized based on the most impactful weaknesses identified during battle (e.g., "Your shields depleted quickly - consider adding more shield generators" or "High weapon accuracy but low damage - upgrade to heavier weapons").

### User Flow
```
1. Player completes a battle (win/loss/retreat)
2. Battle fade-out transition occurs
3. Post-Battle Analysis Panel slides in
4. Stats populate with animated counters/graphs
5. Player reviews performance metrics
6. Player scrolls to Suggestions section
7. Player reads improvement recommendations
8. Player clicks "Continue" to return to ship designer or main menu
```

### Rules & Constraints
- Panel only appears after combat encounters, not during tutorial or practice modes
- Stats must be tracked throughout entire battle and cached before transition
- Suggestions limited to 3-5 items to avoid overwhelming the player
- Suggestions must be specific and actionable (not generic advice)
- Panel remains accessible via "Review Last Battle" button until next battle starts

### Edge Cases
- What happens if player quits during battle? → Stats saved up to quit point, shown on next launch with "Incomplete Battle" tag
- What happens if battle lasts less than 10 seconds? → Still show panel but flag as "Quick Encounter" with limited suggestions
- What happens if this is player's first battle? → Include tutorial tooltips explaining each stat category

---

## User Interaction

### Controls
- **Mouse scroll / Drag**: Navigate through stats sections
- **Click "Continue" button**: Close panel and return to main menu
- **Click "Review Last Battle" (from main menu)**: Reopen most recent analysis
- **Hover over stat icons**: Show detailed tooltip explanations

### Visual Feedback
- Smooth slide-in animation when panel appears
- Stats animate from 0 to final value with counter effect
- Color coding: Green for good performance, yellow for average, red for poor
- Graphs/charts animate to fill on display
- Suggestion cards have subtle highlight on hover
- Victory/Defeat banner displays prominently at top

### Audio Feedback (if applicable)
- Transition whoosh sound when panel opens
- Subtle tick sounds as stat counters increment
- Success chime for victory, somber tone for defeat
- Click sound for button interactions

---

## Visual Design

### Layout
Full-screen overlay with semi-transparent dark background. Central panel (80% screen width, 90% height) with three main sections stacked vertically: Header (Victory/Defeat), Stats Breakdown (60% of panel), and Suggestions (40% of panel). Scrollable if content exceeds viewport.

### Components
- **Victory/Defeat Banner**: Large header with battle outcome and duration
- **Stats Grid**: 2-3 column layout with icon, label, value, and mini-graph for each metric
- **Performance Bars**: Horizontal bars showing relative performance (0-100%)
- **Suggestion Cards**: Rounded rectangles with icon, title, and description
- **Continue Button**: Large, prominent button at bottom
- **Background Blur**: Subtle blur effect on game world behind panel

### Visual Style
- Colors: Dark navy background (#1a1d2e), accent blue (#4a9eff), warning yellow (#ffc947), danger red (#ff6b6b), success green (#51cf66)
- Fonts: Bold sans-serif for headers, regular sans-serif for stats, italic for suggestions
- Animations: Smooth 0.3s ease transitions, 1.5s counter animations, staggered stat reveals

### States
- **Default:** Panel visible, stats displayed, interactive elements enabled
- **Hover:** Suggestion cards lift slightly, buttons brighten
- **Active:** Button pressed effect, immediate visual feedback
- **Loading:** Skeleton loaders if stats computation takes >500ms
- **Error:** "Stats Unavailable" message if data corrupted/missing

---

## Technical Implementation

### Scene Structure
```
PostBattleAnalysisPanel (Control)
├── BackgroundOverlay (ColorRect)
├── MainPanel (PanelContainer)
│   ├── VBoxContainer
│   │   ├── OutcomeBanner (HBoxContainer)
│   │   ├── ScrollContainer
│   │   │   ├── StatsSection (VBoxContainer)
│   │   │   └── SuggestionsSection (VBoxContainer)
│   │   └── ContinueButton (Button)
```

### Script Responsibilities
- **PostBattleAnalysisPanel.gd:** Orchestrates panel display, receives battle stats, coordinates animations
- **BattleStatsCalculator.gd:** Processes raw battle data into displayable metrics and performance ratings
- **SuggestionGenerator.gd:** Analyzes stats and generates contextual improvement recommendations
- **StatDisplayWidget.gd:** Handles individual stat visualization with animations

### Data Structures
(Code omitted per request - structure described conceptually)

**BattleStats class:** Stores all combat metrics including damage dealt/taken, accuracy percentages, shield/hull integrity, time survived, kills, and resource expenditure.

**PerformanceRating class:** Converts raw stats into normalized 0-100 scores for visual display.

**Suggestion class:** Contains suggestion text, priority level, related stat category, and optional visual icon.

### Integration Points
- Connects to: Battle system (receives combat events), Ship designer (for stat calculations), Save system (for battle history)
- Emits signals: `analysis_closed`, `review_requested`
- Listens for: `battle_ended`, `stats_ready`
- Modifies: Player progression data (battle records), UI state

### Configuration
- JSON data: `res://data/suggestion_templates.json` (suggestion text patterns and thresholds)
- Tunable constants: Performance thresholds, animation timings, stat weights in `res://config/battle_analysis_config.gd`

---

## Acceptance Criteria

Feature is complete when:

- [ ] Panel displays automatically after every battle conclusion
- [ ] All core stats (damage, defense, efficiency) display correctly with accurate values
- [ ] Stats animate smoothly on panel open
- [ ] 3-5 relevant suggestions generate based on actual battle performance
- [ ] Color coding correctly reflects performance quality (red/yellow/green)
- [ ] "Review Last Battle" functionality works from main menu
- [ ] Panel scales properly across different screen resolutions
- [ ] Tooltips explain each stat category clearly
- [ ] Victory/Defeat state displays correctly
- [ ] Continue button closes panel and returns to appropriate screen

---

## Testing Checklist

### Functional Tests
- [ ] **Victory scenario**: Panel shows correct victory banner and positive stats
- [ ] **Defeat scenario**: Panel shows defeat banner and highlights failure points
- [ ] **Stat accuracy**: All displayed numbers match actual battle performance
- [ ] **Suggestion relevance**: Generated suggestions match observed weaknesses
- [ ] **Navigation**: Continue button and back navigation work correctly

### Edge Case Tests
- [ ] **First battle**: Tutorial tooltips appear for new players
- [ ] **Quick battle (<10s)**: Panel handles minimal data gracefully
- [ ] **Interrupted battle**: Stats saved and displayed correctly on next launch
- [ ] **Perfect performance**: Handles all max stats without breaking layout
- [ ] **Terrible performance**: Handles all minimum stats, provides encouraging tone

### Integration Tests
- [ ] Works with existing battle system without conflicts
- [ ] Doesn't break save/load functionality
- [ ] Battle history properly updated after each panel view
- [ ] Ship designer can be accessed after panel closes

### Polish Tests
- [ ] Animations smooth and timed well (no jank)
- [ ] Sounds play at appropriate moments
- [ ] Visual feedback clear for all interactive elements
- [ ] Performance acceptable (60 FPS) even with animations

---

## Known Limitations

- **No comparative analysis**: First version won't compare current battle to previous battles (future enhancement)
- **Suggestion templates only**: AI-driven dynamic suggestions planned for v2.0
- **Single battle history**: Only most recent battle reviewable, full history viewer deferred

---

## Future Enhancements

*(Not for MVP, but worth noting)*

- Battle-to-battle performance trending with graphs over time
- Share battle results with friends/community
- Advanced filtering (show only defensive stats, only weapon stats, etc.)
- "Rematch" button to retry same battle scenario
- AI opponent analysis showing enemy ship weaknesses
- Achievement tracking integrated into stats display

---

## Implementation Notes

*(For AI assistant or future you)*

- Consider caching suggestion templates on game startup to avoid JSON reads during battle transitions
- Use object pooling for stat widgets if performance issues arise with many stats
- Keep suggestion algorithm simple initially; complex ML-based analysis can come later
- Consider A/B testing different suggestion formats to see what players act on most
- Panel must feel responsive - aim for <100ms from battle end to panel start

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-12-09 | Initial spec | Feature planned for post-battle feedback loop |
