extends Button
class_name RoomTypeButton

## Button representing a room type in the palette

signal room_type_selected(room_type: RoomData.RoomType)
signal rotation_requested(room_type: RoomData.RoomType)  # Phase 7.3

## The room type this button represents
@export var room_type: RoomData.RoomType = RoomData.RoomType.EMPTY

## UI elements
@onready var room_icon: ColorRect = $HBoxContainer/Icon
@onready var symbol_label: Label = $HBoxContainer/Icon/SymbolLabel
@onready var rotate_button: Button = $HBoxContainer/RotateButton  # Phase 7.3
@onready var name_label: Label = $HBoxContainer/NameLabel
@onready var cost_label: Label = $HBoxContainer/CostLabel
@onready var count_label: Label = $HBoxContainer/CountLabel

## Tooltip elements
@onready var tooltip_panel: Panel = $TooltipPanel
@onready var tooltip_timer: Timer = $TooltipTimer
@onready var tooltip_name_label: Label = $TooltipPanel/VBoxContainer/MarginContainer/Content/RoomNameLabel
@onready var tooltip_description_label: Label = $TooltipPanel/VBoxContainer/MarginContainer/Content/DescriptionLabel
@onready var tooltip_stats_label: Label = $TooltipPanel/VBoxContainer/MarginContainer/Content/StatsLabel

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

## Tooltip data for each room type
static var tooltip_data = {
	RoomData.RoomType.BRIDGE: "Command center. Required. Self-powered.|Losing Bridge = instant defeat.",
	RoomData.RoomType.WEAPON: "Offensive system.|Deals 10 damage per powered weapon.",
	RoomData.RoomType.SHIELD: "Defensive system.|Absorbs up to 15 damage per powered shield.",
	RoomData.RoomType.ENGINE: "Propulsion system.|Higher engine count shoots first (initiative).",
	RoomData.RoomType.REACTOR: "Power generation.|Powers adjacent rooms (up/down/left/right only).",
	RoomData.RoomType.ARMOR: "Hull plating.|Adds 20 HP per armor room (doesn't need power)."
}

func _ready():
	pressed.connect(_on_pressed)
	update_display()

	# Connect rotation button (Phase 7.3)
	rotate_button.pressed.connect(_on_rotate_button_pressed)

	# Hide rotation button for rooms that don't rotate (Bridge/Armor are square)
	if room_type == RoomData.RoomType.BRIDGE or room_type == RoomData.RoomType.ARMOR or room_type == RoomData.RoomType.EMPTY:
		rotate_button.visible = false

	# Connect tooltip signals
	mouse_entered.connect(_on_mouse_entered_tooltip)
	mouse_exited.connect(_on_mouse_exited_tooltip)
	tooltip_timer.timeout.connect(_on_tooltip_timeout)

	# Update tooltip text based on room type
	_update_tooltip_text()

## Update the button's visual display
func update_display():
	if room_type == RoomData.RoomType.EMPTY:
		return

	# Get full label with symbol
	var full_label = RoomData.labels.get(room_type, "")

	# Extract symbol (first character before space) and room name
	var parts = full_label.split(" ", false, 1)
	if parts.size() >= 2:
		symbol_label.text = parts[0]  # Symbol
		name_label.text = parts[1]    # Room name without symbol
	else:
		symbol_label.text = ""
		name_label.text = full_label

	# Set cost
	var cost = RoomData.costs.get(room_type, 0)
	cost_label.text = "%d BP" % cost

	# Set icon color based on room type
	room_icon.color = RoomData.colors.get(room_type, Color.WHITE)

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

## Handle mouse entering button - start tooltip timer
func _on_mouse_entered_tooltip():
	tooltip_timer.start()

## Handle tooltip timer timeout - show tooltip
func _on_tooltip_timeout():
	tooltip_panel.visible = true

## Handle mouse exiting button - hide tooltip
func _on_mouse_exited_tooltip():
	tooltip_timer.stop()
	tooltip_panel.visible = false

## Update tooltip text based on room type
func _update_tooltip_text():
	if room_type == RoomData.RoomType.EMPTY:
		return

	# Get tooltip text for this room type
	var tooltip_text = tooltip_data.get(room_type, "|")

	# Split on "|" separator
	var parts = tooltip_text.split("|")

	# Set room name (extract name without symbol)
	var full_label = RoomData.labels.get(room_type, "")
	var label_parts = full_label.split(" ", false, 1)
	if label_parts.size() >= 2:
		tooltip_name_label.text = label_parts[1]  # Room name without symbol
	else:
		tooltip_name_label.text = full_label

	# Set description (first part)
	if parts.size() > 0:
		tooltip_description_label.text = parts[0]

	# Set stats (second part)
	if parts.size() > 1:
		tooltip_stats_label.text = parts[1]

## Handle rotation button press (Phase 7.3)
func _on_rotate_button_pressed():
	# Emit rotation signal
	emit_signal("rotation_requested", room_type)
	# Don't select the room, just rotate it
	# (prevents accidentally changing selection when just wanting to rotate)

## Update rotation display on button (Phase 7.3)
func update_rotation_display(rotation: int):
	# Only update if rotation button is visible (non-square rooms)
	if not rotate_button.visible:
		return

	# Show rotation angle on button
	if rotation == 0:
		rotate_button.text = "↻"  # Just arrow at 0°
	else:
		rotate_button.text = "↻%d°" % rotation
