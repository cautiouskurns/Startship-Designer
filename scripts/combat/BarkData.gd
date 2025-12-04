extends RefCounted
class_name BarkData

## Data structure for crew bark information
## Used by CrewBarkSystem to track and display crew commentary

## Bark text content
var text: String = ""

## Crew role speaking this bark
var role: CrewRole = CrewRole.OPERATIONS

## Priority level (affects queue order)
var priority: BarkPriority = BarkPriority.MEDIUM

## Category (for filtering and selection)
var category: BarkCategory = BarkCategory.TACTICAL_UPDATE

## Optional audio file path (for Phase 2)
var audio_file: String = ""

## Priority levels - higher priority barks play first
enum BarkPriority {
	LOW = 0,       # Minor hits, low-consequence events
	MEDIUM = 1,    # System damage, moderate hits
	HIGH = 2,      # Critical systems, HP thresholds
	CRITICAL = 3,  # Battle start/end, player death
}

## Bark categories - determines which events trigger which barks
enum BarkCategory {
	DAMAGE_REPORT,    # Component destroyed or damaged
	TACTICAL_UPDATE,  # Combat progress (hits, enemy status)
	SYSTEM_STATUS,    # Power, resources, system state
	CREW_STRESS,      # Ship HP thresholds, panic
	VICTORY_DEFEAT,   # Battle end conditions
}

## Crew roles - determines voice/color in UI
enum CrewRole {
	CAPTAIN,      # Commands, victory/defeat
	TACTICAL,     # Weapons, targeting updates
	ENGINEERING,  # Power, damage control
	OPERATIONS,   # General systems status
}

## Create a new bark with all properties
static func create(p_text: String, p_role: CrewRole, p_priority: BarkPriority,
                   p_category: BarkCategory, p_audio_file: String = "") -> BarkData:
	var bark = BarkData.new()
	bark.text = p_text
	bark.role = p_role
	bark.priority = p_priority
	bark.category = p_category
	bark.audio_file = p_audio_file
	return bark

## Get role name as string (for UI display)
static func role_to_string(role: CrewRole) -> String:
	match role:
		CrewRole.CAPTAIN:
			return "CAPTAIN"
		CrewRole.TACTICAL:
			return "TACTICAL"
		CrewRole.ENGINEERING:
			return "ENGINEERING"
		CrewRole.OPERATIONS:
			return "OPS"
	return "UNKNOWN"

## Get priority name as string (for debugging)
static func priority_to_string(prio: BarkPriority) -> String:
	match prio:
		BarkPriority.LOW:
			return "LOW"
		BarkPriority.MEDIUM:
			return "MEDIUM"
		BarkPriority.HIGH:
			return "HIGH"
		BarkPriority.CRITICAL:
			return "CRITICAL"
	return "UNKNOWN"
