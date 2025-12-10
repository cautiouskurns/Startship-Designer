class_name SuggestionGenerator extends RefCounted

## Analyzes battle performance and generates contextual improvement suggestions

## Suggestion priority levels
enum Priority {
	CRITICAL = 1,
	HIGH = 2,
	MEDIUM = 3,
	LOW = 4
}

## Generate improvement suggestions based on performance metrics
func generate_suggestions(metrics: Dictionary, player_stats: Dictionary, player_won: bool) -> Array[Dictionary]:
	var suggestions: Array[Dictionary] = []

	# Analyze different aspects of performance
	_analyze_damage_output(suggestions, metrics, player_stats, player_won)
	_analyze_defense(suggestions, metrics, player_stats, player_won)
	_analyze_power_efficiency(suggestions, metrics, player_stats)
	_analyze_room_survival(suggestions, metrics, player_stats, player_won)
	_analyze_initiative(suggestions, player_stats, player_won)

	# Sort by priority
	suggestions.sort_custom(func(a, b): return a["priority"] < b["priority"])

	# Return top 5 suggestions
	return suggestions.slice(0, 5)

## Analyze damage output performance
func _analyze_damage_output(suggestions: Array, metrics: Dictionary, stats: Dictionary, won: bool):
	var avg_damage = metrics.get("avg_damage_per_turn", 0.0)
	var weapon_efficiency = metrics.get("weapon_efficiency", 0.0)
	var powered_weapons = stats.get("powered_weapons", 0)
	var total_weapons = stats.get("total_weapons", 0)

	# Low damage output
	if avg_damage < 20 and not won:
		suggestions.append({
			"title": "Insufficient Firepower",
			"description": "Your damage output was too low to defeat the enemy efficiently. Consider adding more weapons or ensuring existing weapons are powered.",
			"priority": Priority.CRITICAL
		})
	elif powered_weapons < total_weapons and powered_weapons < 3:
		suggestions.append({
			"title": "Unpowered Weapons Detected",
			"description": "You have %d unpowered weapon(s). Add more reactors or reposition weapons closer to existing reactors to increase damage output." % (total_weapons - powered_weapons),
			"priority": Priority.HIGH
		})
	elif weapon_efficiency < 60 and not won:
		suggestions.append({
			"title": "Low Weapon Efficiency",
			"description": "Your weapons aren't performing as expected (%.0f%% efficiency). Enemy shields may be absorbing too much damage - consider overwhelming their defenses with more weapons." % weapon_efficiency,
			"priority": Priority.MEDIUM
		})
	elif powered_weapons >= 5 and won:
		suggestions.append({
			"title": "Excellent Offensive Strategy",
			"description": "Your %d powered weapons provided strong firepower. This offensive approach is working well!" % powered_weapons,
			"priority": Priority.LOW
		})

## Analyze defensive performance
func _analyze_defense(suggestions: Array, metrics: Dictionary, stats: Dictionary, won: bool):
	var damage_taken = metrics.get("total_damage_taken", 0)
	var shield_efficiency = metrics.get("shield_efficiency", 0.0)
	var powered_shields = stats.get("powered_shields", 0)
	var hp_remaining = metrics.get("hp_remaining_pct", 100.0)

	# Shields depleted quickly
	if shield_efficiency < 30 and damage_taken > 50 and not won:
		suggestions.append({
			"title": "Weak Shield Defense",
			"description": "Your shields depleted quickly, allowing heavy hull damage. Add more shield generators or ensure they're properly powered.",
			"priority": Priority.CRITICAL
		})
	elif powered_shields == 0 and damage_taken > 30:
		suggestions.append({
			"title": "No Active Shields",
			"description": "You had no powered shields! Shields are crucial for absorbing enemy fire. Add shield generators adjacent to reactors.",
			"priority": Priority.CRITICAL
		})
	elif hp_remaining < 25 and won:
		suggestions.append({
			"title": "Close Call - Strengthen Defenses",
			"description": "You won, but barely (%.0f%% HP remaining). Consider adding more shields or armor to survive tougher battles." % hp_remaining,
			"priority": Priority.HIGH
		})
	elif shield_efficiency > 70 and won:
		suggestions.append({
			"title": "Excellent Shield Performance",
			"description": "Your shields absorbed most incoming damage (%.0f%% efficiency). Great defensive setup!" % shield_efficiency,
			"priority": Priority.LOW
		})

