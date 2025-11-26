extends Panel
class_name SynergyGuidePanel

## Panel displaying inventory of placed components

## References to value labels (some are RichTextLabel for synergy display)
@onready var bridge_value: Label = $VBoxContainer/ContentMargin/ContentContainer/BridgeRow/BridgeValue
@onready var weapons_value: RichTextLabel = $VBoxContainer/ContentMargin/ContentContainer/WeaponsRow/WeaponsValue
@onready var shields_value: RichTextLabel = $VBoxContainer/ContentMargin/ContentContainer/ShieldsRow/ShieldsValue
@onready var engines_value: RichTextLabel = $VBoxContainer/ContentMargin/ContentContainer/EnginesRow/EnginesValue
@onready var reactors_value: Label = $VBoxContainer/ContentMargin/ContentContainer/ReactorsRow/ReactorsValue
@onready var armor_value: Label = $VBoxContainer/ContentMargin/ContentContainer/ArmorRow/ArmorValue

## Update inventory with room counts and synergy bonuses
func update_inventory(room_counts: Dictionary, synergy_counts: Dictionary = {}):
	# Weapons: Show count + FIRE_RATE and DURABILITY synergies
	if weapons_value:
		var count = room_counts.get(RoomData.RoomType.WEAPON, 0)
		var fire_rate = synergy_counts.get(RoomData.SynergyType.FIRE_RATE, 0)
		var durability = synergy_counts.get(RoomData.SynergyType.DURABILITY, 0)
		var synergy_total = fire_rate + durability

		weapons_value.text = str(count)
		if synergy_total > 0:
			weapons_value.text += " [font_size=10][color=#E2904A](+%d)[/color][/font_size]" % synergy_total

	# Shields: Show count + SHIELD_CAPACITY synergies
	if shields_value:
		var count = room_counts.get(RoomData.RoomType.SHIELD, 0)
		var shield_cap = synergy_counts.get(RoomData.SynergyType.SHIELD_CAPACITY, 0)

		shields_value.text = str(count)
		if shield_cap > 0:
			shields_value.text += " [font_size=10][color=#4AE2E2](+%d)[/color][/font_size]" % shield_cap

	# Engines: Show count + INITIATIVE synergies
	if engines_value:
		var count = room_counts.get(RoomData.RoomType.ENGINE, 0)
		var initiative = synergy_counts.get(RoomData.SynergyType.INITIATIVE, 0)

		engines_value.text = str(count)
		if initiative > 0:
			engines_value.text += " [font_size=10][color=#4A90E2](+%d)[/color][/font_size]" % initiative

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
