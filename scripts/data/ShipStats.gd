class_name ShipStats

## Utility class for calculating ship statistics (Phase 10.9)
## Quantifies offense, defense, and thrust for display in Designer and Combat

## Calculate offense statistics from ship data
## Returns: {damage: int, weapons: int, synergy_bonus: int, rating: int}
static func calculate_offense(ship: ShipData) -> Dictionary:
	var weapons = 0
	var base_damage = 0

	# Sum damage from all powered weapons (using individual stats)
	var synergies = ship.calculate_synergy_bonuses()
	var room_synergies = synergies["room_synergies"]

	var weapons_with_synergy = 0
	var synergy_bonus_damage = 0

	for y in range(ship.grid.size()):
		for x in range(ship.grid[y].size()):
			var room_type = ship.grid[y][x]
			var category = RoomData.get_category(room_type)

			# Check if this is a weapon and it's powered
			if category == ComponentCategory.Category.WEAPONS and ship.is_room_powered(x, y):
				weapons += 1

				# Get this weapon's individual damage stat
				var weapon_stats = RoomData.get_stats(room_type)
				var weapon_damage = weapon_stats.get("damage", 10)  # Default to 10 if missing
				base_damage += weapon_damage

				# Check if this weapon has fire rate synergy
				var pos = Vector2i(x, y)
				if pos in room_synergies:
					if RoomData.SynergyType.FIRE_RATE in room_synergies[pos]:
						weapons_with_synergy += 1
						# Synergy adds bonus percentage of this weapon's damage
						synergy_bonus_damage += int(weapon_damage * BalanceConstants.FIRE_RATE_SYNERGY_BONUS)

	var total_damage = base_damage + synergy_bonus_damage

	# Calculate rating (0-100 scale)
	# 0 weapons = 0, 2 weapons = 40, 3 weapons = 60, 5+ weapons = 100
	var rating = get_offense_rating(total_damage, weapons)

	return {
		"damage": total_damage,
		"weapons": weapons,
		"synergy_bonus": synergy_bonus_damage,
		"synergized_weapons": weapons_with_synergy,
		"rating": rating
	}

## Calculate defense statistics from ship data
## hull_bonus: additional HP from hull type (Battleship +20)
## Returns: {hp: int, max_absorption: int, shields: int, armor: int, synergy_bonus: int, rating: int}
static func calculate_defense(ship: ShipData, hull_bonus: int = 0) -> Dictionary:
	var shields = 0
	var armor = 0
	var base_absorption = 0
	var armor_hp_bonus = 0

	# Sum absorption/HP from all powered shields and armor (using individual stats)
	var synergies = ship.calculate_synergy_bonuses()
	var room_synergies = synergies["room_synergies"]

	var shields_with_synergy = 0
	var synergy_bonus = 0

	for y in range(ship.grid.size()):
		for x in range(ship.grid[y].size()):
			var room_type = ship.grid[y][x]
			var category = RoomData.get_category(room_type)

			# Check if this is a shield and it's powered
			if category == ComponentCategory.Category.DEFENSE and ship.is_room_powered(x, y):
				var defense_stats = RoomData.get_stats(room_type)

				# Shields have absorption stat
				if defense_stats.has("absorption"):
					shields += 1
					var shield_absorption = defense_stats.get("absorption", 15)  # Default to 15 if missing
					base_absorption += shield_absorption

					# Check if this shield has capacity synergy
					var pos = Vector2i(x, y)
					if pos in room_synergies:
						if RoomData.SynergyType.SHIELD_CAPACITY in room_synergies[pos]:
							shields_with_synergy += 1
							# Synergy adds bonus percentage of this shield's absorption
							synergy_bonus += int(shield_absorption * BalanceConstants.SHIELD_CAPACITY_SYNERGY_BONUS)

				# Armor has hp_bonus stat
				if defense_stats.has("hp_bonus"):
					armor += 1
					armor_hp_bonus += defense_stats.get("hp_bonus", 20)  # Default to 20 if missing

	var max_absorption = base_absorption + synergy_bonus

	# Calculate total HP: base ship HP + armor bonuses + hull type bonus
	var total_hp = ship.max_hp + armor_hp_bonus + hull_bonus

	# Calculate rating (0-100 scale)
	# 40 HP + 0 shields = 30, 80 HP + 2 shields = 60, 120+ HP + 4 shields = 100
	var rating = get_defense_rating(total_hp, max_absorption)

	return {
		"hp": total_hp,
		"max_absorption": max_absorption,
		"shields": shields,
		"armor": armor,
		"synergy_bonus": synergy_bonus,
		"synergized_shields": shields_with_synergy,
		"rating": rating
	}

