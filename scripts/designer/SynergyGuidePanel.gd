extends Panel
class_name SynergyGuidePanel

## Panel displaying inventory of placed components

## References to value labels
@onready var bridge_value: Label = $VBoxContainer/ContentMargin/ContentContainer/BridgeRow/BridgeValue
@onready var weapons_value: Label = $VBoxContainer/ContentMargin/ContentContainer/WeaponsRow/WeaponsValue
@onready var shields_value: Label = $VBoxContainer/ContentMargin/ContentContainer/ShieldsRow/ShieldsValue
@onready var engines_value: Label = $VBoxContainer/ContentMargin/ContentContainer/EnginesRow/EnginesValue
@onready var reactors_value: Label = $VBoxContainer/ContentMargin/ContentContainer/ReactorsRow/ReactorsValue
@onready var armor_value: Label = $VBoxContainer/ContentMargin/ContentContainer/ArmorRow/ArmorValue

## References to synergy labels
@onready var weapons_synergy: RichTextLabel = $VBoxContainer/ContentMargin/ContentContainer/WeaponsRow/WeaponsSynergy
@onready var shields_synergy: RichTextLabel = $VBoxContainer/ContentMargin/ContentContainer/ShieldsRow/ShieldsSynergy
@onready var engines_synergy: RichTextLabel = $VBoxContainer/ContentMargin/ContentContainer/EnginesRow/EnginesSynergy

## Update inventory with room counts and synergy bonuses
func update_inventory(room_counts: Dictionary, synergy_counts: Dictionary = {}):
	# Weapons: Show count + FIRE_RATE and DURABILITY synergies
	if weapons_value and weapons_synergy:
		var count = room_counts.get(RoomData.RoomType.WEAPON, 0)
		var fire_rate = synergy_counts.get(RoomData.SynergyType.FIRE_RATE, 0)
		var durability = synergy_counts.get(RoomData.SynergyType.DURABILITY, 0)
		var synergy_total = fire_rate + durability

		weapons_value.text = str(count)

		if synergy_total > 0:
			var tooltip_parts = []
			if fire_rate > 0:
				tooltip_parts.append("Fire Rate: +%d (Weapon+Weapon)" % fire_rate)
			if durability > 0:
				tooltip_parts.append("Durability: +%d (Weapon+Armor)" % durability)

			weapons_synergy.text = "[color=#E2904A](+%d)[/color]" % synergy_total
			weapons_synergy.tooltip_text = "\n".join(tooltip_parts)
		else:
			weapons_synergy.text = ""
			weapons_synergy.tooltip_text = ""

	# Shields: Show count + SHIELD_CAPACITY synergies
	if shields_value and shields_synergy:
		var count = room_counts.get(RoomData.RoomType.SHIELD, 0)
		var shield_cap = synergy_counts.get(RoomData.SynergyType.SHIELD_CAPACITY, 0)

		shields_value.text = str(count)

		if shield_cap > 0:
			shields_synergy.text = "[color=#4AE2E2](+%d)[/color]" % shield_cap
			shields_synergy.tooltip_text = "Shield Capacity: +%d (Shield+Reactor)" % shield_cap
		else:
			shields_synergy.text = ""
			shields_synergy.tooltip_text = ""

	# Engines: Show count + INITIATIVE synergies
	if engines_value and engines_synergy:
		var count = room_counts.get(RoomData.RoomType.ENGINE, 0)
		var initiative = synergy_counts.get(RoomData.SynergyType.INITIATIVE, 0)

		engines_value.text = str(count)

		if initiative > 0:
			engines_synergy.text = "[color=#4A90E2](+%d)[/color]" % initiative
			engines_synergy.tooltip_text = "Initiative: +%d (Engine+Engine)" % initiative
		else:
			engines_synergy.text = ""
			engines_synergy.tooltip_text = ""

	# Bridge, Reactors, Armor: No synergies, just show count
	if bridge_value:
		bridge_value.text = str(room_counts.get(RoomData.RoomType.BRIDGE, 0))
	if reactors_value:
		reactors_value.text = str(room_counts.get(RoomData.RoomType.REACTOR, 0))
	if armor_value:
		armor_value.text = str(room_counts.get(RoomData.RoomType.ARMOR, 0))

## Backward compatibility wrapper (old function name)
func update_synergy_counts(room_counts: Dictionary):
	# Call new function without synergy data
	update_inventory(room_counts, {})
