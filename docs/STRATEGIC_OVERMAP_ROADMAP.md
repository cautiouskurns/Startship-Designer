# Strategic Overmap System - Feature Roadmap

**Campaign Layer Implementation**
**Target Timeline:** 3 weeks
**Total Estimated Time:** 80-100 hours

---

## Implementation Phases

**Week 1:** Core System (Features 1-2)
**Week 2:** Strategic Depth (Features 3-5)
**Week 3:** Narrative & Polish (Features 6-7)

---

# Feature 1: Campaign Map Core

**Status:** 🔴 Planned
**Priority:** 🔥 Critical
**Estimated Time:** 12 hours
**Dependencies:** None
**Assigned To:** AI Assistant

---

## Purpose

**Why does this feature exist?**
Creates the strategic foundation for the campaign by tracking sector states and turn progression.

**What does it enable?**
Players can see the war state at a glance, understand which sectors are threatened, and make informed deployment decisions.

**Success criteria:**
- All 7 sectors display with current threat levels
- Turn counter advances correctly
- Map state persists between battles
- Visual feedback clearly shows sector status

---

## How It Works

### Overview
The campaign map displays 7 sectors arranged in a star formation with Command at the center. Each sector has a threat level (0-4) represented visually. The map updates after each battle, showing which sectors are secure, threatened, or lost.

### User Flow
```
1. Player launches campaign mode
2. System loads campaign map showing 7 sectors
3. Player sees threat levels for each sector
4. System highlights available deployment options
5. Player selects sector to defend
```

### Rules & Constraints
- Command (center) cannot fall
- Threat levels range from 0 (secure) to 4 (lost)
- Only one sector can be defended per turn
- Campaign lasts exactly 12 turns
- Map state persists between battles

### Edge Cases
- What if player quits mid-campaign? → Save campaign state
- What if all sectors reach critical? → Game over condition
- What if player tries to select unavailable sector? → Disable selection

---

## User Interaction

### Controls
- **Mouse click on sector**: Select sector for deployment
- **Hover over sector**: Show detailed status tooltip
- **ESC key**: Pause menu (save/quit campaign)

### Visual Feedback
- Secure sectors: Green glow
- Threatened sectors (1-2 threats): Yellow pulse
- Critical sectors (3 threats): Red pulse + warning icon
- Lost sectors (4 threats): Gray/dark, crossed out
- Selected sector: Cyan highlight border

---

## Visual Design

### Layout
```
        🏛️ Command (center)
          / | \
        /   |   \
      /     |     \
    🏭─────🏥─────🌾   (inner ring)
    |  \   |   /  |
    |    \ | /    |
    ⚡─────🛡️─────🎯   (outer ring)
```

### Components
- **Sector Node**: Icon + name + threat bar
- **Connection Lines**: Show sector relationships
- **Turn Counter**: "Turn X/12" display
- **Threat Legend**: Visual key for threat levels

