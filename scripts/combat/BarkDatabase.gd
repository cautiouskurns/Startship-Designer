extends RefCounted
class_name BarkDatabase

## Static bark database for crew commentary
## Contains ~50 barks across 5 categories for MVP
## Part of Phase 1.2: Bark Content & Selection

## Category 1: DAMAGE REPORTS (System Failures)
const DAMAGE_REPORTS = [
	# Reactor destruction
	{
		"text": "Main reactor offline!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.HIGH,
		"component": RoomData.RoomType.REACTOR,
	},
	{
		"text": "We've lost main power!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.HIGH,
		"component": RoomData.RoomType.REACTOR,
	},

	# Shield destruction
	{
		"text": "Shield generator destroyed!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.MEDIUM,
		"component": RoomData.RoomType.SHIELD,
	},
	{
		"text": "Shields are down!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.MEDIUM,
		"component": RoomData.RoomType.SHIELD,
	},
	{
		"text": "We're exposed!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.MEDIUM,
		"component": RoomData.RoomType.SHIELD,
	},

	# Weapon destruction
	{
		"text": "Weapons offline!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.HIGH,
		"component": RoomData.RoomType.WEAPON,
	},
	{
		"text": "No response from weapon systems!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.HIGH,
		"component": RoomData.RoomType.WEAPON,
	},
	{
		"text": "All weapons down!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.HIGH,
		"component": RoomData.RoomType.WEAPON,
	},

	# Engine destruction
	{
		"text": "Engines failing!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.MEDIUM,
		"component": RoomData.RoomType.ENGINE,
	},
	{
		"text": "We're dead in the water!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.MEDIUM,
		"component": RoomData.RoomType.ENGINE,
	},
	{
		"text": "Maneuvering offline!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.MEDIUM,
		"component": RoomData.RoomType.ENGINE,
	},

	# Generic damage
	{
		"text": "Hull breach in engineering!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.MEDIUM,
		"component": null,
	},
	{
		"text": "Backup systems engaging!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.LOW,
		"component": null,
	},
	{
		"text": "Damage control teams, move!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.MEDIUM,
		"component": null,
	},
]

## Category 2: TACTICAL UPDATES (Combat Progress)
const TACTICAL_UPDATES = [
	# Enemy damage dealt
	{
		"text": "Direct hit on their hull!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.MEDIUM,
		"event": "enemy_damage",
	},
	{
		"text": "Enemy shields failing!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.MEDIUM,
		"event": "enemy_shields_low",
	},
	{
		"text": "Their weapons are down!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.MEDIUM,
		"event": "enemy_weapon_destroyed",
	},
	{
		"text": "Got their reactor!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.HIGH,
		"event": "enemy_reactor_destroyed",
	},
	{
		"text": "Enemy disarmed!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.MEDIUM,
		"event": "enemy_weapon_destroyed",
	},
	{
		"text": "Target's losing power!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.MEDIUM,
		"event": "enemy_reactor_destroyed",
	},

	# Player taking damage
	{
		"text": "Taking heavy fire!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.MEDIUM,
		"event": "player_heavy_damage",
	},
	{
		"text": "Taking damage!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.LOW,
		"event": "player_damage",
	},
	{
		"text": "We're hit!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.LOW,
		"event": "player_damage",
	},
	{
		"text": "Multiple hits!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.MEDIUM,
		"event": "player_heavy_damage",
	},
	{
		"text": "Armor's not holding!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.MEDIUM,
		"event": "player_heavy_damage",
		"context": {"min_hp": 0, "max_hp": 75},
	},
	{
		"text": "Stay on target!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.LOW,
		"event": "player_damage",
	},
]

## Category 3: SYSTEM STATUS (Power/Resources)
const SYSTEM_STATUS = [
	{
		"text": "Power grid unstable!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.MEDIUM,
		"event": "power_loss",
	},
	{
		"text": "Rerouting emergency power!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.MEDIUM,
		"event": "power_loss",
	},
	{
		"text": "All systems running on backup!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.HIGH,
		"event": "power_cascade",
	},
	{
		"text": "No power to weapons array!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.HIGH,
		"event": "weapon_unpowered",
	},
	{
		"text": "We're running on fumes!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.HIGH,
		"event": "power_cascade",
	},
	{
		"text": "Multiple systems offline!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.HIGH,
		"event": "power_cascade",
	},
	{
		"text": "Systems nominal!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.LOW,
		"event": "systems_green",
	},
]

