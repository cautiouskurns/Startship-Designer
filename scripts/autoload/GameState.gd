extends Node

## Global game state singleton
## Tracks mission progression and unlocks

## Mission unlock states
var missions_unlocked: Array[bool] = [true, false, false]

## Currently selected mission (0 = Patrol, 1 = Convoy, 2 = Fleet)
var current_mission: int = 0

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
