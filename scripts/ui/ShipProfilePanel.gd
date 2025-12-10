extends Panel

## ShipProfilePanel - Main controller for ship profile visualization
## Provides real-time feedback on ship stats, archetype, and predicted performance

# Stats (0.0 to 1.0)
var offense: float = 0.0
var defense: float = 0.0
var speed: float = 0.0
var durability: float = 0.0
var efficiency: float = 0.0

# Archetype
enum Archetype {
	INCOMPLETE,
	GLASS_CANNON,
	TURTLE,
	SPEEDSTER,
	BALANCED,
	JUGGERNAUT,
	ALPHA_STRIKER,
	LAST_STAND,
	GUERRILLA
}
var current_archetype: Archetype = Archetype.INCOMPLETE

# Room counts (cached for calculations)
var weapon_count: int = 0
var shield_count: int = 0
var engine_count: int = 0
var armor_count: int = 0
var reactor_count: int = 0
var bridge_count: int = 0
var total_rooms: int = 0
var powered_rooms: int = 0

# Reference to ship data (set by ShipDesigner)
var ship_data: ShipData = null

# Signals
signal profile_updated(offense: float, defense: float, speed: float, durability: float, efficiency: float, archetype: Archetype)
signal archetype_changed(old: Archetype, new: Archetype)

# Node references
@onready var radar_chart: Control = $MarginContainer/VBoxContainer/RadarChartContainer
@onready var archetype_label: Label = $MarginContainer/VBoxContainer/ArchetypeLabel
@onready var offense_bar: ProgressBar = $MarginContainer/VBoxContainer/StatsContainer/OffenseRow/OffenseBar
@onready var offense_percent: Label = $MarginContainer/VBoxContainer/StatsContainer/OffenseRow/OffensePercent
@onready var defense_bar: ProgressBar = $MarginContainer/VBoxContainer/StatsContainer/DefenseRow/DefenseBar
@onready var defense_percent: Label = $MarginContainer/VBoxContainer/StatsContainer/DefenseRow/DefensePercent
@onready var speed_bar: ProgressBar = $MarginContainer/VBoxContainer/StatsContainer/SpeedRow/SpeedBar
@onready var speed_percent: Label = $MarginContainer/VBoxContainer/StatsContainer/SpeedRow/SpeedPercent
@onready var durability_bar: ProgressBar = $MarginContainer/VBoxContainer/StatsContainer/DurabilityRow/DurabilityBar
@onready var durability_percent: Label = $MarginContainer/VBoxContainer/StatsContainer/DurabilityRow/DurabilityPercent
@onready var efficiency_bar: ProgressBar = $MarginContainer/VBoxContainer/StatsContainer/EfficiencyRow/EfficiencyBar
@onready var efficiency_percent: Label = $MarginContainer/VBoxContainer/StatsContainer/EfficiencyRow/EfficiencyPercent
@onready var warnings_list: VBoxContainer = $MarginContainer/VBoxContainer/WarningsContainer/WarningsList
@onready var performance_list: VBoxContainer = $MarginContainer/VBoxContainer/PerformanceContainer/PerformanceList
@onready var win_chances_list: VBoxContainer = $MarginContainer/VBoxContainer/WinChancesContainer/WinChancesList

# Constants
const MAX_DAMAGE = 60.0  # 6 weapons × 10 dmg
const MAX_DEFENSE = 150.0  # Max shields + armor combined
const MAX_DURABILITY = 200.0  # Max hull HP
const BASE_HULL_HP = 60
const WEAPON_DAMAGE = 10
const SHIELD_ABSORPTION = 15
const ARMOR_HP_BONUS = 20

# Archetype colors
const ARCHETYPE_COLORS = {
	Archetype.BALANCED: Color(0.29, 0.89, 0.29),  # Green
	Archetype.GLASS_CANNON: Color(0.89, 0.29, 0.29),  # Red (extreme)
	Archetype.TURTLE: Color(0.89, 0.83, 0.29),  # Yellow (specialized)
	Archetype.SPEEDSTER: Color(0.89, 0.83, 0.29),  # Yellow (specialized)
	Archetype.JUGGERNAUT: Color(0.89, 0.83, 0.29),  # Yellow (specialized)
	Archetype.ALPHA_STRIKER: Color(0.89, 0.29, 0.29),  # Red (extreme)
	Archetype.LAST_STAND: Color(0.89, 0.29, 0.29),  # Red (extreme)
	Archetype.GUERRILLA: Color(0.89, 0.83, 0.29),  # Yellow (specialized)
	Archetype.INCOMPLETE: Color(0.5, 0.5, 0.5)  # Gray
}

func _ready():
	# Initialize with empty stats
	recalculate()

## Set reference to ship data
func set_ship_data(data: ShipData):
	ship_data = data

