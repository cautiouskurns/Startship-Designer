extends RefCounted
class_name BarkSelector

## Context-aware bark selection from BarkDatabase
## Part of Phase 1.2: Bark Content & Selection
## Filters barks by event type, context, and prevents repetition

## Track which barks have been used (managed by CrewBarkSystem)
## This is just a reference - actual tracking happens in CrewBarkSystem.used_barks

## Select bark for component destroyed event
static func select_for_component_destroyed(component_type: RoomData.RoomType) -> BarkData:
	var eligible_barks = []

	# Get all damage report barks for this component
	for bark_dict in BarkDatabase.DAMAGE_REPORTS:
		if bark_dict["component"] == component_type:
			# Check if not already used
			if not CrewBarkSystem.used_barks.has(bark_dict["text"]):
				eligible_barks.append(bark_dict)

	# No eligible barks? Try generic damage reports
	if eligible_barks.is_empty():
		for bark_dict in BarkDatabase.DAMAGE_REPORTS:
			if bark_dict["component"] == null:  # Generic
				if not CrewBarkSystem.used_barks.has(bark_dict["text"]):
					eligible_barks.append(bark_dict)

	# Still none? Return null (no bark)
	if eligible_barks.is_empty():
		if CrewBarkSystem.debug_enabled:
			print("[BarkSelector] No eligible barks for component: %s" % RoomData.get_label(component_type))
		return null

	# Random selection from eligible
	var selected = eligible_barks.pick_random()
	return _bark_dict_to_data(selected, BarkData.BarkCategory.DAMAGE_REPORT)

## Select bark for HP threshold crossed
static func select_for_hp_threshold(threshold: int) -> BarkData:
	var eligible_barks = []

	# Get all crew stress barks for this HP threshold
	for bark_dict in BarkDatabase.CREW_STRESS:
		if bark_dict.get("hp_threshold") == threshold:
			if not CrewBarkSystem.used_barks.has(bark_dict["text"]):
				eligible_barks.append(bark_dict)

	if eligible_barks.is_empty():
		if CrewBarkSystem.debug_enabled:
			print("[BarkSelector] No eligible barks for HP threshold: %d%%" % threshold)
		return null

	var selected = eligible_barks.pick_random()
	return _bark_dict_to_data(selected, BarkData.BarkCategory.CREW_STRESS)

## Select bark for victory
static func select_for_victory() -> BarkData:
	var eligible_barks = []

	# Get all victory barks
	for bark_dict in BarkDatabase.VICTORY_DEFEAT:
		if bark_dict.get("outcome") == "victory":
			if not CrewBarkSystem.used_barks.has(bark_dict["text"]):
				eligible_barks.append(bark_dict)

	if eligible_barks.is_empty():
		if CrewBarkSystem.debug_enabled:
			print("[BarkSelector] No eligible victory barks")
		return null

	var selected = eligible_barks.pick_random()
	return _bark_dict_to_data(selected, BarkData.BarkCategory.VICTORY_DEFEAT)

## Select bark for defeat
static func select_for_defeat() -> BarkData:
	var eligible_barks = []

	# Get all defeat barks
	for bark_dict in BarkDatabase.VICTORY_DEFEAT:
		if bark_dict.get("outcome") == "defeat":
			if not CrewBarkSystem.used_barks.has(bark_dict["text"]):
				eligible_barks.append(bark_dict)

	if eligible_barks.is_empty():
		if CrewBarkSystem.debug_enabled:
			print("[BarkSelector] No eligible defeat barks")
		return null

	var selected = eligible_barks.pick_random()
	return _bark_dict_to_data(selected, BarkData.BarkCategory.VICTORY_DEFEAT)

## Select bark for general event (with context matching)
static func select_for_event(event_type: String, context: Dictionary = {}) -> BarkData:
	var eligible_barks = []

	# Search all categories for matching event
	var all_categories = [
		BarkDatabase.DAMAGE_REPORTS,
		BarkDatabase.TACTICAL_UPDATES,
		BarkDatabase.SYSTEM_STATUS,
		BarkDatabase.CREW_STRESS
	]

	for category in all_categories:
		for bark_dict in category:
			if bark_dict.get("event") == event_type:
				# Check context requirements
				if _matches_context(bark_dict, context):
					if not CrewBarkSystem.used_barks.has(bark_dict["text"]):
						eligible_barks.append(bark_dict)

	if eligible_barks.is_empty():
		if CrewBarkSystem.debug_enabled:
			print("[BarkSelector] No eligible barks for event: %s" % event_type)
		return null

	var selected = eligible_barks.pick_random()
	# Determine category based on event type
	var category = _infer_category_from_event(event_type)
	return _bark_dict_to_data(selected, category)

## Check if bark matches context requirements
static func _matches_context(bark_dict: Dictionary, context: Dictionary) -> bool:
	# Check HP context if specified
	if bark_dict.has("context"):
		var bark_context = bark_dict["context"]
		if bark_context.has("min_hp") and context.has("hp_percent"):
			if context["hp_percent"] < bark_context["min_hp"]:
				return false
		if bark_context.has("max_hp") and context.has("hp_percent"):
			if context["hp_percent"] > bark_context["max_hp"]:
				return false

	return true

## Convert bark dictionary to BarkData object
static func _bark_dict_to_data(bark_dict: Dictionary, category: BarkData.BarkCategory) -> BarkData:
	return BarkData.create(
		bark_dict["text"],
		bark_dict["role"],
		bark_dict["priority"],
		category,
		bark_dict.get("audio_file", "")
	)

## Infer category from event type
static func _infer_category_from_event(event_type: String) -> BarkData.BarkCategory:
	# Check if event is tactical (enemy-related)
	if event_type.begins_with("enemy_"):
		return BarkData.BarkCategory.TACTICAL_UPDATE

	# Check if event is power-related
	if event_type.contains("power") or event_type.contains("unpowered"):
		return BarkData.BarkCategory.SYSTEM_STATUS

	# Check if event is damage-related
	if event_type.contains("damage"):
		return BarkData.BarkCategory.TACTICAL_UPDATE

	# Check if event is systems-related
	if event_type.contains("systems"):
		return BarkData.BarkCategory.CREW_STRESS

	# Default to tactical update
	return BarkData.BarkCategory.TACTICAL_UPDATE

## Reset used barks (call at battle start)
static func reset_used_barks() -> void:
	# This is now handled by CrewBarkSystem
	# Just clear any local state if needed
	pass

## Debug: Get statistics about bark database
static func get_bark_stats() -> Dictionary:
	return {
		"total_barks": BarkDatabase.get_total_bark_count(),
		"damage_reports": BarkDatabase.DAMAGE_REPORTS.size(),
		"tactical_updates": BarkDatabase.TACTICAL_UPDATES.size(),
		"system_status": BarkDatabase.SYSTEM_STATUS.size(),
		"crew_stress": BarkDatabase.CREW_STRESS.size(),
		"victory_defeat": BarkDatabase.VICTORY_DEFEAT.size(),
	}
