extends Panel
class_name MissionRequirementsPanel

## Displays mission requirements and objectives for the current mission
## Helps players design ships that match mission needs

## UI elements
@onready var mission_title_label: Label = $VBoxContainer/ScrollContainer/ContentMargin/Content/MissionTitleLabel
@onready var objective_label: Label = $VBoxContainer/ScrollContainer/ContentMargin/Content/ObjectiveSection/ObjectiveValue
@onready var enemy_label: Label = $VBoxContainer/ScrollContainer/ContentMargin/Content/EnemySection/EnemyValue
@onready var recommendation_label: Label = $VBoxContainer/ScrollContainer/ContentMargin/Content/RecommendationSection/RecommendationValue

func _ready():
	# Initialize with current mission data
	update_mission_requirements(GameState.current_mission)

## Update panel with mission requirements
func update_mission_requirements(mission_index: int):
	# Get mission data
	var mission_data = GameState.get_mission_data(mission_index)
	var mission_brief = GameState.get_mission_brief(mission_index)
	var enemy_id = GameState.get_mission_enemy_id(mission_index)
	var tech_level = GameState.get_mission_tech_level(mission_index)

	if mission_title_label:
		var tech_name = _get_tech_level_name(tech_level)
		mission_title_label.text = "MISSION %d: %s [%s]" % [(mission_index + 1), GameState.get_mission_name(mission_index), tech_name]

	if objective_label:
		objective_label.text = mission_brief

	# Load and display enemy configuration
	if enemy_label:
		var enemy_stats = _get_enemy_stats(enemy_id)
		enemy_label.text = enemy_stats

	# Provide strategic recommendation based on enemy
	if recommendation_label:
		var recommendation = _get_strategic_recommendation(enemy_id)
		recommendation_label.text = recommendation

## Get enemy stats text from enemy ID
func _get_enemy_stats(enemy_id: String) -> String:
	# Load enemy data from JSON
	ShipData._load_enemy_data_from_json()

	if not ShipData.enemies_data.has(enemy_id):
		return "Unknown enemy configuration"

	var enemy_data = ShipData.enemies_data[enemy_id]
	var enemy_name = enemy_data.get("name", "Unknown")
	var enemy_hp = enemy_data.get("hp", 0)
	var room_placements = enemy_data.get("room_placements", [])

	# Count room types
	var weapons = 0
	var shields = 0
	var engines = 0
	var reactors = 0
	var armor = 0

	for placement in room_placements:
		match placement.get("type", ""):
			"WEAPON": weapons += 1
			"SHIELD": shields += 1
			"ENGINE": engines += 1
			"REACTOR": reactors += 1
			"ARMOR": armor += 1

	# Format enemy stats
	var stats_text = "%s - %d HP\n" % [enemy_name, enemy_hp]
	stats_text += "⚔ %d Weapons  " % weapons
	stats_text += "🛡 %d Shields\n" % shields
	stats_text += "⚡ %d Reactors  " % reactors
	stats_text += "🚀 %d Engines" % engines

	return stats_text

## Get strategic recommendation based on enemy configuration
func _get_strategic_recommendation(enemy_id: String) -> String:
	match enemy_id:
		"scout":
			return "Light opponent. Focus on weapons to overwhelm their single shield. Minimal defense needed."
		"raider":
			return "Balanced threat with 3 weapons. Prioritize shields and armor. Target their weapons first."
		"dreadnought":
			return "Heavy firepower and shields. Maximum armor recommended. Protect your reactors - they target power systems."
		_:
			return "Analyze enemy and adjust design accordingly"

## Get tech level display name
func _get_tech_level_name(tech_level: int) -> String:
	match tech_level:
		1:
			return "TECH I"
		2:
			return "TECH II"
		3:
			return "TECH III"
		_:
			return "TECH %d" % tech_level
