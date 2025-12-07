# Campaign System Integration Test Checklist

## Feature 1: Campaign Map Core - Testing Guide

### Pre-Test Setup
- [ ] Open project in Godot 4.5 editor
- [ ] Verify no errors in Output/Debugger panel
- [ ] Check that CampaignState appears in Autoloads (Project Settings > Autoload)

### Test 1: Initial Campaign Launch
**Steps:**
1. Run the project (F5)
2. Click "NEW GAME" button on Main Menu

**Expected Results:**
- [ ] CampaignMap scene loads successfully
- [ ] Title displays "SECTOR 7 DEFENSE"
- [ ] Turn counter shows "TURN 1/12"
- [ ] 7 sector nodes visible in star formation:
  - [ ] Command (center) - 🏛️
  - [ ] Shipyard (inner left) - 🏭
  - [ ] Medical (inner right) - ⚕️
  - [ ] Colony (bottom) - 🌍
  - [ ] Power (outer left) - ⚡
  - [ ] Defense (top) - 🛡️
  - [ ] Weapons (outer right) - 🔫
- [ ] All sectors show threat level 0 (green borders, empty threat bars)
- [ ] Command sector is disabled (can't click)

### Test 2: Sector Selection
**Steps:**
1. Click on SHIPYARD sector (🏭)

**Expected Results:**
- [ ] DeploymentPanel appears (centered modal)
- [ ] Shows "DEPLOY TO: 🏭 SHIPYARD"
- [ ] Enemy displays "Raider (Medium)"
- [ ] Threat bar shows "░░░░ (0/4) - SECURE"
- [ ] Stakes section shows:
  - WIN: Secure sector (-2 threat)
  - LOSE: Sector worsens (+1 threat)
  - CURRENT BONUS: +10 budget to all missions...
- [ ] Budget displays correctly (e.g., "20 BP" for Mission 1)
- [ ] Both CANCEL and CONFIRM buttons are visible

### Test 3: Deployment Cancellation
**Steps:**
1. With DeploymentPanel open, click "CANCEL"

**Expected Results:**
- [ ] DeploymentPanel closes
- [ ] Returns to CampaignMap view
- [ ] Can select different sector

### Test 4: Deployment Confirmation & ShipDesigner Launch
**Steps:**
1. Click on MEDICAL sector (⚕️)
2. Review deployment details
3. Click "CONFIRM"

**Expected Results:**
- [ ] Scene transitions to ShipDesigner
- [ ] Budget reflects mission difficulty (varies by enemy)
- [ ] Can design ship normally
- [ ] "LAUNCH" button works

### Test 5: Battle Flow (Win Scenario)
**Steps:**
1. Design a strong ship in ShipDesigner
2. Click "LAUNCH" to start battle
3. Win the battle

**Expected Results:**
- [ ] After battle victory, returns to CampaignMap
- [ ] Turn counter advances to "TURN 2/12"
- [ ] Defended sector threat level decreased by 2
- [ ] All other sectors (except Command) threat level increased by 1
- [ ] Sector visual states update (colors, threat bars)

### Test 6: Battle Flow (Loss Scenario)
**Steps:**
1. Click on a sector
2. Confirm deployment
3. Design a weak ship (e.g., Bridge only)
4. Launch and lose battle

**Expected Results:**
- [ ] After battle loss, returns to CampaignMap
- [ ] Turn counter advances
- [ ] Defended sector threat level increased by 1
- [ ] All other sectors threat level increased by 1
- [ ] Can select and retry same or different sector

### Test 7: Threat Level Progression
**Steps:**
1. Let multiple sectors reach threat level 3-4 by defending only one sector

**Expected Results:**
- [ ] Sector at threat 1: yellow-green border
- [ ] Sector at threat 2-3: yellow border, pulsing
- [ ] Sector at threat 4: red border, pulsing, marked "CRITICAL"
- [ ] If sector reaches threat 5: becomes "LOST" (gray, disabled)

### Test 8: Campaign End Conditions
**Steps:**
1. Play until turn 12 OR until campaign failure

**Expected Results (Turn 12 Reached):**
- [ ] Victory screen appears
- [ ] Shows sectors saved count (X/6)
- [ ] Shows victory rank
- [ ] After 3 seconds, returns to main menu

**Expected Results (Campaign Failure):**
- [ ] Game over screen appears
- [ ] Shows failure message
- [ ] After 3 seconds, returns to main menu

### Test 9: Multiple Sector Selection
**Steps:**
1. Click different sectors and review their deployment panels

**Expected Results:**
- [ ] Each sector shows unique enemy type:
  - Shipyard → Raider
  - Medical → Scout
  - Colony → Scout
  - Power → Raider
  - Defense → Dreadnought
  - Weapons → Raider
- [ ] Stakes text reflects sector-specific bonuses/penalties
- [ ] Budget varies based on enemy difficulty

### Test 10: Integration with Existing Systems
**Steps:**
1. Play a complete turn (select sector → design → battle → return)

**Expected Results:**
- [ ] GameState.current_mission set correctly
- [ ] Tech level updates appropriately
- [ ] Battle results stored in GameState.last_battle_result
- [ ] CampaignState.last_defended_sector persists through battle
- [ ] No errors in console/debugger

---

## Known Limitations (By Design)
- Command sector cannot be defended (always secure)
- Only 1 sector can be defended per turn
- Ship design not saved between battles (intentional - fresh design each battle)
- No mid-campaign save/load (play in single session)

## Common Issues & Solutions

**Issue:** CampaignMap doesn't load
- **Check:** project.godot has CampaignState registered in autoloads
- **Check:** MainMenu.gd line 20 points to CampaignMap.tscn

**Issue:** Sectors don't appear
- **Check:** SectorNode.tscn exists at scenes/campaign/components/
- **Check:** sector_id properties set in CampaignMap.tscn (0-6)

**Issue:** DeploymentPanel doesn't show
- **Check:** DeploymentPanel.tscn exists at scenes/campaign/components/
- **Check:** Signal connections in CampaignMap._ready()

**Issue:** Battle doesn't return to CampaignMap
- **Check:** GameState.last_battle_result is set after battle
- **Check:** CampaignMap._initialize_campaign() checks for battle result

**Issue:** Threat levels don't update
- **Check:** CampaignState.process_threat_escalation() called in _process_battle_result()
- **Check:** SectorNode.update_display() called after threat changes

---

## File Verification Checklist
- [x] scripts/autoload/CampaignState.gd (194 lines)
- [x] data/sectors.json (100+ lines, 7 sectors defined)
- [x] scripts/campaign/SectorNode.gd (165 lines)
- [x] scenes/campaign/components/SectorNode.tscn
- [x] scripts/campaign/DeploymentPanel.gd (120 lines)
- [x] scenes/campaign/components/DeploymentPanel.tscn
- [x] scripts/campaign/CampaignMap.gd (135 lines)
- [x] scenes/campaign/CampaignMap.tscn (140 lines)
- [x] scripts/ui/MainMenu.gd (line 20 updated)
- [x] project.godot (CampaignState in autoloads)

---

## Next Steps After Testing
1. Fix any bugs discovered during testing
2. Balance tune threat escalation rates
3. Adjust sector bonus/penalty values
4. Implement Feature 2: Sector Defense (hull deployment locking)
5. Implement Feature 3: Threat Escalation (enhanced mechanics)

## Testing Sign-Off

Date: _______________
Tester: _______________

All critical tests passed: [ ] YES [ ] NO

Notes:
_____________________________________________
_____________________________________________
_____________________________________________
