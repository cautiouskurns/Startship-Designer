extends Node

## Global game state singleton
## Tracks mission progression and unlocks

## Flag to track if data has been loaded from JSON
static var _data_loaded: bool = false

## Mission unlock states
var missions_unlocked: Array[bool] = [true, false, false]

## Currently selected mission (0 = Patrol, 1 = Convoy, 2 = Fleet)
var current_mission: int = 0

## Hull types (Phase 10.1)
enum HullType {
	FRIGATE,
	CRUISER,
	BATTLESHIP,
	FREE_DESIGN  # Custom free design mode - uses ShipGrid.gd dimensions
}

## Currently selected hull type
var current_hull: HullType = HullType.CRUISER

## Template to load when entering designer (set by HullSelect, cleared after load)
var template_to_load = null

## Template to restore after combat defeat (set before launching combat, cleared after load)
var redesign_template = null

## Battle replay data (Feature 2: Timeline Bar & Scrubbing)
var last_battle_result: BattleResult = null
var original_player_data: ShipData = null
var original_enemy_data: ShipData = null

## Hull type definitions (Phase 10.4 - shaped hulls) - now loaded from JSON
## grid_shape: 'X' = valid tile, '.' = empty space
## Ships taper from LEFT (wide engine side) to RIGHT (narrow weapon/bridge side)
static var HULL_TYPES = {
	HullType.FRIGATE: {
		"name": "FRIGATE",
		"grid_size": Vector2i(10, 4),
		"grid_shape": [
			"XXXXXX....",  # Row 0: wide back → narrow front
			"XXXXXXXX..",  # Row 1: sleek angular profile
			"XXXXXXXX..",  # Row 2: sleek angular profile
			"XXXXXX...."   # Row 3: wide back → narrow front
		],
		"bonus_type": "initiative",
		"bonus_value": 2,
		"description": "+2 Initiative"
	},
	HullType.CRUISER: {
		"name": "CRUISER",
		"grid_size": Vector2i(8, 6),
		"grid_shape": [
			"XXXXX...",  # Row 0: tapered front
			"XXXXXX..",  # Row 1: expanding
			"XXXXXXX.",  # Row 2: widest point
			"XXXXXXX.",  # Row 3: widest point
			"XXXXXX..",  # Row 4: tapering
			"XXXXX..."   # Row 5: tapered front
		],
		"bonus_type": "none",
		"bonus_value": 0,
		"description": "Balanced"
	},
	HullType.BATTLESHIP: {
		"name": "BATTLESHIP",
		"grid_size": Vector2i(7, 7),
		"grid_shape": [
			"XXXXX..",  # Row 0: broad back
			"XXXXXX.",  # Row 1: expanding
			"XXXXXXX",  # Row 2: full width - imposing
			"XXXXXXX",  # Row 3: full width - thickest
			"XXXXXXX",  # Row 4: full width - imposing
			"XXXXXX.",  # Row 5: tapering
			"XXXXX.."   # Row 6: front
		],
		"bonus_type": "hull_hp",
		"bonus_value": 20,
		"description": "+20 HP"
	},
	HullType.FREE_DESIGN: {
		"name": "FREE DESIGN",
		"grid_size": Vector2i(30, 30),  # Will be updated from ShipGrid if available
		"grid_shape": [],  # No shape restrictions
		"bonus_type": "none",
		"bonus_value": 0,
		"description": "No Restrictions"
	}
}

## Mission data - now loaded from JSON
static var MISSION_NAMES = [
	"PATROL DUTY",
	"CONVOY DEFENSE",
	"FLEET BATTLE"
]

static var MISSION_BRIEFS = [
	"Pirates raiding supply lines. Need fast interceptor.",
	"Enemy cruiser attacking convoy. Engage and destroy.",
	"Capital ship inbound. This is our final stand."
]

static var MISSION_BUDGETS = [50, 25, 30]

## Mission data array (loaded from JSON) - Phase 3
static var missions_data: Array = []