## Calculate thrust/initiative statistics from ship data
## hull_bonus: additional initiative from hull type (Frigate +2)
## Returns: {initiative: int, engines: int, synergy_bonus: int, rating: int}
static func calculate_thrust(ship: ShipData, hull_bonus: int = 0) -> Dictionary:
	var engines = 0
	var base_thrust = 0

	# Sum thrust from all powered engines (using individual stats)
	var synergies = ship.calculate_synergy_bonuses()
	var synergy_bonus = synergies["counts"][RoomData.SynergyType.INITIATIVE]

	for y in range(ship.grid.size()):
		for x in range(ship.grid[y].size()):
			var room_type = ship.grid[y][x]
			var category = RoomData.get_category(room_type)

			# Check if this is an engine and it's powered
			if category == ComponentCategory.Category.PROPULSION and ship.is_room_powered(x, y):
				var engine_stats = RoomData.get_stats(room_type)

				# Engines have thrust stat (initiative contribution)
				if engine_stats.has("thrust"):
					engines += 1
					var engine_thrust = engine_stats.get("thrust", 10)  # Default to 10 if missing
					base_thrust += engine_thrust

	var total_initiative = base_thrust + synergy_bonus + hull_bonus

	# Calculate rating (0-100 scale)
	# 0 engines = 0, 1 engine = 33, 2 engines = 66, 3+ engines = 100
	var rating = get_thrust_rating(total_initiative)

	return {
		"initiative": total_initiative,
		"engines": engines,
		"synergy_bonus": synergy_bonus,
		"hull_bonus": hull_bonus,
		"rating": rating
	}

## Convert offense damage to 0-100 rating
static func get_offense_rating(damage: int, _weapons: int) -> int:
	# Rating curve:
	# 0 dmg = 0, 20 dmg = 40, 30 dmg = 60, 50+ dmg = 100
	if damage == 0:
		return 0
	elif damage >= BalanceConstants.OFFENSE_RATING_MAX_DAMAGE:
		return 100
	else:
		# Linear interpolation: rating = damage * 2 (clamped to 100)
		return mini(int(damage * 2.0), 100)

## Convert defense HP + shields to 0-100 rating
static func get_defense_rating(hp: int, shield_absorption: int) -> int:
	# Combined defense value: HP + (shield absorption * multiplier) since shields regenerate
	var defense_value = hp + (shield_absorption * BalanceConstants.SHIELD_VALUE_MULTIPLIER)

	# Rating curve:
	# 40 = 20, 80 = 40, 120 = 60, 160 = 80, 200+ = 100
	if defense_value == 0:
		return 0
	elif defense_value >= BalanceConstants.DEFENSE_RATING_MAX_VALUE:
		return 100
	else:
		# Linear interpolation: rating = defense_value / 2
		return int(defense_value * 0.5)

## Convert initiative to 0-100 rating
static func get_thrust_rating(initiative: int) -> int:
	# Rating curve:
	# 0 = 0, 1 = 25, 2 = 50, 3 = 75, 4+ = 100
	if initiative == 0:
		return 0
	elif initiative >= BalanceConstants.THRUST_RATING_MAX_INITIATIVE:
		return 100
	else:
		# Linear: rating = initiative * 25
		return initiative * 25

## Get color for rating value (0-100)
static func get_rating_color(rating: int) -> Color:
	if rating >= 60:
		return Color(0.290, 0.886, 0.290)  # Green #4AE24A
	elif rating >= 30:
		return Color(0.886, 0.831, 0.290)  # Yellow #E2D44A
	else:
		return Color(0.886, 0.290, 0.290)  # Red #E24A4A

## Get stat-specific color (for bars)
static func get_stat_color(stat_type: String) -> Color:
	match stat_type:
		"offense":
			return Color(0.886, 0.290, 0.290)  # Red #E24A4A (weapon color)
		"defense":
			return Color(0.290, 0.886, 0.886)  # Cyan #4AE2E2 (shield color)
		"thrust":
			return Color(0.886, 0.627, 0.290)  # Orange #E2A04A (engine color)
		_:
			return Color(1, 1, 1)  # White fallback
