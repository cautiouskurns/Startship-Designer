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

## Update inventory counts from room counts dictionary
func update_synergy_counts(room_counts: Dictionary):
	# This function is called from ShipDesigner with room counts
	# We keep the same function name for compatibility
	update_inventory_counts(room_counts)

## Update inventory counts
func update_inventory_counts(room_counts: Dictionary):
	if bridge_value:
		bridge_value.text = str(room_counts.get(RoomData.RoomType.BRIDGE, 0))
	if weapons_value:
		weapons_value.text = str(room_counts.get(RoomData.RoomType.WEAPON, 0))
	if shields_value:
		shields_value.text = str(room_counts.get(RoomData.RoomType.SHIELD, 0))
	if engines_value:
		engines_value.text = str(room_counts.get(RoomData.RoomType.ENGINE, 0))
	if reactors_value:
		reactors_value.text = str(room_counts.get(RoomData.RoomType.REACTOR, 0))
	if armor_value:
		armor_value.text = str(room_counts.get(RoomData.RoomType.ARMOR, 0))
