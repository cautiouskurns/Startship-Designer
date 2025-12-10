# Narrative Integration System

**Feature 7: Narrative Integration** - Documentation

## Overview

The narrative integration system adds story context and emotional weight to the campaign through minimal but impactful text snippets at key moments.

## Components

### 1. NarrativeEvent Resource (`scripts/data/NarrativeEvent.gd`)

Data structure for defining narrative moments with trigger conditions.

**Properties:**
- `event_id`: Unique identifier
- `event_type`: Type of event (OPENING_CRAWL, MISSION_BRIEF, MID_CAMPAIGN, etc.)
- `event_title`: Title shown in popup (e.g., "[INCOMING TRANSMISSION]")
- `text`: Main narrative text content
- `trigger_condition`: String condition for when event should trigger
- `auto_continue`: Whether to auto-dismiss after delay
- `continue_delay`: Seconds before auto-continue

**Example:**
```gdscript
var event = NarrativeEvent.new(
	"colony_evacuation",
	NarrativeEvent.EventType.MID_CAMPAIGN,
	"[INCOMING TRANSMISSION]",
	"This is Colony Transport Z-9.\nEnemy raiders on our tail.\nCan you spare a ship?",
	"turn == 5 AND colony_threatened"
)
```

### 2. NarrativeManager Autoload (`scripts/autoload/NarrativeManager.gd`)

Singleton that manages narrative events and triggers.

**Key Functions:**
- `check_triggers()`: Evaluates all event conditions against current campaign state
- `generate_mission_brief(sector_id)`: Creates dynamic mission brief based on sector status
- `get_opening_crawl()`: Returns opening crawl text
- `reset()`: Clears triggered events for new campaign

**Pre-defined Events:**
- `colony_evacuation`: Turn 5 when Colony sector threatened
- `desperate_plea`: Turn 8 when 2+ sectors lost
- `final_stand`: Turn 11 (final warning before turn 12)

### 3. NarrativePopup UI (`scenes/ui/NarrativePopup.tscn`)

Displays transmission-style messages to the player.

**Visual Style:**
- Semi-transparent overlay
- Centered panel with title and text
- Continue button for dismissal
- Optional auto-dismiss after delay

**Functions:**
- `show_event(event: NarrativeEvent)`: Display a narrative event
- `show_custom(title, text, auto_dismiss, delay)`: Display custom text (for mission briefs)
- `close()`: Dismiss popup without signal

### 4. OpeningCrawl Scene (`scenes/ui/OpeningCrawl.tscn`)

Cinematic opening text displayed at campaign start.

**Flow:**
1. Fade in crawl text over 1 second
2. Hold for 4 seconds
3. Fade out over 0.5 seconds
4. Transition to Campaign Map

**Features:**
- Skip button in bottom-right
- Automatically transitions to CampaignMap after completion

## Integration Points

### Campaign Map (`scripts/campaign/CampaignMap.gd`)

**Initialization:**
- Connects to `NarrativeManager.narrative_event_triggered` signal
- Checks for triggers on scene load via `_check_narrative_triggers()`

**After Battle:**
- Checks for mid-campaign triggers in `_process_battle_result()`
- Shows mission brief before deployment via `_show_mission_brief()`

**New Campaign:**
- Resets NarrativeManager state
- Reloads scene to clear triggered events

### Victory Screen (`scripts/ui/VictoryScreen.gd`)

Enhanced rank narratives with story context:
- **S-Rank**: "Triumphant Victory" - All sectors saved
- **A-Rank**: "Decisive Victory" - Critical sectors held
- **B-Rank**: "Pyrrhic Victory" - Heavy losses but survived
- **C-Rank**: "Survived by the Skin of Our Teeth" - Barely made it
- **Defeat**: "Overrun" - Command fallen

### Main Menu (`scripts/ui/MainMenu.gd`)