### Visual Style
- Colors: Dark space background (#0A0A1A), cyan borders (#4AE2E2)
- Fonts: Orbitron (sci-fi), 16-24pt
- Animations: Pulse effect for threatened sectors (1s cycle)

### States
- **Secure:** Green border, steady glow
- **Threatened:** Yellow border, slow pulse
- **Critical:** Red border, fast pulse + ⚠️ icon
- **Lost:** Gray, 50% opacity, X mark overlay
- **Selected:** Cyan double-border

---

## Technical Implementation

### Scene Structure
```
CampaignMap.tscn
├── Background (TextureRect)
├── SectorContainer (Control)
│   ├── CommandSector (SectorNode)
│   ├── ShipyardSector (SectorNode)
│   ├── MedicalSector (SectorNode)
│   ├── ColonySector (SectorNode)
│   ├── PowerSector (SectorNode)
│   ├── DefenseSector (SectorNode)
│   └── WeaponsSector (SectorNode)
├── ConnectionLines (Node2D)
├── TurnCounter (Label)
└── DeploymentPanel (Panel)
```

### Script Responsibilities
- **CampaignMap.gd:** Map state management, sector selection
- **SectorNode.gd:** Individual sector display, threat visualization
- **CampaignState.gd (Autoload):** Campaign data persistence

### Data Structures
```gdscript
class CampaignState:
    var current_turn: int = 1
    var max_turns: int = 12
    var sectors: Dictionary = {}  # sector_id -> SectorData

class SectorData:
    var sector_id: String
    var threat_level: int  # 0-4
    var is_lost: bool
    var bonus_active: bool
```

### Integration Points
- Connects to: MissionSelect (launches battles)
- Emits signals: sector_selected(sector_id), turn_advanced
- Listens for: battle_completed(victory)
- Modifies: GameState.current_mission, CampaignState.sectors

### Configuration
- JSON data: `res://data/sectors.json` (sector definitions)
- Tunable constants: `BalanceConstants.CAMPAIGN_TURNS = 12`

---

## Acceptance Criteria

Feature is complete when:

- [ ] All 7 sectors display correctly with icons and names
- [ ] Threat levels update visually (0-4 bars)
- [ ] Turn counter displays and increments
- [ ] Player can click sector to select for deployment
- [ ] Map state persists between battles
- [ ] Campaign save/load works correctly

---

## Testing Checklist

### Functional Tests
- [ ] Map loads with all sectors at threat 0
- [ ] Clicking sector highlights it and shows deployment options
- [ ] Turn counter increments after battle
- [ ] Threat bars update correctly (0-4 visual states)

### Edge Case Tests
- [ ] Loading saved campaign restores exact map state
- [ ] All sectors at threat 4 triggers game over
- [ ] Command sector cannot be selected for defense

---

## Known Limitations

- Single campaign only (no multiple save slots)
- Fixed 7 sectors (not configurable)

---

## Future Enhancements

- Multiple campaign difficulties
- Custom sector configurations
- Animated sector transitions

---

# Feature 2: Sector Defense System

**Status:** 🔴 Planned
**Priority:** 🔥 Critical
**Estimated Time:** 10 hours
**Dependencies:** Feature 1 (Campaign Map Core)
**Assigned To:** AI Assistant

---

## Purpose

**Why does this feature exist?**
Enables the core campaign gameplay loop: choose sector → design ship → fight battle → see consequences.

**What does it enable?**
Players make strategic choices about which sector to defend each turn, knowing undefended sectors will worsen.

**Success criteria:**
- Player selects sector to defend
- System generates appropriate enemy for that sector
- Battle launches with correct mission context
- Victory reduces sector threat, defeat increases it

---

## How It Works

### Overview
Each turn, player selects one sector to defend. System launches a mission for that sector with a contextual enemy. After battle, selected sector's threat decreases on victory (or increases on defeat). All other sectors advance +1 threat level.

### User Flow
```
1. Player sees campaign map with threat levels
2. Player clicks threatened sector
3. System shows deployment confirmation panel
4. Player confirms → launches to ship designer
5. Player designs ship for this mission
6. Battle resolves
7. Map updates with new threat levels
```

### Rules & Constraints
- Only one sector defended per turn
- Victory: selected sector threat -2
- Defeat: selected sector threat +1
- All other sectors: threat +1 automatically
- Cannot defend secure sectors (threat 0)

### Edge Cases
- What if sector has threat 0? → Disable selection
- What if sector is already lost (threat 4)? → Can attempt recapture (-3 threat on win)
- What if player abandons mission? → Counts as defeat

---

## User Interaction

### Controls
- **Click sector on map**: Open deployment panel
- **Confirm button**: Launch mission
- **Cancel button**: Return to map

### Visual Feedback
- Selected sector pulses cyan
- Deployment panel shows enemy preview
- Budget and hull availability displayed
- Mission brief appears

---

## Visual Design

### Layout
```
┌────────────────────────────────┐
│ DEPLOY TO: Shipyard            │
├────────────────────────────────┤
│ ENEMY: Heavy Cruiser           │
│ Threat Level: ███░ (3/4)       │
│                                │
│ STAKES:                        │
│ Win: Secure shipyard           │
│ Lose: Shipyard falls           │
│                                │
│ BUDGET: 30 BP                  │
│ HULL: Frigate, Battleship      │
│                                │
│ [CONFIRM] [CANCEL]             │
└────────────────────────────────┘
```

### Components
- **Deployment Panel**: Modal overlay showing mission details
- **Enemy Preview**: Icon + name + threat
- **Stakes Display**: Win/lose consequences
- **Budget Info**: Available budget for this mission

---

## Technical Implementation

### Scene Structure
```
DeploymentPanel.tscn
├── Background (Panel)
├── SectorNameLabel (Label)
├── EnemyPreview (HBoxContainer)
│   └── EnemyIcon, EnemyName
├── ThreatDisplay (ProgressBar)
├── StakesLabel (RichTextLabel)
├── BudgetLabel (Label)
├── ButtonContainer (HBoxContainer)
│   ├── ConfirmButton
│   └── CancelButton
```

### Script Responsibilities
- **DeploymentPanel.gd:** Shows mission preview, launches to designer
- **CampaignMap.gd:** Handles sector selection, battle results

### Data Structures
```gdscript
class SectorMission:
    var sector_id: String
    var enemy_id: String
    var budget: int
    var available_hulls: Array
    var stakes: Dictionary  # win/lose text
```

### Integration Points
- Connects to: ShipDesigner (launches with mission context)
- Emits signals: mission_confirmed(sector_id), mission_cancelled
- Listens for: battle_result(victory: bool)
- Modifies: GameState.current_mission, selected sector threat

---

## Acceptance Criteria

Feature is complete when:

- [ ] Clicking sector opens deployment panel
- [ ] Panel shows correct enemy and threat level
- [ ] Confirm button launches ship designer
- [ ] After battle, threat updates correctly (win: -2, lose: +1)
- [ ] All other sectors advance +1 threat

---

## Testing Checklist

### Functional Tests
- [ ] Deploy to sector with threat 2 → win → threat becomes 0
- [ ] Deploy to sector with threat 3 → lose → threat becomes 4 (lost)
- [ ] Undefended sectors all increase by +1 threat

---

# Feature 3: Threat Escalation System

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 8 hours
**Dependencies:** Feature 2 (Sector Defense)
**Assigned To:** AI Assistant

---

## Purpose

**Why does this feature exist?**
Creates strategic tension by making undefended sectors worse each turn, forcing meaningful trade-offs.

**What does it enable?**
Players must prioritize which sectors to save and which to sacrifice, creating emergent narrative.

**Success criteria:**
- Undefended sectors automatically worsen each turn
- Threat progression is clear and predictable
- Lost sectors stay lost (unless recaptured)
- Command sector is protected from falling

---

## How It Works

### Overview
After each battle, all sectors not defended this turn advance +1 threat level. When a sector reaches threat 4, it is marked as "lost" and provides penalties instead of bonuses. Command has special protection and cannot fall.

### User Flow
```
1. Player defends Sector A
2. Battle completes
3. System processes threat escalation:
   - Sector A: threat -2 (defended)
   - Sectors B-F: threat +1 each
4. Map updates visually
5. Lost sectors marked with X
```

### Rules & Constraints
- Threat range: 0 (secure) to 4 (lost)
- Undefended sectors: +1 threat per turn
- Defended sector (win): -2 threat
- Defended sector (lose): +1 threat
- Threat cannot go below 0 or above 4
- Command cannot reach threat 4 (game over at threat 3)

### Edge Cases
- What if all outer sectors are lost? → Game over (Command surrounded)
- What if defending a lost sector? → Win reduces threat by 3 (recapture)
- What if Command reaches threat 3? → Emergency mission: "Final Defense"

---

## Technical Implementation

### Script Responsibilities
- **ThreatEscalation.gd:** Calculates threat changes after battles
- **CampaignState.gd:** Stores threat history, triggers game over

### Data Structures
```gdscript
func process_threat_escalation(defended_sector: String, victory: bool):
    for sector in sectors:
        if sector == defended_sector:
            if victory:
                reduce_threat(sector, 2)
            else:
                increase_threat(sector, 1)
        else:
            increase_threat(sector, 1)

    check_game_over_conditions()
```

### Integration Points
- Emits signals: sector_lost(sector_id), game_over(reason)
- Modifies: All sector threat_level values

---

## Acceptance Criteria

Feature is complete when:

- [ ] Undefended sectors increase threat by +1 each turn
- [ ] Defended sector on win decreases threat by -2
- [ ] Sectors at threat 4 are marked as lost
- [ ] Game over triggers if all non-Command sectors lost
- [ ] Threat changes are visually animated on map

---

# Feature 4: Sector Bonuses & Penalties

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 16 hours
**Dependencies:** Feature 3 (Threat Escalation)
**Assigned To:** AI Assistant

---

## Purpose

**Why does this feature exist?**
Makes sector defense meaningful by providing tangible gameplay benefits for secure sectors and penalties for lost ones.

**What does it enable?**
Players experience real mechanical consequences from their strategic choices, not just narrative ones.

**Success criteria:**
- Each sector provides specific bonus when secure
- Lost sectors impose penalties
- Bonuses/penalties affect ship designer and combat
- Effects are clear and impactful

---

## How It Works

### Overview
Each of the 6 non-Command sectors provides a specific bonus when secure (threat 0-1) and a penalty when lost (threat 4). Bonuses affect budget, HP, damage, shields, or power. Effects apply immediately when entering ship designer.

### Sector Effects

**🏭 Shipyard:**
- Secure: +10 budget, Battleship hull available
- Lost: -5 budget, only Frigate hull available

**🏥 Medical:**
- Secure: Ships start at 100% HP
- Lost: Ships start at 60% HP, -20% max HP

**🌾 Colony:**
- Secure: Full crew efficiency
- Lost: -10% all stats (low morale)

**⚡ Power Station:**
- Secure: Reactors +20 power output
- Lost: Reactors -20 power output

**🛡️ Defense Grid:**
- Secure: Shields +30% absorption, shield cost -1
- Lost: Shields -30% absorption, shield cost +1

**🎯 Weapons Depot:**
- Secure: Weapons +30% damage, weapon cost -1
- Lost: Weapons -30% damage, weapon cost +1

### Rules & Constraints
- Bonuses apply at threat 0-1 (secure/lightly threatened)
- Penalties apply at threat 4 (lost)
- Threat 2-3: neutral (no bonus/penalty)
- Effects stack (multiple lost sectors = multiple penalties)
- Effects update immediately when sector status changes

---

## Technical Implementation

### Script Responsibilities
- **SectorBonus.gd:** Calculates active bonuses/penalties
- **ShipDesigner.gd:** Applies bonuses to budget and components
- **CombatEngine.gd:** Applies bonuses to damage/shields/HP

### Data Structures
```gdscript
func get_active_bonuses() -> Dictionary:
    var bonuses = {
        "budget_modifier": 0,
        "hp_modifier": 1.0,
        "damage_modifier": 1.0,
        "shield_modifier": 1.0,
        "power_modifier": 0
    }

    for sector in sectors.values():
        if sector.is_secure():
            apply_sector_bonus(bonuses, sector.bonus)
        elif sector.is_lost():
            apply_sector_penalty(bonuses, sector.penalty)

    return bonuses
```

### Integration Points
- Modifies: GameState mission budget, RoomData costs
- Affects: Combat damage calculations, ship HP

---

## Acceptance Criteria

Feature is complete when:

- [ ] Secure Shipyard increases budget by 10
- [ ] Lost Medical station reduces starting HP to 60%
- [ ] Lost Power station reduces reactor output
- [ ] Bonuses display in ship designer UI
- [ ] Combat applies damage/shield modifiers correctly
- [ ] Multiple bonuses/penalties stack correctly

---

# Feature 5: Ship Deployment & Fleet Building

**Status:** 🔴 Planned
**Priority:** ➡️ Medium
**Estimated Time:** 12 hours
**Dependencies:** Feature 2 (Sector Defense)
**Assigned To:** AI Assistant

---

## Purpose

**Why does this feature exist?**
Creates long-term meaning for ship designs by deploying them permanently to defended sectors, forcing design variety.

**What does it enable?**
Players build a fleet over the campaign, see their engineering legacy, and can't spam one optimal design.

**Success criteria:**
- Winning ships are deployed to defended sector
- Deployed ships are locked (hull unavailable)
- Fleet roster displays all deployed ships
- System forces design diversity across campaign

---

## How It Works

### Overview
When player wins a battle, their ship design is "deployed" to that sector permanently. The hull type used becomes unavailable for future missions. Player must design new ships using different hulls, creating variety.

### User Flow
```
1. Player designs Cruiser → wins battle at Medical
2. System creates deployment: "USS Defender" at Medical
3. Cruiser hull marked as unavailable
4. Next mission: Player must use Frigate or Battleship
5. Fleet roster shows "USS Defender (Cruiser) - Medical"
```

### Rules & Constraints
- One ship deployed per successful defense
- Deployed ships use their hull type permanently
- Frigate: Unlimited availability (always deployable)
- Cruiser: 3 max deployments
- Battleship: 3 max deployments (if Shipyard secure)
- Player can see fleet roster at any time

### Edge Cases
- What if all hulls are deployed? → Can reuse Frigate (unlimited)
- What if player loses battle? → No deployment, hull still available
- What if sector is recaptured? → Previous deployment removed

---

## Visual Design

### Fleet Roster Panel
```
┌────────────────────────────────┐
│ YOUR FLEET (3 ships deployed)  │
├────────────────────────────────┤
│ 🚀 USS Defender (Cruiser)      │
│    Station: Medical             │
│                                │
│ 🚀 USS Guardian (Frigate)      │
│    Station: Colony              │
│                                │
│ 🚀 USS Sentinel (Battleship)   │
│    Station: Shipyard            │
└────────────────────────────────┘
```

---

## Technical Implementation

### Data Structures
```gdscript
class DeployedShip:
    var ship_name: String
    var hull_type: GameState.HullType
    var sector_id: String
    var design_data: ShipData  # Original design

class FleetRoster:
    var deployed_ships: Array[DeployedShip]
    var hull_availability: Dictionary  # hull_type -> count remaining
```

### Integration Points
- Modifies: GameState.hull_availability
- Stores: CampaignState.fleet_roster
- Displays: FleetRosterPanel UI

---

## Acceptance Criteria

Feature is complete when:

- [ ] Winning battle deploys ship to sector
- [ ] Deployed hull becomes unavailable
- [ ] Fleet roster displays all ships
- [ ] Ship names auto-generate (USS + adjective)
- [ ] Frigate always available (unlimited)
- [ ] Battleship unavailable if Shipyard lost

---

# Feature 6: Victory Conditions & Rankings

**Status:** 🔴 Planned
**Priority:** ➡️ Medium
**Estimated Time:** 10 hours
**Dependencies:** Feature 3 (Threat Escalation)
**Assigned To:** AI Assistant

---

## Purpose

**Why does this feature exist?**
Provides clear campaign goals and rewards players for strategic excellence vs just surviving.

**What does it enable?**
Players can replay for better rankings, creating replayability and long-term goals.

**Success criteria:**
- Campaign ends at turn 12 or game over
- Victory ranking calculated based on sectors saved
- Different endings for different ranks
- Clear feedback on performance

---

## How It Works

### Overview
Campaign ends after 12 turns or if Command falls. System calculates victory rank based on how many sectors were saved (threat 0-2 at end). Rankings: S (6 sectors), A (5), B (3-4), C (1-2), Defeat (0 + Command lost).

### Victory Conditions

**S-Rank:** All 6 sectors saved (threat 0-2)
**A-Rank:** 5 sectors saved
**B-Rank:** 3-4 sectors saved
**C-Rank:** 1-2 sectors saved
**Defeat:** Command lost OR all sectors lost

### Rules & Constraints
- Campaign always ends at turn 12
- "Saved" = threat level 0-2 (not lost)
- Rank displayed with narrative ending
- Stats tracked: sectors saved, ships deployed, battles won

---

## Visual Design

### Victory Screen
```
┌────────────────────────────────┐
│ CAMPAIGN COMPLETE              │
│ TURN 12/12                     │
├────────────────────────────────┤
│                                │
│ RANK: A - Decisive Victory     │
│                                │
│ SECTORS SAVED: 5/6             │
│ FLEET SIZE: 10 ships           │
│ BATTLES WON: 11/12             │
│                                │
│ "Enemy advance halted.         │
│  Critical sectors secured.     │
│  Minor losses sustained."      │
│                                │
│ [NEW CAMPAIGN] [MAIN MENU]     │
└────────────────────────────────┘
```

---

## Technical Implementation

### Data Structures
```gdscript
func calculate_victory_rank() -> String:
    var saved_count = 0
    for sector in sectors.values():
        if sector.threat_level <= 2:
            saved_count += 1

    match saved_count:
        6: return "S"
        5: return "A"
        4, 3: return "B"
        2, 1: return "C"
        _: return "DEFEAT"
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] Campaign ends at turn 12
- [ ] Victory screen displays rank
- [ ] Rank calculated correctly (sector count)
- [ ] Different ending text for each rank
- [ ] Stats shown: sectors saved, fleet size, win rate

---

# Feature 7: Narrative Integration

**Status:** 🔴 Planned
**Priority:** ⬇️ Low
**Estimated Time:** 12 hours
**Dependencies:** All previous features
**Assigned To:** AI Assistant

---

## Purpose

**Why does this feature exist?**
Adds narrative context and emotional weight without requiring extensive writing or cutscenes.

**What does it enable?**
Players feel invested in the war, understand stakes, and remember key moments from their campaign.

**Success criteria:**
- Opening crawl sets context
- Mission briefs reference map state
- Event snippets trigger at key moments
- Endings vary based on performance

---

## How It Works

### Overview
Minimal text snippets appear at key moments: campaign start (opening crawl), mission deployment (contextual brief), mid-campaign events (threat triggers), and campaign end (rank-based ending). All text is brief and reactive to player choices.

### Narrative Elements

**Opening Crawl:**
```
SECTOR 7 - FRONTIER DEFENSE
━━━━━━━━━━━━━━━━━━━━━━━━━

Enemy fleet detected at sector boundary.
12 days until main invasion force arrives.

You are Chief Engineer.
Your ship designs are our only hope.

BEGIN OPERATIONS.
```

**Mission Briefs (Dynamic):**
- Reference sector status
- Mention threat level
- Include stakes

**Mid-Campaign Events:**
- Turn 5 if Colony threatened: Evacuation transmission
- Turn 8 if multiple sectors lost: Desperate plea
- Turn 11: Final stand message

**Endings (Rank-Based):**
- S-Rank: Triumphant victory
- A-Rank: Decisive win
- B-Rank: Pyrrhic victory
- C-Rank: Survived by the skin of teeth
- Defeat: Overrun

---

## Visual Design

### Text Display
```
┌────────────────────────────────┐
│ [INCOMING TRANSMISSION]        │
├────────────────────────────────┤
│                                │
│ "This is Colony Transport Z-9. │
│  Enemy raiders on our tail.    │
│  Can you spare a ship?"        │
│                                │
│ [CONTINUE]                     │
└────────────────────────────────┘
```

---

## Technical Implementation

### Data Structures
```gdscript
var narrative_events = {
    "colony_evacuation": {
        "trigger": "colony_threat >= 2 AND turn == 5",
        "text": "Colony evacuation transmission..."
    }
}

func check_narrative_triggers():
    for event_id in narrative_events:
        if evaluate_trigger(event_id):
            show_narrative_popup(event_id)
```

---

## Acceptance Criteria

Feature is complete when:

- [ ] Opening crawl plays at campaign start
- [ ] Mission briefs are contextual and dynamic
- [ ] Mid-campaign events trigger correctly
- [ ] Victory endings vary by rank
- [ ] All text is concise (<100 words per snippet)

---

## Implementation Timeline Summary

### Week 1: Core System (32 hours)
- Feature 1: Campaign Map Core (12h)
- Feature 2: Sector Defense System (10h)
- Feature 3: Threat Escalation (8h)
- **Milestone:** Playable campaign loop

### Week 2: Strategic Depth (38 hours)
- Feature 4: Sector Bonuses & Penalties (16h)
- Feature 5: Ship Deployment & Fleet (12h)
- Feature 6: Victory Conditions (10h)
- **Milestone:** Full strategic mechanics

### Week 3: Polish & Narrative (12 hours)
- Feature 7: Narrative Integration (12h)
- Bug fixes and balance tuning
- **Milestone:** Shippable campaign

**Total:** 82 hours (~3 weeks part-time)

---

## Success Metrics

Campaign system is complete when:
- ✅ Player can complete 12-turn campaign
- ✅ All sectors have functional bonuses/penalties
- ✅ Ship deployment locks hulls appropriately
- ✅ Victory rankings calculated correctly
- ✅ Narrative events trigger at correct moments
- ✅ Map state persists and saves correctly
- ✅ Game over conditions work (Command threat, all sectors lost)

---

## Scope Protection

**What this roadmap includes:**
- 7 sector map with threat system
- Turn-based strategic layer
- Sector bonuses and penalties
- Ship deployment and fleet building
- Victory rankings
- Minimal narrative integration

**What this roadmap DOES NOT include:**
- Resource economy
- Research trees
- Base building
- Random events
- Multiple campaigns
- Procedural generation
- Difficulty settings
- Multiplayer

**If you find yourself implementing anything in the second list, STOP and re-evaluate scope.**