## Category 4: CREW STRESS (Ship State)
const CREW_STRESS = [
	# 75% HP threshold
	{
		"text": "Hull integrity compromised!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.HIGH,
		"hp_threshold": 75,
	},
	{
		"text": "Taking damage!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.MEDIUM,
		"hp_threshold": 75,
	},
	{
		"text": "Armor degrading!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.MEDIUM,
		"hp_threshold": 75,
	},

	# 50% HP threshold
	{
		"text": "Hull integrity at 50%!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.HIGH,
		"hp_threshold": 50,
	},
	{
		"text": "We can't take much more!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.HIGH,
		"hp_threshold": 50,
	},
	{
		"text": "This is bad...",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.MEDIUM,
		"hp_threshold": 50,
	},
	{
		"text": "Half the hull's gone!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.HIGH,
		"hp_threshold": 50,
	},

	# 25% HP threshold
	{
		"text": "Critical damage!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.CRITICAL,
		"hp_threshold": 25,
	},
	{
		"text": "We're coming apart!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.CRITICAL,
		"hp_threshold": 25,
	},
	{
		"text": "Structural failure imminent!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.CRITICAL,
		"hp_threshold": 25,
	},
	{
		"text": "We need to get out of here!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.HIGH,
		"hp_threshold": 25,
	},
	{
		"text": "This is it!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.CRITICAL,
		"hp_threshold": 25,
	},

	# Multiple systems lost
	{
		"text": "Half our systems are gone!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.HIGH,
		"event": "multiple_systems_lost",
	},
	{
		"text": "We're fighting blind!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.HIGH,
		"event": "multiple_systems_lost",
	},
	{
		"text": "Nothing's responding!",
		"role": BarkData.CrewRole.ENGINEERING,
		"priority": BarkData.BarkPriority.HIGH,
		"event": "multiple_systems_lost",
	},
]

## Category 5: VICTORY/DEFEAT
const VICTORY_DEFEAT = [
	# Victory
	{
		"text": "Target destroyed!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.CRITICAL,
		"outcome": "victory",
	},
	{
		"text": "Enemy down!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.CRITICAL,
		"outcome": "victory",
	},
	{
		"text": "We did it!",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.CRITICAL,
		"outcome": "victory",
	},
	{
		"text": "All stations, stand down.",
		"role": BarkData.CrewRole.CAPTAIN,
		"priority": BarkData.BarkPriority.CRITICAL,
		"outcome": "victory",
	},
	{
		"text": "Threat eliminated!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.CRITICAL,
		"outcome": "victory",
	},
	{
		"text": "Enemy neutralized!",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.CRITICAL,
		"outcome": "victory",
	},

	# Defeat
	{
		"text": "We're losing—",
		"role": BarkData.CrewRole.TACTICAL,
		"priority": BarkData.BarkPriority.CRITICAL,
		"outcome": "defeat",
	},
	{
		"text": "Abandon—",
		"role": BarkData.CrewRole.CAPTAIN,
		"priority": BarkData.BarkPriority.CRITICAL,
		"outcome": "defeat",
	},
	{
		"text": "Brace for—",
		"role": BarkData.CrewRole.OPERATIONS,
		"priority": BarkData.BarkPriority.CRITICAL,
		"outcome": "defeat",
	},
	{
		"text": "All hands—",
		"role": BarkData.CrewRole.CAPTAIN,
		"priority": BarkData.BarkPriority.CRITICAL,
		"outcome": "defeat",
	},
]

## Get all barks for a category
static func get_barks_for_category(category: BarkData.BarkCategory) -> Array:
	match category:
		BarkData.BarkCategory.DAMAGE_REPORT:
			return DAMAGE_REPORTS
		BarkData.BarkCategory.TACTICAL_UPDATE:
			return TACTICAL_UPDATES
		BarkData.BarkCategory.SYSTEM_STATUS:
			return SYSTEM_STATUS
		BarkData.BarkCategory.CREW_STRESS:
			return CREW_STRESS
		BarkData.BarkCategory.VICTORY_DEFEAT:
			return VICTORY_DEFEAT
	return []

## Get total bark count
static func get_total_bark_count() -> int:
	return DAMAGE_REPORTS.size() + TACTICAL_UPDATES.size() + SYSTEM_STATUS.size() + \
	       CREW_STRESS.size() + VICTORY_DEFEAT.size()