**New Game Flow:**
1. Reset game state and campaign
2. Reset NarrativeManager
3. Show OpeningCrawl scene
4. OpeningCrawl transitions to CampaignMap

## Usage Examples

### Adding a New Mid-Campaign Event

In `NarrativeManager._initialize_narrative_events()`:

```gdscript
narrative_events["new_event"] = NarrativeEvent.new(
	"new_event",
	NarrativeEvent.EventType.MID_CAMPAIGN,
	"[URGENT MESSAGE]",
	"Your narrative text here...",
	"turn == 7 AND sectors_lost >= 1"  # Trigger condition
)
```

### Trigger Conditions

Supported context variables:
- `turn`: Current campaign turn (1-12)
- `colony_threatened`: Boolean, Colony sector at threat level 2+
- `sectors_lost`: Number of lost sectors (threat level 4)
- `command_threat`: Command sector threat level (0-3)

Supported operators:
- `==`: Equality check
- `>=`: Greater than or equal
- `AND`: Logical AND for combining conditions

### Dynamic Mission Briefs

Mission briefs are generated dynamically based on:
- Sector name and threat level
- Current turn progress
- Whether sector is lost (recapture operation)
- Campaign urgency (turns 10-12 emphasize final stand)

Example brief structure:
```
TARGET: Medical Sector
TURN: 8/12

STATUS: CRITICAL (Threat Level 3)
Sector is on the brink of collapse!

OBJECTIVE: Prevent sector collapse
If this sector falls, we lose its strategic value.

Deploy your ship and engage.
```

## Testing Checklist

### Opening Crawl
- [ ] New Game shows opening crawl
- [ ] Crawl displays for ~4 seconds
- [ ] Skip button works
- [ ] Transitions to Campaign Map

### Mission Briefs
- [ ] Brief shows when deploying to sector
- [ ] Brief reflects current threat level
- [ ] Brief text changes based on sector status
- [ ] Continue button proceeds to ship designer

### Mid-Campaign Events
- [ ] Colony evacuation triggers on turn 5 (if colony threatened)
- [ ] Desperate plea triggers on turn 8 (if 2+ sectors lost)
- [ ] Final stand triggers on turn 11
- [ ] Events only trigger once per campaign
- [ ] Events don't block gameplay

### Victory Screen
- [ ] S-Rank shows triumphant narrative
- [ ] A-Rank shows decisive victory narrative
- [ ] B-Rank shows pyrrhic victory narrative
- [ ] C-Rank shows barely survived narrative
- [ ] Defeat shows overrun narrative
- [ ] Narratives match campaign outcome

### Reset Functionality
- [ ] New Campaign button resets narrative state
- [ ] Events can trigger again in new campaign
- [ ] Opening crawl plays for each new campaign

## File Locations

```
scripts/
├── data/
│   └── NarrativeEvent.gd          # Event data structure
├── autoload/
│   └── NarrativeManager.gd        # Event management singleton
└── ui/
    ├── NarrativePopup.gd          # Popup display logic
    └── OpeningCrawl.gd            # Opening crawl logic

scenes/
└── ui/
    ├── NarrativePopup.tscn        # Popup UI scene
    └── OpeningCrawl.tscn          # Opening crawl scene
```

## Design Philosophy

**Minimal but Impactful:**
- All text snippets are brief (<100 words)
- Events trigger at key moments only
- No lengthy cutscenes or extensive dialogue
- Focus on context and emotional weight

**Reactive to Player Choices:**
- Mission briefs reference current map state
- Mid-campaign events respond to player performance
- Endings vary based on final rank

**Non-Intrusive:**
- All events can be quickly dismissed
- No narrative blocks critical gameplay
- Events enhance but don't replace gameplay

## Future Enhancements

Potential additions (not in current scope):
- More mid-campaign events for specific scenarios
- Commander personality variations
- Sector-specific event chains
- Alternate opening crawls based on difficulty
- Post-battle debriefs with performance analysis
