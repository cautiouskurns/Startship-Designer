extends Node

## Campaign State Singleton
## Manages campaign progression, sector states, and turn tracking

## Sector IDs (must match sectors.json)
enum SectorID {
	COMMAND,
	SHIPYARD,
	MEDICAL,
	COLONY,
	POWER,
	DEFENSE,
	WEAPONS
}

## Sector data class
class SectorData:
	var sector_id: SectorID
	var threat_level: int = 0  # 0-4 (0=secure, 4=lost)
	var is_lost: bool = false
	var bonus_active: bool = true

	func _init(id: SectorID):
		sector_id = id

	## Check if sector is secure (threat 0-1)
	func is_secure() -> bool:
		return threat_level <= 1

	## Check if sector is threatened (threat 2-3)
	func is_threatened() -> bool:
		return threat_level >= 2 and threat_level < 4

	## Check if sector is critical (threat 3)
	func is_critical() -> bool:
		return threat_level == 3

## Campaign state variables
var current_turn: int = 1
var max_turns: int = 12
var campaign_active: bool = false
var last_defended_sector: SectorID = SectorID.COMMAND
var sectors: Dictionary = {}  # SectorID -> SectorData
var current_tech_level: int = 1  # Tech level (1-3), unlocks components as campaign progresses

## Sector definitions (loaded from JSON)
var sector_definitions: Dictionary = {}

func _ready():
	_initialize_campaign()
	_load_sector_definitions()

## Initialize new campaign
func _initialize_campaign():
	current_turn = 1
	current_tech_level = 1  # Start at tech level 1
	campaign_active = true
	sectors.clear()

	# Initialize all 7 sectors
	for sector_id in SectorID.values():
		sectors[sector_id] = SectorData.new(sector_id)

	print("Campaign initialized - Turn 1/12, Tech Level 1, all sectors secure")

## Load sector definitions from JSON
func _load_sector_definitions():
	var file = FileAccess.open("res://data/sectors.json", FileAccess.READ)
	if not file:
		push_error("Failed to load sectors.json!")
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("Failed to parse sectors.json: %s" % json.get_error_message())
		return

	var data = json.data
	if data and data.has("sectors"):
		sector_definitions = data["sectors"]
		print("Sector definitions loaded from JSON")

## Get sector data by ID
func get_sector(sector_id: SectorID) -> SectorData:
	return sectors.get(sector_id)

## Get sector definition by ID
func get_sector_definition(sector_id: SectorID) -> Dictionary:
	var sector_key = SectorID.keys()[sector_id]
	return sector_definitions.get(sector_key, {})

## Get current tech level for unlocking components
func get_tech_level() -> int:
	return current_tech_level

## Get budget for a specific sector based on its enemy
func get_budget_for_sector(sector_id: SectorID) -> int:
	var sector_def = get_sector_definition(sector_id)
	var enemy_id = sector_def.get("enemy_id", "scout")

	# Map enemy to mission index
	var mission_index = 0
	match enemy_id:
		"scout":
			mission_index = 0
		"raider":
			mission_index = 1
		"dreadnought":
			mission_index = 2
		_:
			mission_index = 0

	# Get budget from GameState mission data
	return GameState.get_mission_budget(mission_index)

## Advance turn after battle
func advance_turn():
	current_turn += 1

	# Update tech level based on turn progression
	# Turns 1-4: Tech Level 1 (basic)
	# Turns 5-8: Tech Level 2 (intermediate)
	# Turns 9-12: Tech Level 3 (advanced)
	var old_tech = current_tech_level
	if current_turn >= 9:
		current_tech_level = 3
	elif current_turn >= 5:
		current_tech_level = 2
	else:
		current_tech_level = 1

	if old_tech != current_tech_level:
		print("Tech Level increased to %d!" % current_tech_level)

	print("Turn advanced to %d/%d (Tech Level %d)" % [current_turn, max_turns, current_tech_level])

	# Check for campaign end
	if current_turn > max_turns:
		_end_campaign()