## Analyze power efficiency
func _analyze_power_efficiency(suggestions: Array, metrics: Dictionary, stats: Dictionary):
	var power_efficiency = metrics.get("power_efficiency", 0.0)
	var powered_rooms = stats.get("total_powered_rooms", 0)
	var total_rooms = stats.get("total_rooms", 1)
	var reactors = stats.get("total_reactors", 0)

	# Low power efficiency
	if power_efficiency < 60:
		var unpowered = total_rooms - powered_rooms
		suggestions.append({
			"title": "Poor Power Distribution",
			"description": "Only %.0f%% of your rooms are powered (%d unpowered). Add more reactors or reposition rooms closer to existing power sources." % [power_efficiency, unpowered],
			"priority": Priority.HIGH
		})
	elif reactors < 2 and total_rooms > 6:
		suggestions.append({
			"title": "Insufficient Reactors",
			"description": "Your ship has only %d reactor(s) for %d rooms. Add more reactors to power your entire ship effectively." % [reactors, total_rooms],
			"priority": Priority.MEDIUM
		})
	elif power_efficiency >= 90:
		suggestions.append({
			"title": "Excellent Power Grid",
			"description": "Nearly all rooms are powered (%.0f%%). Your power distribution is very efficient!" % power_efficiency,
			"priority": Priority.LOW
		})

## Analyze room survival
func _analyze_room_survival(suggestions: Array, metrics: Dictionary, stats: Dictionary, won: bool):
	var rooms_lost = metrics.get("rooms_lost", 0)
	var armor_count = stats.get("total_armor", 0)

	# Many rooms destroyed
	if rooms_lost >= 5 and not won:
		suggestions.append({
			"title": "Heavy Component Damage",
			"description": "You lost %d rooms during battle. This severely weakened your ship. Add more armor plating to increase hull HP and reduce room losses." % rooms_lost,
			"priority": Priority.CRITICAL
		})
	elif rooms_lost >= 3 and won:
		suggestions.append({
			"title": "Significant Room Losses",
			"description": "You lost %d rooms but still won. Adding armor could help you take less damage in future battles." % rooms_lost,
			"priority": Priority.MEDIUM
		})
	elif armor_count == 0 and not won:
		suggestions.append({
			"title": "No Armor Plating",
			"description": "Your ship has no armor! Armor increases hull HP and helps you survive longer. Add armor plating to improve survivability.",
			"priority": Priority.HIGH
		})
	elif rooms_lost <= 1 and won:
		suggestions.append({
			"title": "Minimal Damage Taken",
			"description": "You only lost %d room(s)! Your ship's durability is excellent." % rooms_lost,
			"priority": Priority.LOW
		})

## Analyze initiative and positioning
func _analyze_initiative(suggestions: Array, stats: Dictionary, won: bool):
	var powered_engines = stats.get("powered_engines", 0)
	var total_engines = stats.get("total_engines", 0)

	# Low engine count
	if powered_engines == 0:
		suggestions.append({
			"title": "No Powered Engines",
			"description": "You had no powered engines! Engines determine who shoots first. Add engines to gain initiative advantage.",
			"priority": Priority.HIGH
		})
	elif powered_engines < 2 and not won:
		suggestions.append({
			"title": "Low Initiative",
			"description": "Only %d powered engine(s). The enemy likely shot first each turn. Add more engines to gain the initiative advantage." % powered_engines,
			"priority": Priority.MEDIUM
		})
	elif powered_engines < total_engines:
		suggestions.append({
			"title": "Unpowered Engines",
			"description": "You have %d unpowered engine(s). Ensure all engines are connected to reactors to maximize initiative." % (total_engines - powered_engines),
			"priority": Priority.MEDIUM
		})
	elif powered_engines >= 3 and won:
		suggestions.append({
			"title": "Superior Initiative",
			"description": "Your %d powered engines likely gave you first strike advantage. Excellent positioning!" % powered_engines,
			"priority": Priority.LOW
		})
