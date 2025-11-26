extends Panel
class_name InventoryPanel

## Panel displaying room inventory counts (clean modern UI)

## Room count value labels
@onready var bridge_value: Label = $VBoxContainer/BridgeRow/BridgeValue
@onready var weapons_value: Label = $VBoxContainer/WeaponsRow/WeaponsValue
@onready var shields_value: Label = $VBoxContainer/ShieldsRow/ShieldsValue
@onready var engines_value: Label = $VBoxContainer/EnginesRow/EnginesValue
@onready var reactors_value: Label = $VBoxContainer/ReactorsRow/ReactorsValue
@onready var armor_value: Label = $VBoxContainer/ArmorRow/ArmorValue

## Update inventory counts from room counts dictionary
func update_inventory(counts: Dictionary):
	# Update each room type count
	bridge_value.text = str(counts.get(RoomData.RoomType.BRIDGE, 0))
	weapons_value.text = str(counts.get(RoomData.RoomType.WEAPON, 0))
	shields_value.text = str(counts.get(RoomData.RoomType.SHIELD, 0))
	engines_value.text = str(counts.get(RoomData.RoomType.ENGINE, 0))
	reactors_value.text = str(counts.get(RoomData.RoomType.REACTOR, 0))
	armor_value.text = str(counts.get(RoomData.RoomType.ARMOR, 0))

	# Apply white color to all values
	var white_color = Color.WHITE
	bridge_value.add_theme_color_override("font_color", white_color)
	weapons_value.add_theme_color_override("font_color", white_color)
	shields_value.add_theme_color_override("font_color", white_color)
	engines_value.add_theme_color_override("font_color", white_color)
	reactors_value.add_theme_color_override("font_color", white_color)
	armor_value.add_theme_color_override("font_color", white_color)
