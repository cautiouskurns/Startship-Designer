class_name ShipStats

## Utility class for calculating ship statistics (Phase 10.9)
## Quantifies offense, defense, and thrust for display in Designer and Combat

## Calculate offense statistics from ship data
## Returns: {damage: int, weapons: int, synergy_bonus: int, rating: int}
static func calculate_offense(ship: ShipData) -> Dictionary:
	var weapons = ship.count_powered_room_type(RoomData.RoomType.WEAPON)
	var base_damage = weapons * BalanceConstants.DAMAGE_PER_WEAPON

	# Calculate synergy bonuses (matching Combat.gd formula)
	var synergies = ship.calculate_synergy_bonuses()
	var room_synergies = synergies["room_synergies"]

	var weapons_with_synergy = 0
	for y in range(ship.grid.size()):
		for x in range(ship.grid[y].size()):
			var room_type = ship.grid[y][x]
			if room_type == RoomData.RoomType.WEAPON and ship.is_room_powered(x, y):
				var pos = Vector2i(x, y)
				if pos in room_synergies:
					if RoomData.SynergyType.FIRE_RATE in room_synergies[pos]:
						weapons_with_synergy += 1

	var synergy_bonus = int(weapons_with_synergy * BalanceConstants.DAMAGE_PER_WEAPON * BalanceConstants.FIRE_RATE_SYNERGY_BONUS)
	var total_damage = base_damage + synergy_bonus

	# Calculate rating (0-100 scale)
	# 0 weapons = 0, 2 weapons = 40, 3 weapons = 60, 5+ weapons = 100
	var rating = get_offense_rating(total_damage, weapons)

	return {
		"damage": total_damage,
		"weapons": weapons,
		"synergy_bonus": synergy_bonus,
		"synergized_weapons": weapons_with_synergy,
		"rating": rating
	}

## Calculate defense statistics from ship data
## hull_bonus: additional HP from hull type (Battleship +20)
## Returns: {hp: int, max_absorption: int, shields: int, armor: int, synergy_bonus: int, rating: int}
static func calculate_defense(ship: ShipData, hull_bonus: int = 0) -> Dictionary:
	var shields = ship.count_powered_room_type(RoomData.RoomType.SHIELD)
	var armor = ship.count_room_type(RoomData.RoomType.ARMOR)
	var hp = ship.max_hp  # Already includes armor bonus
	var total_hp = hp + hull_bonus

	# Calculate shield absorption (matching Combat.gd formula)
	var base_absorption = shields * BalanceConstants.SHIELD_ABSORPTION_PER_SHIELD

	var synergies = ship.calculate_synergy_bonuses()
	var room_synergies = synergies["room_synergies"]

	var shields_with_synergy = 0
	for y in range(ship.grid.size()):
		for x in range(ship.grid[y].size()):
			var room_type = ship.grid[y][x]
			if room_type == RoomData.RoomType.SHIELD and ship.is_room_powered(x, y):
				var pos = Vector2i(x, y)
				if pos in room_synergies:
					if RoomData.SynergyType.SHIELD_CAPACITY in room_synergies[pos]:
						shields_with_synergy += 1

	var synergy_bonus = int(shields_with_synergy * BalanceConstants.SHIELD_ABSORPTION_PER_SHIELD * BalanceConstants.SHIELD_CAPACITY_SYNERGY_BONUS)
	var max_absorption = base_absorption + synergy_bonus

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
	var engines = ship.count_powered_room_type(RoomData.RoomType.ENGINE)

	# Calculate synergy bonuses (Engine+Engine gives +1 initiative each)
	var synergies = ship.calculate_synergy_bonuses()
	var synergy_bonus = synergies["counts"][RoomData.SynergyType.INITIATIVE]

	var total_initiative = engines + synergy_bonus + hull_bonus

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
