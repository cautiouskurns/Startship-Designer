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
	BATTLESHIP
}

## Currently selected hull type
var current_hull: HullType = HullType.CRUISER

## Hull type definitions
const HULL_TYPES = {
	HullType.FRIGATE: {
		"name": "FRIGATE",
		"grid_size": Vector2i(10, 4),
		"bonus_type": "initiative",
		"bonus_value": 2,
		"description": "+2 Initiative"
	},
	HullType.CRUISER: {
		"name": "CRUISER",
		"grid_size": Vector2i(8, 6),
		"bonus_type": "none",
		"bonus_value": 0,
		"description": "Balanced"
	},
	HullType.BATTLESHIP: {
		"name": "BATTLESHIP",
		"grid_size": Vector2i(7, 7),
		"bonus_type": "hull_hp",
		"bonus_value": 20,
		"description": "+20 HP"
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
