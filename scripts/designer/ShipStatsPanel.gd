extends Panel
class_name ShipStatsPanel

## Panel displaying ship statistics: Offense, Defense, Thrust (Phase 10.9)

## Offense elements
@onready var offense_label: Label = $VBoxContainer/OffenseRow/OffenseHeader/OffenseLabel
@onready var offense_rating: Label = $VBoxContainer/OffenseRow/OffenseHeader/OffenseRating
@onready var offense_bar: ProgressBar = $VBoxContainer/OffenseRow/OffenseBar
@onready var offense_detail: Label = $VBoxContainer/OffenseRow/OffenseDetail

## Defense elements
@onready var defense_label: Label = $VBoxContainer/DefenseRow/DefenseHeader/DefenseLabel
@onready var defense_rating: Label = $VBoxContainer/DefenseRow/DefenseHeader/DefenseRating
@onready var defense_bar: ProgressBar = $VBoxContainer/DefenseRow/DefenseBar
@onready var defense_detail: Label = $VBoxContainer/DefenseRow/DefenseDetail

## Thrust elements
@onready var thrust_label: Label = $VBoxContainer/ThrustRow/ThrustHeader/ThrustLabel
@onready var thrust_rating: Label = $VBoxContainer/ThrustRow/ThrustHeader/ThrustRating
@onready var thrust_bar: ProgressBar = $VBoxContainer/ThrustRow/ThrustBar
@onready var thrust_detail: Label = $VBoxContainer/ThrustRow/ThrustDetail

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

	# Update offense
	_update_offense(offense_data)

	# Update defense
	_update_defense(defense_data)

	# Update thrust
	_update_thrust(thrust_data)

## Update offense display
func _update_offense(data: Dictionary):
	var damage = data["damage"]
	var weapons = data["weapons"]
	var synergy_bonus = data["synergy_bonus"]
	var rating = data["rating"]

	# Update labels
	offense_label.text = " OFFENSE: %d" % damage
	offense_rating.text = "(%d)" % rating

	# Update bar
	offense_bar.value = rating
	_update_bar_style(offense_bar, "offense", rating)

	# Update detail
	if synergy_bonus > 0:
		offense_detail.text = "  %d weapon%s, %d dmg + %d synergy" % [
			weapons,
			"s" if weapons != 1 else "",
			damage - synergy_bonus,
			synergy_bonus
		]
	else:
		offense_detail.text = "  %d weapon%s, %d damage" % [
			weapons,
			"s" if weapons != 1 else "",
			damage
		]

	# Color rating based on value
	var rating_color = ShipStats.get_rating_color(rating)
	offense_rating.add_theme_color_override("font_color", rating_color)

## Update defense display
func _update_defense(data: Dictionary):
	var hp = data["hp"]
	var shields = data["shields"]
	var max_absorption = data["max_absorption"]
	var synergy_bonus = data["synergy_bonus"]
	var rating = data["rating"]

	# Update labels
	defense_label.text = " DEFENSE: %d" % hp
	defense_rating.text = "(%d)" % rating

	# Update bar
	defense_bar.value = rating
	_update_bar_style(defense_bar, "defense", rating)

	# Update detail
	if shields > 0:
		if synergy_bonus > 0:
			defense_detail.text = "  %d HP, %d shield%s (%d absorb + %d)" % [
				hp,
				shields,
				"s" if shields != 1 else "",
				max_absorption - synergy_bonus,
				synergy_bonus
			]
		else:
			defense_detail.text = "  %d HP, %d shield%s (%d absorb)" % [
				hp,
				shields,
				"s" if shields != 1 else "",
				max_absorption
			]
	else:
		defense_detail.text = "  %d HP, no shields" % hp

	# Color rating based on value
	var rating_color = ShipStats.get_rating_color(rating)
	defense_rating.add_theme_color_override("font_color", rating_color)

## Update thrust display
func _update_thrust(data: Dictionary):
	var initiative = data["initiative"]
	var engines = data["engines"]
	var synergy_bonus = data["synergy_bonus"]
	var hull_bonus = data["hull_bonus"]
	var rating = data["rating"]

	# Update labels
	thrust_label.text = " THRUST: %d" % initiative
	thrust_rating.text = "(%d)" % rating

	# Update bar
	thrust_bar.value = rating
	_update_bar_style(thrust_bar, "thrust", rating)

	# Update detail with bonuses
	var bonus_parts = []
	if synergy_bonus > 0:
		bonus_parts.append("+%d synergy" % synergy_bonus)
	if hull_bonus > 0:
		bonus_parts.append("+%d hull" % hull_bonus)

	if bonus_parts.is_empty():
		thrust_detail.text = "  %d engine%s, %d initiative" % [
			engines,
			"s" if engines != 1 else "",
			initiative
		]
	else:
		thrust_detail.text = "  %d engine%s, %d (%s)" % [
			engines,
			"s" if engines != 1 else "",
			initiative,
			", ".join(bonus_parts)
		]

	# Color rating based on value
	var rating_color = ShipStats.get_rating_color(rating)
	thrust_rating.add_theme_color_override("font_color", rating_color)

## Update progress bar style with stat-specific color
func _update_bar_style(bar: ProgressBar, stat_type: String, rating: int):
	var stat_color = ShipStats.get_stat_color(stat_type)

	# Create custom style for filled portion
	var style = StyleBoxFlat.new()
	style.bg_color = stat_color

	# Adjust alpha based on rating for visual feedback
	if rating < 30:
		style.bg_color.a = 0.6  # Dimmer for low ratings
	elif rating < 60:
		style.bg_color.a = 0.8  # Medium for average ratings
	else:
		style.bg_color.a = 1.0  # Full brightness for high ratings

	bar.add_theme_stylebox_override("fill", style)
