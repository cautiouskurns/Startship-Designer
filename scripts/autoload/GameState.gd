extends Node

## Global game state singleton
## Tracks mission progression and unlocks

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

## Hull type definitions (Phase 10.4 - shaped hulls)
## grid_shape: 'X' = valid tile, '.' = empty space
## Ships taper from LEFT (wide engine side) to RIGHT (narrow weapon/bridge side)
const HULL_TYPES = {
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
		"grid_size": Vector2i(ShipGrid.DEFAULT_FREE_DESIGN_WIDTH, ShipGrid.DEFAULT_FREE_DESIGN_HEIGHT),
		"grid_shape": [],  # No shape restrictions
		"bonus_type": "none",
		"bonus_value": 0,
		"description": "No Restrictions"
	}
}

## Mission data
const MISSION_NAMES = [
	"PATROL DUTY",
	"CONVOY DEFENSE",
	"FLEET BATTLE"
]

const MISSION_BRIEFS = [
	"Pirates raiding supply lines. Need fast interceptor.",
	"Enemy cruiser attacking convoy. Engage and destroy.",
	"Capital ship inbound. This is our final stand."
]

const MISSION_BUDGETS = [20, 25, 30]

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
	if index >= 0 and index < MISSION_BUDGETS.size():
		return MISSION_BUDGETS[index]
	return 30  # Default fallback

## Get mission name by index
func get_mission_name(index: int) -> String:
	if index >= 0 and index < MISSION_NAMES.size():
		return MISSION_NAMES[index]
	return "UNKNOWN MISSION"

## Get mission brief by index
func get_mission_brief(index: int) -> String:
	if index >= 0 and index < MISSION_BRIEFS.size():
		return MISSION_BRIEFS[index]
	return ""

## Reset progression (for testing)
func reset_progression():
	missions_unlocked = [true, false, false]
	current_mission = 0
	current_hull = HullType.CRUISER

## Get hull data for a specific hull type (Phase 10.1)
func get_hull_data(hull_type: HullType) -> Dictionary:
	if HULL_TYPES.has(hull_type):
		return HULL_TYPES[hull_type]
	return HULL_TYPES[HullType.CRUISER]  # Default fallback

## Get current hull data (Phase 10.1)
func get_current_hull_data() -> Dictionary:
	return get_hull_data(current_hull)

## Set current hull type (Phase 10.1)
func set_hull(hull_type: HullType):
	current_hull = hull_type

## Get hull name string (Phase 10.8 - for template system)
func get_hull_name(hull_type: HullType) -> String:
	var hull_data = get_hull_data(hull_type)
	return hull_data.get("name", "UNKNOWN")
