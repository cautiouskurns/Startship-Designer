# [Feature Name]

**Status:** 🔴 Planned | 🟡 In Progress | 🟢 Implemented
**Priority:** 🔥 Critical | ⬆️ High | ➡️ Medium | ⬇️ Low
**Estimated Time:** X hours/days/weeks
**Dependencies:** [Other features needed first, or "None"]
**Assigned To:** [Your name / AI assistant / contractor]

---

## Purpose

**Why does this feature exist?**
[1-2 sentences explaining the problem this solves]

**What does it enable?**
[What can players do that they couldn't before?]

**Success criteria:**
[How will you know this feature works?]

---

## How It Works

### Overview
[2-3 paragraph explanation of the feature behavior]

### User Flow
```
1. Player does [X]
2. System responds with [Y]
3. Player sees [Z]
4. Result: [Outcome]
```

### Rules & Constraints
- [Rule 1]
- [Rule 2]
- [Rule 3]

### Edge Cases
- What happens if [unusual scenario]?
- What happens if [error condition]?

---

## User Interaction

### Controls
- [Input method 1]: [Action]
- [Input method 2]: [Action]

### Visual Feedback
- [What player sees during interaction]
- [How system state is communicated]

### Audio Feedback (if applicable)
- [Sound effects]
- [Music changes]

---

## Visual Design

### Layout
[Sketch or description of UI layout]

### Components
- [UI element 1]: [Purpose]
- [UI element 2]: [Purpose]

### Visual Style
- Colors: [Palette]
- Fonts: [Typography]
- Animations: [Movement/transitions]

### States
- **Default:** [Appearance]
- **Hover:** [Appearance]
- **Active:** [Appearance]
- **Disabled:** [Appearance]
- **Error:** [Appearance]

---

## Technical Implementation

### Scene Structure
```
[Scene Name]
├── [Node 1]
│   └── [Child Node]
├── [Node 2]
└── [Node 3]
```

### Script Responsibilities
- **[ScriptName].gd:** [What it does]
- **[ScriptName].gd:** [What it does]

### Data Structures
```gdscript
class [ClassName]:
    var [property]: [type]  # [purpose]
    
    func [method_name]():
        # [what it does]
```

### Integration Points
- Connects to: [Other system]
- Emits signals: [Signal list]
- Listens for: [Signal list]
- Modifies: [Affected game state]

### Configuration
- JSON data: [File location]
- Tunable constants: [Where defined]

---

## Acceptance Criteria

Feature is complete when:

- [ ] [Specific testable criterion 1]
- [ ] [Specific testable criterion 2]
- [ ] [Specific testable criterion 3]
- [ ] [Specific testable criterion 4]
- [ ] [Specific testable criterion 5]

---

## Testing Checklist

### Functional Tests
- [ ] [Test case 1]: [Expected behavior]
- [ ] [Test case 2]: [Expected behavior]
- [ ] [Test case 3]: [Expected behavior]

### Edge Case Tests
- [ ] [Edge case 1]: [Expected behavior]
- [ ] [Edge case 2]: [Expected behavior]

### Integration Tests
- [ ] Works with [Other Feature]
- [ ] Doesn't break [Existing Feature]

### Polish Tests
- [ ] Animations smooth
- [ ] Sounds play correctly
- [ ] Visual feedback clear
- [ ] Performance acceptable (60 FPS)

---

## Known Limitations

- [Limitation 1]: [Why it exists, when to fix]
- [Limitation 2]: [Why it exists, when to fix]

---

## Future Enhancements

*(Not for MVP, but worth noting)*

- [Enhancement 1]
- [Enhancement 2]

---

## Implementation Notes

*(For AI assistant or future you)*

- [Important detail about approach]
- [Gotcha to watch out for]
- [Alternative approach considered but rejected because...]

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| [Date] | Initial spec | Feature planned |
| [Date] | [Change made] | [Why] |