## Process threat escalation after battle
## defended_sector: which sector was defended this turn
## victory: whether the player won the battle
func process_threat_escalation(defended_sector: SectorID, victory: bool):
	print("Processing threat escalation - Defended: %s, Victory: %s" % [SectorID.keys()[defended_sector], victory])

	for sector_id in sectors.keys():
		var sector = sectors[sector_id]

		# Command cannot fall
		if sector_id == SectorID.COMMAND:
			continue

		if sector_id == defended_sector:
			# Player defended this sector
			if victory:
				# Victory: reduce threat by 2
				_change_threat(sector, -2)
			else:
				# Defeat: increase threat by 1
				_change_threat(sector, 1)
		else:
			# Undefended sector: increase threat by 1
			_change_threat(sector, 1)

	# Check game over conditions
	_check_game_over()

## Change sector threat level (clamped to 0-4)
func _change_threat(sector: SectorData, delta: int):
	var old_threat = sector.threat_level
	sector.threat_level = clamp(sector.threat_level + delta, 0, 4)

	# Mark as lost if threat reaches 4
	if sector.threat_level >= 4:
		sector.is_lost = true
		sector.bonus_active = false
		print("Sector %s LOST (threat 4)" % SectorID.keys()[sector.sector_id])
	elif sector.threat_level <= 1:
		sector.is_lost = false
		sector.bonus_active = true

	if delta != 0:
		print("Sector %s threat: %d -> %d" % [SectorID.keys()[sector.sector_id], old_threat, sector.threat_level])

## Check game over conditions
func _check_game_over():
	# Count lost sectors (excluding Command)
	var lost_count = 0
	for sector_id in sectors.keys():
		if sector_id != SectorID.COMMAND and sectors[sector_id].is_lost:
			lost_count += 1

	# Game over if all non-Command sectors lost
	if lost_count >= 6:
		print("GAME OVER: All sectors lost")
		campaign_active = false
		# TODO: Trigger game over screen

	# Game over if Command threatened critically
	var command = sectors[SectorID.COMMAND]
	if command.threat_level >= 3:
		print("GAME OVER: Command under critical threat")
		campaign_active = false
		# TODO: Trigger game over screen

## End campaign (victory at turn 12)
func _end_campaign():
	campaign_active = false
	var saved_count = _count_saved_sectors()
	var rank = _calculate_victory_rank(saved_count)

	print("CAMPAIGN COMPLETE!")
	print("Sectors Saved: %d/6" % saved_count)
	print("Victory Rank: %s" % rank)

	# TODO: Show victory screen with rank

## Count saved sectors (threat 0-2)
func _count_saved_sectors() -> int:
	var count = 0
	for sector_id in sectors.keys():
		if sector_id != SectorID.COMMAND and sectors[sector_id].threat_level <= 2:
			count += 1
	return count

## Calculate victory rank based on saved sectors
func _calculate_victory_rank(saved_count: int) -> String:
	match saved_count:
		6: return "S"
		5: return "A"
		4, 3: return "B"
		2, 1: return "C"
		_: return "DEFEAT"

## Reset campaign to initial state
func reset_campaign():
	_initialize_campaign()
	print("Campaign reset to Turn 1/12, Tech Level 1")

## Save campaign state (for persistence between battles)
func save_campaign_state() -> Dictionary:
	var save_data = {
		"current_turn": current_turn,
		"current_tech_level": current_tech_level,
		"campaign_active": campaign_active,
		"last_defended_sector": last_defended_sector,
		"sectors": {}
	}

	# Save each sector's state
	for sector_id in sectors.keys():
		var sector = sectors[sector_id]
		save_data["sectors"][sector_id] = {
			"threat_level": sector.threat_level,
			"is_lost": sector.is_lost,
			"bonus_active": sector.bonus_active
		}

	return save_data

## Load campaign state (for resuming after battle)
func load_campaign_state(save_data: Dictionary):
	if not save_data:
		return

	current_turn = save_data.get("current_turn", 1)
	current_tech_level = save_data.get("current_tech_level", 1)
	campaign_active = save_data.get("campaign_active", true)
	last_defended_sector = save_data.get("last_defended_sector", SectorID.COMMAND)

	# Restore sector states
	var sectors_data = save_data.get("sectors", {})
	for sector_id in sectors_data.keys():
		if sectors.has(sector_id):
			var sector = sectors[sector_id]
			var sector_data = sectors_data[sector_id]
			sector.threat_level = sector_data.get("threat_level", 0)
			sector.is_lost = sector_data.get("is_lost", false)
			sector.bonus_active = sector_data.get("bonus_active", true)

	print("Campaign state loaded - Turn %d/%d, Tech Level %d" % [current_turn, max_turns, current_tech_level])
