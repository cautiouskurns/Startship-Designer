extends Node

## Sector Bonus System (Feature 4: Sector Bonuses & Penalties)
## Calculates active bonuses/penalties from campaign sector states
## Applies to budget, costs, combat stats, and power

## Get all active bonuses and penalties from campaign sectors
## Returns dictionary with all modifier values
func get_active_bonuses() -> Dictionary:
	var bonuses = {
		"budget_modifier": 0,        # Added/subtracted from max budget
		"hp_modifier": 1.0,          # Multiplier for max HP
		"damage_modifier": 1.0,      # Multiplier for weapon damage
		"shield_modifier": 1.0,      # Multiplier for shield absorption
		"power_modifier": 0,         # Added/subtracted from reactor power output
		"weapon_cost_modifier": 0,   # Added/subtracted from weapon component costs
		"shield_cost_modifier": 0,   # Added/subtracted from shield component costs
		"all_stats_modifier": 1.0    # Multiplier for all stats (Colony morale)
	}

	# Only calculate bonuses if campaign is active
	if not CampaignState or not CampaignState.campaign_active:
		return bonuses

	# Check each sector for bonuses/penalties
	for sector_id in CampaignState.sectors.keys():
		# Skip Command sector (no bonuses/penalties)
		if sector_id == CampaignState.SectorID.COMMAND:
			continue

		var sector = CampaignState.get_sector(sector_id)
		var sector_def = CampaignState.get_sector_definition(sector_id)

		if not sector or not sector_def:
			continue

		# Apply bonuses for secure sectors (threat 0-1)
		if sector.is_secure():
			_apply_sector_effect(bonuses, sector_def.get("bonus", {}))
		# Apply penalties for lost sectors (threat 4)
		elif sector.is_lost:
			_apply_sector_effect(bonuses, sector_def.get("penalty", {}))
		# Threat 2-3: neutral, no bonuses or penalties

	return bonuses

## Apply a sector's bonus or penalty effect to the bonuses dictionary
func _apply_sector_effect(bonuses: Dictionary, effect: Dictionary):
	if effect.is_empty():
		return

	var effect_type = effect.get("type", "none")
	var effect_value = effect.get("value", 0)

	match effect_type:
		"budget":
			# Shipyard: ±budget
			bonuses["budget_modifier"] += effect_value

		"hp":
			# Medical: HP multiplier
			bonuses["hp_modifier"] *= effect_value

		"morale":
			# Colony: All stats multiplier
			bonuses["all_stats_modifier"] *= effect_value

		"power":
			# Power Station: ±reactor power output
			bonuses["power_modifier"] += effect_value

		"shields":
			# Defense Grid: Shield multiplier + cost modifier
			bonuses["shield_modifier"] *= effect_value
			# Apply cost modifier (secure: -1, lost: +1)
			if effect_value > 1.0:  # Bonus (secure)
				bonuses["shield_cost_modifier"] -= 1
			elif effect_value < 1.0:  # Penalty (lost)
				bonuses["shield_cost_modifier"] += 1

		"damage":
			# Weapons Depot: Damage multiplier + cost modifier
			bonuses["damage_modifier"] *= effect_value
			# Apply cost modifier (secure: -1, lost: +1)
			if effect_value > 1.0:  # Bonus (secure)
				bonuses["weapon_cost_modifier"] -= 1
			elif effect_value < 1.0:  # Penalty (lost)
				bonuses["weapon_cost_modifier"] += 1

## Get budget modifier only (shortcut for Ship Designer)
func get_budget_modifier() -> int:
	var bonuses = get_active_bonuses()
	return bonuses["budget_modifier"]

## Get cost modifier for a specific room type
func get_room_cost_modifier(room_type: RoomData.RoomType) -> int:
	var bonuses = get_active_bonuses()

	# Check if room is a weapon type
	var category = RoomData.get_category(room_type)
	if category == ComponentCategory.Category.WEAPONS:
		return bonuses["weapon_cost_modifier"]
	elif category == ComponentCategory.Category.DEFENSE:
		# Only apply shield cost modifier to shield rooms
		if _is_shield_type(room_type):
			return bonuses["shield_cost_modifier"]

	return 0

## Check if room type is a shield
func _is_shield_type(room_type: RoomData.RoomType) -> bool:
	return room_type in [
		RoomData.RoomType.SHIELD,
		RoomData.RoomType.STANDARD_SHIELD,
		RoomData.RoomType.LIGHT_SHIELD,
		RoomData.RoomType.HEAVY_SHIELD,
		RoomData.RoomType.FAST_RECHARGE_SHIELD,
		RoomData.RoomType.HARDENED_SHIELD
	]

## Get formatted description of all active bonuses/penalties
## Returns array of strings for UI display
func get_active_bonus_descriptions() -> Array[String]:
	var descriptions: Array[String] = []

	if not CampaignState or not CampaignState.campaign_active:
		return descriptions

	# Check each sector
	for sector_id in CampaignState.sectors.keys():
		if sector_id == CampaignState.SectorID.COMMAND:
			continue

		var sector = CampaignState.get_sector(sector_id)
		var sector_def = CampaignState.get_sector_definition(sector_id)

		if not sector or not sector_def:
			continue

		var sector_name = sector_def.get("name", "Unknown")
		var icon = sector_def.get("icon", "")

		# Add bonus descriptions for secure sectors
		if sector.is_secure():
			var bonus = sector_def.get("bonus", {})
			var desc = bonus.get("description", "")
			if not desc.is_empty():
				descriptions.append("[color=#4AE24A]%s %s:[/color] %s" % [icon, sector_name, desc])

		# Add penalty descriptions for lost sectors
		elif sector.is_lost:
			var penalty = sector_def.get("penalty", {})
			var desc = penalty.get("description", "")
			if not desc.is_empty():
				descriptions.append("[color=#E24A4A]%s %s LOST:[/color] %s" % [icon, sector_name, desc])

	return descriptions

## Print debug info about active bonuses (for testing)
func print_debug_bonuses():
	var bonuses = get_active_bonuses()
	print("=== Active Sector Bonuses/Penalties ===")
	print("Budget Modifier: %+d BP" % bonuses["budget_modifier"])
	print("HP Modifier: ×%.1f" % bonuses["hp_modifier"])
	print("Damage Modifier: ×%.1f" % bonuses["damage_modifier"])
	print("Shield Modifier: ×%.1f" % bonuses["shield_modifier"])
	print("Power Modifier: %+d" % bonuses["power_modifier"])
	print("Weapon Cost Modifier: %+d BP" % bonuses["weapon_cost_modifier"])
	print("Shield Cost Modifier: %+d BP" % bonuses["shield_cost_modifier"])
	print("All Stats Modifier: ×%.1f" % bonuses["all_stats_modifier"])
	print("=======================================")