## Recalculate all stats and update UI
func recalculate():
	if not ship_data:
		_reset_to_empty()
		return

	# Count rooms
	weapon_count = _count_rooms_of_category(ComponentCategory.Category.WEAPONS)
	shield_count = _count_rooms_of_type(RoomData.RoomType.SHIELD)
	engine_count = _count_rooms_of_category(ComponentCategory.Category.PROPULSION)
	armor_count = _count_rooms_of_type(RoomData.RoomType.ARMOR)
	reactor_count = _count_rooms_of_type(RoomData.RoomType.REACTOR)
	bridge_count = _count_rooms_of_type(RoomData.RoomType.BRIDGE)
	total_rooms = weapon_count + shield_count + engine_count + armor_count + reactor_count + bridge_count
	powered_rooms = _count_powered_rooms()

	# Calculate stats (0-100 scale)
	offense = calculate_offense()
	defense = calculate_defense()
	speed = calculate_speed()
	durability = calculate_durability()
	efficiency = calculate_efficiency()

	# Detect archetype
	var old_archetype = current_archetype
	current_archetype = detect_archetype()
	if old_archetype != current_archetype:
		archetype_changed.emit(old_archetype, current_archetype)

	# Update UI
	_update_radar_chart()
	_update_stat_bars()
	_update_archetype_label()
	_update_warnings()
	_update_performance()
	_update_win_chances()

	profile_updated.emit(offense, defense, speed, durability, efficiency, current_archetype)

## Calculate offense stat
func calculate_offense() -> float:
	if weapon_count == 0:
		return 0.0
	# Max possible damage ~60 (6 weapons × 10 dmg)
	var damage_output = weapon_count * WEAPON_DAMAGE
	return min(100.0, (damage_output / MAX_DAMAGE) * 100.0)

## Calculate defense stat
func calculate_defense() -> float:
	# Max possible defense ~150 (shields + armor)
	var shield_value = shield_count * SHIELD_ABSORPTION  # Shield absorption
	var armor_value = armor_count * ARMOR_HP_BONUS   # HP bonus
	var total_defense = shield_value + armor_value
	return min(100.0, (total_defense / MAX_DEFENSE) * 100.0)

## Calculate speed stat
func calculate_speed() -> float:
	# Max speed ~6 engines
	var speed_value = engine_count * 16.67
	return min(100.0, speed_value)

## Calculate durability stat
func calculate_durability() -> float:
	# Base hull 60, max ~200 with armor
	var hull_hp = BASE_HULL_HP + (armor_count * ARMOR_HP_BONUS)
	return min(100.0, (hull_hp / MAX_DURABILITY) * 100.0)

## Calculate efficiency stat
func calculate_efficiency() -> float:
	if total_rooms == 0:
		return 100.0
	return (float(powered_rooms) / float(total_rooms)) * 100.0

## Detect ship archetype based on stats
func detect_archetype() -> Archetype:
	if total_rooms < 5:
		return Archetype.INCOMPLETE

	# Check extreme archetypes first
	if offense >= 80 and speed >= 60:
		return Archetype.ALPHA_STRIKER
	if durability >= 80 and defense >= 70:
		return Archetype.LAST_STAND
	if speed >= 70 and efficiency >= 60:
		return Archetype.GUERRILLA

	# Check primary archetypes
	if offense >= 70 and defense <= 30:
		return Archetype.GLASS_CANNON
	if defense >= 70 and offense <= 40:
		return Archetype.TURTLE
	if speed >= 70 and durability <= 40:
		return Archetype.SPEEDSTER
	if durability >= 70 and speed <= 30:
		return Archetype.JUGGERNAUT

	# Check balanced
	if offense >= 40 and offense <= 60 and defense >= 40 and defense <= 60:
		return Archetype.BALANCED

	return Archetype.BALANCED  # Default fallback

## Analyze weaknesses and return warning messages
func analyze_weaknesses() -> Array[String]:
	var warnings: Array[String] = []

	if armor_count <= 1:
		warnings.append("Low armor (only %d room)" % armor_count)
	if shield_count == 0:
		warnings.append("No shields - vulnerable to burst damage")
	if engine_count == 0:
		warnings.append("No engines - will always shoot last")
	if reactor_count == 1 and total_rooms > 8:
		warnings.append("Single reactor - critical failure point")
	if powered_rooms < total_rooms:
		warnings.append("%d unpowered rooms (wasted budget)" % (total_rooms - powered_rooms))
	if weapon_count <= 1:
		warnings.append("Low firepower - battles will drag")
	if offense >= 70 and defense <= 20:
		warnings.append("Extreme glass cannon - one mistake = death")
	if defense >= 80 and offense <= 20:
		warnings.append("Too defensive - can't win by timeout")

	# Return max 3 warnings
	return warnings.slice(0, 3)