## Load mission and hull data from JSON files (Phase 3: Data-driven design)
static func _load_data_from_json():
	if _data_loaded:
		return

	# Load missions.json
	var missions_file = FileAccess.open("res://data/missions.json", FileAccess.READ)
	if missions_file:
		var json_text = missions_file.get_as_text()
		missions_file.close()

		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			var data = json.data
			if data and data.has("missions"):
				missions_data = data["missions"]

				# Update legacy arrays for backward compatibility
				MISSION_NAMES.clear()
				MISSION_BRIEFS.clear()
				MISSION_BUDGETS.clear()

				for mission in missions_data:
					MISSION_NAMES.append(mission.get("name", "UNKNOWN"))
					MISSION_BRIEFS.append(mission.get("brief", ""))
					MISSION_BUDGETS.append(mission.get("budget", 30))

				print("Mission data loaded from JSON successfully")
		else:
			push_error("Failed to parse missions.json: %s" % json.get_error_message())
	else:
		push_error("Failed to load missions.json! Using fallback data.")

	# Load hulls.json
	var hulls_file = FileAccess.open("res://data/hulls.json", FileAccess.READ)
	if hulls_file:
		var json_text = hulls_file.get_as_text()
		hulls_file.close()

		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			var data = json.data
			if data and data.has("hulls"):
				var hulls_data = data["hulls"]

				# Update HULL_TYPES dictionary with JSON data
				for hull_name in hulls_data.keys():
					var hull_type = _get_hull_type_from_name(hull_name)
					if hull_type == null:
						continue

					var hull_def = hulls_data[hull_name]
					var hull_dict = {}

					# Load name
					if hull_def.has("name"):
						hull_dict["name"] = hull_def["name"]

					# Load grid_size (convert [width, height] array to Vector2i)
					if hull_def.has("grid_size") and hull_def["grid_size"].size() == 2:
						hull_dict["grid_size"] = Vector2i(hull_def["grid_size"][0], hull_def["grid_size"][1])

					# Load grid_shape (array of strings)
					if hull_def.has("grid_shape"):
						hull_dict["grid_shape"] = hull_def["grid_shape"]

					# Load bonus_type
					if hull_def.has("bonus_type"):
						hull_dict["bonus_type"] = hull_def["bonus_type"]

					# Load bonus_value
					if hull_def.has("bonus_value"):
						hull_dict["bonus_value"] = hull_def["bonus_value"]

					# Load description
					if hull_def.has("description"):
						hull_dict["description"] = hull_def["description"]

					# Update HULL_TYPES
					HULL_TYPES[hull_type] = hull_dict

				print("Hull data loaded from JSON successfully")
		else:
			push_error("Failed to parse hulls.json: %s" % json.get_error_message())
	else:
		push_error("Failed to load hulls.json! Using fallback data.")

	_data_loaded = true

## Convert hull name string to HullType enum
static func _get_hull_type_from_name(name: String):
	match name:
		"FRIGATE": return HullType.FRIGATE
		"CRUISER": return HullType.CRUISER
		"BATTLESHIP": return HullType.BATTLESHIP
		"FREE_DESIGN": return HullType.FREE_DESIGN
		_:
			push_warning("Unknown hull type: %s" % name)
			return null

## Unlock a mission by index
func unlock_mission(index: int):
	if index >= 0 and index < missions_unlocked.size():
		missions_unlocked[index] = true

## Check if mission is unlocked
func is_mission_unlocked(index: int) -> bool:
	if index >= 0 and index < missions_unlocked.size():
		return missions_unlocked[index]
	return false

## Get mission budget by index
func get_mission_budget(index: int) -> int:
	_load_data_from_json()  # Ensure data is loaded
	if index >= 0 and index < MISSION_BUDGETS.size():
		return MISSION_BUDGETS[index]
	return 30  # Default fallback

## Get mission name by index
func get_mission_name(index: int) -> String:
	_load_data_from_json()  # Ensure data is loaded
	if index >= 0 and index < MISSION_NAMES.size():
		return MISSION_NAMES[index]
	return "UNKNOWN MISSION"

## Get mission brief by index
func get_mission_brief(index: int) -> String:
	_load_data_from_json()  # Ensure data is loaded
	if index >= 0 and index < MISSION_BRIEFS.size():
		return MISSION_BRIEFS[index]
	return ""

## Get enemy ID for a mission index (Phase 3)
func get_mission_enemy_id(index: int) -> String:
	_load_data_from_json()  # Ensure data is loaded
	if index >= 0 and index < missions_data.size():
		return missions_data[index].get("enemy_id", "scout")
	return "scout"  # Default fallback

## Reset progression (for testing)
func reset_progression():
	missions_unlocked = [true, false, false]
	current_mission = 0
	current_hull = HullType.CRUISER

## Get hull data for a specific hull type (Phase 10.1)
func get_hull_data(hull_type: HullType) -> Dictionary:
	_load_data_from_json()  # Ensure data is loaded
	if HULL_TYPES.has(hull_type):
		return HULL_TYPES[hull_type]
	return HULL_TYPES[HullType.CRUISER]  # Default fallback

## Get current hull data (Phase 10.1)
func get_current_hull_data() -> Dictionary:
	_load_data_from_json()  # Ensure data is loaded
	return get_hull_data(current_hull)

## Set current hull type (Phase 10.1)
func set_hull(hull_type: HullType):
	current_hull = hull_type

## Get hull name string (Phase 10.8 - for template system)
func get_hull_name(hull_type: HullType) -> String:
	var hull_data = get_hull_data(hull_type)
	return hull_data.get("name", "UNKNOWN")

## Store battle result for replay viewing (Feature 2: Timeline Bar & Scrubbing)
func store_battle_result(result: BattleResult):
	last_battle_result = result
	print("DEBUG: Battle result stored in GameState - ", result.get_summary())

## Get last battle result (Feature 2: Timeline Bar & Scrubbing)
func get_battle_result() -> BattleResult:
	return last_battle_result
