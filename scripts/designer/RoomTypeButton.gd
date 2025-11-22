extends Button
class_name RoomTypeButton

## Button representing a room type in the palette

signal room_type_selected(room_type: RoomData.RoomType)

## The room type this button represents
@export var room_type: RoomData.RoomType = RoomData.RoomType.EMPTY

## UI elements
@onready var room_icon: ColorRect = $HBoxContainer/Icon
@onready var name_label: Label = $HBoxContainer/NameLabel
@onready var cost_label: Label = $HBoxContainer/CostLabel
@onready var count_label: Label = $HBoxContainer/CountLabel

## Visual state
var is_selected: bool = false

## Room scenes for icons (same as ShipDesigner)
var room_scenes = {
	RoomData.RoomType.BRIDGE: preload("res://scenes/components/rooms/Bridge.tscn"),
	RoomData.RoomType.WEAPON: preload("res://scenes/components/rooms/Weapon.tscn"),
	RoomData.RoomType.SHIELD: preload("res://scenes/components/rooms/Shield.tscn"),
	RoomData.RoomType.ENGINE: preload("res://scenes/components/rooms/Engine.tscn"),
	RoomData.RoomType.REACTOR: preload("res://scenes/components/rooms/Reactor.tscn"),
	RoomData.RoomType.ARMOR: preload("res://scenes/components/rooms/Armor.tscn")
}

func _ready():
	pressed.connect(_on_pressed)
	update_display()

## Update the button's visual display
func update_display():
	if room_type == RoomData.RoomType.EMPTY:
		return

	# Set name
	name_label.text = RoomData.labels.get(room_type, "")

	# Set cost
	var cost = RoomData.costs.get(room_type, 0)
	cost_label.text = "%d BP" % cost

	# Icon will be set by instantiating the room scene for its sprite
	# For now, use a placeholder color based on room type
	room_icon.modulate = RoomData.colors.get(room_type, Color.WHITE)

## Update the count displayed
func set_count(count: int):
	count_label.text = "x%d" % count

## Set selected visual state
func set_selected(selected: bool):
	is_selected = selected
	if selected:
		# Cyan glow border
		add_theme_color_override("font_color", Color(0.290, 0.886, 0.886))
		modulate = Color(1.1, 1.1, 1.1)
	else:
		# Normal state
		remove_theme_color_override("font_color")
		modulate = Color(1, 1, 1)

## Set availability (enabled/disabled)
func set_available(available: bool):
	disabled = not available
	if not available:
		modulate = Color(0.5, 0.5, 0.5)
	elif not is_selected:
		modulate = Color(1, 1, 1)

## Handle button press
func _on_pressed():
	emit_signal("room_type_selected", room_type)