## Predict performance based on archetype
func predict_performance() -> Dictionary:
	var predictions = {
		"strengths": [],
		"weaknesses": []
	}

	# Analyze based on archetype
	match current_archetype:
		Archetype.GLASS_CANNON:
			predictions["strengths"].append("Fast decisive battles")
			predictions["weaknesses"].append("Attrition warfare")
			predictions["weaknesses"].append("Multi-phase encounters")
		Archetype.TURTLE:
			predictions["strengths"].append("Long battles")
			predictions["strengths"].append("Surviving alpha strikes")
			predictions["weaknesses"].append("Low damage output")
		Archetype.SPEEDSTER:
			predictions["strengths"].append("First strike advantage")
			predictions["strengths"].append("Avoiding slow enemies")
			predictions["weaknesses"].append("Prolonged combat")
		Archetype.BALANCED:
			predictions["strengths"].append("Versatile performance")
			predictions["strengths"].append("No critical weaknesses")
			predictions["weaknesses"].append("No dominant strength")
		Archetype.ALPHA_STRIKER:
			predictions["strengths"].append("Devastating first strike")
			predictions["strengths"].append("Speed advantage")
			predictions["weaknesses"].append("Low durability")
		Archetype.JUGGERNAUT:
			predictions["strengths"].append("Extreme durability")
			predictions["strengths"].append("Sustained combat")
			predictions["weaknesses"].append("Slow and predictable")
		Archetype.INCOMPLETE:
			predictions["weaknesses"].append("Design incomplete")

	return predictions

## Calculate win chance against enemy type
func calculate_win_chance(enemy_type: String) -> int:
	# Simplified win chance calculation
	var player_power = (offense + defense + speed + durability) / 4.0

	var enemy_power = 0.0
	match enemy_type:
		"Scout":
			enemy_power = 30.0  # Weak
		"Raider":
			enemy_power = 50.0  # Medium
		"Dreadnought":
			enemy_power = 80.0  # Strong

	var power_diff = player_power - enemy_power
	var win_chance = 50 + (power_diff * 1.5)  # ±1.5% per power point

	return int(clamp(win_chance, 5, 95))  # Never 0% or 100%

## Count rooms of specific type
func _count_rooms_of_type(room_type: RoomData.RoomType) -> int:
	if not ship_data:
		return 0

	# Use ShipData's built-in method
	return ship_data.count_room_type(room_type)

## Count rooms of specific category
func _count_rooms_of_category(category: ComponentCategory.Category) -> int:
	if not ship_data:
		return 0

	var count = 0
	# Use room_instances if available (counts room instances, not tiles)
	if not ship_data.room_instances.is_empty():
		for room_id in ship_data.room_instances:
			var room_data = ship_data.room_instances[room_id]
			var room_type = room_data["type"]
			if room_type != RoomData.RoomType.EMPTY and RoomData.get_category(room_type) == category:
				count += 1
	else:
		# Fallback: iterate through grid
		for y in range(ship_data.grid.size()):
			for x in range(ship_data.grid[y].size()):
				var room_type = ship_data.grid[y][x]
				if room_type != RoomData.RoomType.EMPTY and RoomData.get_category(room_type) == category:
					count += 1
	return count

## Count powered rooms
func _count_powered_rooms() -> int:
	if not ship_data:
		return 0

	var count = 0
	# Use room_instances if available (counts room instances, not tiles)
	if not ship_data.room_instances.is_empty():
		for room_id in ship_data.room_instances:
			var room_data = ship_data.room_instances[room_id]
			var room_type = room_data["type"]
			if room_type != RoomData.RoomType.EMPTY:
				# Check if any tile of this room is powered
				var is_powered = false
				for tile_pos in room_data["tiles"]:
					if ship_data.is_room_powered(tile_pos.x, tile_pos.y):
						is_powered = true
						break
				if is_powered:
					count += 1
	else:
		# Fallback: iterate through grid
		for y in range(ship_data.grid.size()):
			for x in range(ship_data.grid[y].size()):
				if ship_data.is_room_powered(x, y):
					var room_type = ship_data.grid[y][x]
					if room_type != RoomData.RoomType.EMPTY:
						count += 1
	return count

## Update radar chart
func _update_radar_chart():
	if radar_chart and radar_chart.has_method("update_stats"):
		radar_chart.update_stats(offense / 100.0, defense / 100.0, speed / 100.0, durability / 100.0, efficiency / 100.0)

	# Update chart color based on archetype
	if radar_chart and radar_chart.has_method("set_chart_color"):
		var color = ARCHETYPE_COLORS.get(current_archetype, Color.GRAY)
		radar_chart.set_chart_color(color)

## Update stat bars with smooth animation
func _update_stat_bars():
	_update_bar(offense_bar, offense_percent, offense)
	_update_bar(defense_bar, defense_percent, defense)
	_update_bar(speed_bar, speed_percent, speed)
	_update_bar(durability_bar, durability_percent, durability)
	_update_bar(efficiency_bar, efficiency_percent, efficiency)

