class_name BattleStatsCalculator extends RefCounted

## Processes raw battle data into displayable metrics and performance ratings

## Calculate comprehensive ship stats
func calculate_ship_stats(ship: ShipData) -> Dictionary:
	var stats = {}

	# Count room types
	stats["total_weapons"] = _count_rooms_of_type(ship, RoomData.RoomType.WEAPON)
	stats["powered_weapons"] = ship.count_powered_room_type(RoomData.RoomType.WEAPON)
	stats["total_shields"] = _count_rooms_of_type(ship, RoomData.RoomType.SHIELD)
	stats["powered_shields"] = ship.count_powered_room_type(RoomData.RoomType.SHIELD)
	stats["total_engines"] = _count_rooms_of_type(ship, RoomData.RoomType.ENGINE)
	stats["powered_engines"] = ship.count_powered_room_type(RoomData.RoomType.ENGINE)
	stats["total_reactors"] = _count_rooms_of_type(ship, RoomData.RoomType.REACTOR)
	stats["total_armor"] = _count_rooms_of_type(ship, RoomData.RoomType.ARMOR)

	# HP stats
	stats["max_hp"] = ship.max_hp
	stats["current_hp"] = ship.current_hp
	stats["hp_percentage"] = (float(ship.current_hp) / float(ship.max_hp)) * 100.0 if ship.max_hp > 0 else 0.0

	# Total room count
	stats["total_rooms"] = ship.room_instances.size()
	stats["total_powered_rooms"] = _count_powered_rooms(ship)

	# Power efficiency (percentage of rooms that are powered)
	stats["power_efficiency"] = (float(stats["total_powered_rooms"]) / float(stats["total_rooms"])) * 100.0 if stats["total_rooms"] > 0 else 0.0

	# Calculate potential stats
	stats["potential_damage"] = stats["powered_weapons"] * 10
	stats["potential_shield_absorption"] = stats["powered_shields"] * 15
	stats["initiative"] = stats["powered_engines"]

	return stats

## Calculate performance metrics from battle result
func calculate_performance_metrics(result: BattleResult, player_ship: ShipData, enemy_ship: ShipData) -> Dictionary:
	var metrics = {}

	# Get snapshots
	var initial_snapshot = result.get_turn_snapshot(0)
	var final_snapshot = result.get_turn_snapshot(result.total_turns - 1) if result.total_turns > 0 else initial_snapshot

	if not initial_snapshot or not final_snapshot:
		print("WARNING: Missing snapshots for battle analysis")
		return _get_default_metrics()

	# Calculate damage dealt and taken
	var initial_enemy_hp = initial_snapshot.enemy_hull_hp
	var final_enemy_hp = final_snapshot.enemy_hull_hp
	var initial_player_hp = initial_snapshot.player_hull_hp
	var final_player_hp = final_snapshot.player_hull_hp

	metrics["total_damage_dealt"] = max(0, initial_enemy_hp - final_enemy_hp)
	metrics["total_damage_taken"] = max(0, initial_player_hp - final_player_hp)

	# Average damage per turn
	metrics["avg_damage_per_turn"] = float(metrics["total_damage_dealt"]) / float(result.total_turns) if result.total_turns > 0 else 0.0

	# Estimate shield absorption (this is approximate based on weapon count vs actual damage)
	var player_weapon_count = player_ship.count_powered_room_type(RoomData.RoomType.WEAPON)
	var potential_damage = player_weapon_count * 10 * result.total_turns
	metrics["damage_absorbed"] = max(0, potential_damage - metrics["total_damage_dealt"])

	# Shield efficiency (how much damage was absorbed vs taken)
	var total_incoming = metrics["damage_absorbed"] + metrics["total_damage_taken"]
	metrics["shield_efficiency"] = (float(metrics["damage_absorbed"]) / float(total_incoming)) * 100.0 if total_incoming > 0 else 0.0

	# Weapon efficiency (actual damage vs potential)
	metrics["weapon_efficiency"] = (float(metrics["total_damage_dealt"]) / float(potential_damage)) * 100.0 if potential_damage > 0 else 0.0

	# Rooms lost
	var initial_room_count = initial_snapshot.player_active_room_ids.size()
	var final_room_count = final_snapshot.player_active_room_ids.size()
	metrics["rooms_lost"] = max(0, initial_room_count - final_room_count)

	# HP remaining
	metrics["hp_remaining_pct"] = (float(final_player_hp) / float(initial_player_hp)) * 100.0 if initial_player_hp > 0 else 0.0

	# Power efficiency
	var player_stats = calculate_ship_stats(player_ship)
	metrics["power_efficiency"] = player_stats["power_efficiency"]

	# Battle outcome
	metrics["victory"] = result.player_won
	metrics["turns_survived"] = result.total_turns

	print("Battle metrics calculated: ", metrics)
	return metrics

## Count rooms of a specific type
func _count_rooms_of_type(ship: ShipData, room_type: RoomData.RoomType) -> int:
	var count = 0
	for room_id in ship.room_instances:
		var room = ship.room_instances[room_id]
		if room["type"] == room_type:
			count += 1
	return count

## Count total powered rooms
func _count_powered_rooms(ship: ShipData) -> int:
	var count = 0
	for room_id in ship.room_instances:
		var room = ship.room_instances[room_id]
		var tiles = room["tiles"]

		# Check if any tile of this room is powered
		var is_powered = false
		for tile_pos in tiles:
			if ship.is_room_powered(tile_pos.x, tile_pos.y):
				is_powered = true
				break

		if is_powered:
			count += 1

	return count

## Get default metrics (fallback)
func _get_default_metrics() -> Dictionary:
	return {
		"total_damage_dealt": 0,
		"total_damage_taken": 0,
		"avg_damage_per_turn": 0.0,
		"damage_absorbed": 0,
		"shield_efficiency": 0.0,
		"weapon_efficiency": 0.0,
		"rooms_lost": 0,
		"hp_remaining_pct": 100.0,
		"power_efficiency": 0.0,
		"victory": false,
		"turns_survived": 0
	}
