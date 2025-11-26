extends Panel
class_name ShipStatsPanel

## Panel displaying ship statistics: Offense, Defense, Mobility, Power (Updated to match modern UI)

## Stat value labels (simplified - just values)
@onready var offense_value: Label = $VBoxContainer/ContentMargin/ContentContainer/OffenseRow/OffenseHeader/OffenseValue
@onready var defense_value: Label = $VBoxContainer/ContentMargin/ContentContainer/DefenseRow/DefenseHeader/DefenseValue
@onready var mobility_value: Label = $VBoxContainer/ContentMargin/ContentContainer/MobilityRow/MobilityHeader/MobilityValue
@onready var power_value: Label = $VBoxContainer/ContentMargin/ContentContainer/PowerRow/PowerHeader/PowerValue

## Progress bars
@onready var offense_bar: ProgressBar = $VBoxContainer/ContentMargin/ContentContainer/OffenseRow/OffenseBar
@onready var defense_bar: ProgressBar = $VBoxContainer/ContentMargin/ContentContainer/DefenseRow/DefenseBar
@onready var mobility_bar: ProgressBar = $VBoxContainer/ContentMargin/ContentContainer/MobilityRow/MobilityBar
@onready var power_bar: ProgressBar = $VBoxContainer/ContentMargin/ContentContainer/PowerRow/PowerBar

## Update all stats from ship data
## hull_data: dictionary with hull bonus info (optional)
func update_stats(ship: ShipData, hull_data: Dictionary = {}):
	# Extract hull bonuses
	var hp_bonus = 0
	var initiative_bonus = 0

	if not hull_data.is_empty():
		var bonus_type = hull_data.get("bonus_type", "none")
		var bonus_value = hull_data.get("bonus_value", 0)

		if bonus_type == "hull_hp":
			hp_bonus = bonus_value
		elif bonus_type == "initiative":
			initiative_bonus = bonus_value

	# Calculate all stats
	var offense_data = ShipStats.calculate_offense(ship)
	var defense_data = ShipStats.calculate_defense(ship, hp_bonus)
	var thrust_data = ShipStats.calculate_thrust(ship, initiative_bonus)

	# Update display (simple values only)
	_update_offense(offense_data)
	_update_defense(defense_data)
	_update_mobility(thrust_data)
	_update_power(ship)

## Update offense display (simplified)
func _update_offense(data: Dictionary):
	if not offense_value:
		return  # Node not set up yet
	var damage = data["damage"]
	offense_value.text = str(damage)
	offense_value.add_theme_color_override("font_color", Color.WHITE)

	# Update progress bar (max 100 for display purposes)
	if offense_bar:
		offense_bar.value = min(damage, 100)

## Update defense display (simplified)
func _update_defense(data: Dictionary):
	if not defense_value:
		return  # Node not set up yet
	var hp = data["hp"]
	defense_value.text = str(hp)
	defense_value.add_theme_color_override("font_color", Color.WHITE)

	# Update progress bar (max 200 for display purposes)
	if defense_bar:
		defense_bar.max_value = 200
		defense_bar.value = min(hp, 200)

## Update mobility display (renamed from thrust, simplified)
func _update_mobility(data: Dictionary):
	if not mobility_value:
		return  # Node not set up yet
	var initiative = data["initiative"]
	mobility_value.text = str(initiative)
	mobility_value.add_theme_color_override("font_color", Color.WHITE)

	# Update progress bar (max 20 for display purposes)
	if mobility_bar:
		mobility_bar.max_value = 20
		mobility_bar.value = min(initiative, 20)

## Update power display (count of powered rooms)
func _update_power(ship: ShipData):
	if not power_value:
		return  # Node not set up yet
	# Count total powered rooms (excluding empty)
	var powered_count = 0
	powered_count += ship.count_powered_room_type(RoomData.RoomType.BRIDGE)
	powered_count += ship.count_powered_room_type(RoomData.RoomType.WEAPON)
	powered_count += ship.count_powered_room_type(RoomData.RoomType.SHIELD)
	powered_count += ship.count_powered_room_type(RoomData.RoomType.ENGINE)
	powered_count += ship.count_powered_room_type(RoomData.RoomType.REACTOR)
	powered_count += ship.count_powered_room_type(RoomData.RoomType.RELAY)

	power_value.text = str(powered_count)
	power_value.add_theme_color_override("font_color", Color.WHITE)

	# Update progress bar (max 30 for display purposes - typical ship size)
	if power_bar:
		power_bar.max_value = 30
		power_bar.value = min(powered_count, 30)