## Update single bar
func _update_bar(bar: ProgressBar, label: Label, value: float):
	if not bar or not label:
		return

	# Animate bar value
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(bar, "value", value, 0.2)

	# Update percentage label
	label.text = "%d%%" % int(value)

## Update archetype label
func _update_archetype_label():
	if not archetype_label:
		return

	var archetype_name = _get_archetype_name(current_archetype)
	archetype_label.text = "Archetype: " + archetype_name

	# Update color
	var color = ARCHETYPE_COLORS.get(current_archetype, Color.GRAY)
	archetype_label.add_theme_color_override("font_color", color)

	# Pulse animation on archetype change
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(archetype_label, "scale", Vector2(1.1, 1.1), 0.15)
	tween.tween_property(archetype_label, "scale", Vector2(1.0, 1.0), 0.15)

## Get archetype name string
func _get_archetype_name(archetype: Archetype) -> String:
	match archetype:
		Archetype.INCOMPLETE: return "INCOMPLETE"
		Archetype.GLASS_CANNON: return "GLASS CANNON"
		Archetype.TURTLE: return "TURTLE"
		Archetype.SPEEDSTER: return "SPEEDSTER"
		Archetype.BALANCED: return "BALANCED"
		Archetype.JUGGERNAUT: return "JUGGERNAUT"
		Archetype.ALPHA_STRIKER: return "ALPHA STRIKER"
		Archetype.LAST_STAND: return "LAST STAND"
		Archetype.GUERRILLA: return "GUERRILLA"
		_: return "UNKNOWN"

## Update warnings list
func _update_warnings():
	if not warnings_list:
		return

	# Clear existing warnings
	for child in warnings_list.get_children():
		child.queue_free()

	# Get warnings
	var warnings = analyze_weaknesses()

	# Add warning labels
	for warning in warnings:
		var label = Label.new()
		label.text = "⚠ " + warning
		label.add_theme_color_override("font_color", Color(0.89, 0.63, 0.29))  # Orange
		label.add_theme_font_size_override("font_size", 12)
		warnings_list.add_child(label)

## Update performance list
func _update_performance():
	if not performance_list:
		return

	# Clear existing items
	for child in performance_list.get_children():
		child.queue_free()

	# Get predictions
	var predictions = predict_performance()

	# Add strengths
	for strength in predictions["strengths"]:
		var label = Label.new()
		label.text = "✓ " + strength
		label.add_theme_color_override("font_color", Color(0.29, 0.89, 0.29))  # Green
		label.add_theme_font_size_override("font_size", 12)
		performance_list.add_child(label)

	# Add weaknesses
	for weakness in predictions["weaknesses"]:
		var label = Label.new()
		label.text = "✗ " + weakness
		label.add_theme_color_override("font_color", Color(0.89, 0.29, 0.29))  # Red
		label.add_theme_font_size_override("font_size", 12)
		performance_list.add_child(label)

## Update win chances list
func _update_win_chances():
	if not win_chances_list:
		return

	# Clear existing items
	for child in win_chances_list.get_children():
		child.queue_free()

	# Only show if ship has weapons and reactors
	if weapon_count == 0 or reactor_count == 0:
		var label = Label.new()
		label.text = "Need weapons and reactor for predictions"
		label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		label.add_theme_font_size_override("font_size", 12)
		win_chances_list.add_child(label)
		return

	# Calculate and display win chances
	var enemies = ["Scout", "Raider", "Dreadnought"]
	for enemy in enemies:
		var win_chance = calculate_win_chance(enemy)
		var label = Label.new()
		label.text = "vs %s: %d%% win chance" % [enemy, win_chance]

		# Color based on win chance
		if win_chance >= 70:
			label.add_theme_color_override("font_color", Color(0.29, 0.89, 0.29))  # Green
		elif win_chance >= 40:
			label.add_theme_color_override("font_color", Color(0.89, 0.83, 0.29))  # Yellow
		else:
			label.add_theme_color_override("font_color", Color(0.89, 0.29, 0.29))  # Red

		label.add_theme_font_size_override("font_size", 12)
		win_chances_list.add_child(label)

## Reset to empty state
func _reset_to_empty():
	offense = 0.0
	defense = 0.0
	speed = 0.0
	durability = 0.0
	efficiency = 100.0
	current_archetype = Archetype.INCOMPLETE

	weapon_count = 0
	shield_count = 0
	engine_count = 0
	armor_count = 0
	reactor_count = 0
	bridge_count = 0
	total_rooms = 0
	powered_rooms = 0

	_update_radar_chart()
	_update_stat_bars()
	_update_archetype_label()
	_update_warnings()
	_update_performance()
	_update_win_chances()
