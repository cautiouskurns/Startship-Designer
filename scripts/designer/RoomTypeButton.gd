extends Button
class_name RoomTypeButton

## Button representing a room type in the palette

signal room_type_selected(room_type: RoomData.RoomType)
signal rotation_requested(room_type: RoomData.RoomType)  # Phase 7.3

## The room type this button represents
@export var room_type: RoomData.RoomType = RoomData.RoomType.EMPTY

## UI elements
@onready var name_label: Label = $HBoxContainer/MarginContainer/NameLabel
@onready var size_cost_label: Label = $HBoxContainer/SizeCostLabel
@onready var preview_panel: Panel = $HBoxContainer/PreviewMargin/PreviewContainer/PreviewPanel
@onready var preview_icon: Label = $HBoxContainer/PreviewMargin/PreviewContainer/PreviewIcon

## Tooltip elements
@onready var tooltip_panel: Panel = $TooltipPanel
@onready var tooltip_timer: Timer = $TooltipTimer
@onready var tooltip_name_label: Label = $TooltipPanel/VBoxContainer/MarginContainer/Content/RoomNameLabel
@onready var tooltip_description_label: Label = $TooltipPanel/VBoxContainer/MarginContainer/Content/DescriptionLabel
@onready var tooltip_stats_label: Label = $TooltipPanel/VBoxContainer/MarginContainer/Content/StatsLabel

## Visual state
var is_selected: bool = false

## Room icons mapping
static var room_icons = {
	RoomData.RoomType.BRIDGE: "★",
	RoomData.RoomType.WEAPON: "▶",
	RoomData.RoomType.SHIELD: "◆",
	RoomData.RoomType.ENGINE: "▲",
	RoomData.RoomType.REACTOR: "⊕",
	RoomData.RoomType.ARMOR: "■",
	RoomData.RoomType.CONDUIT: "─",
	RoomData.RoomType.RELAY: "◈"
}

## Tooltip data for each room type
static var tooltip_data = {
	RoomData.RoomType.BRIDGE: "Command center. Required. Self-powered.|Losing Bridge = instant defeat.",
	RoomData.RoomType.WEAPON: "Offensive system.|Deals 10 damage per powered weapon.",
	RoomData.RoomType.SHIELD: "Defensive system.|Absorbs up to 15 damage per powered shield.",
	RoomData.RoomType.ENGINE: "Propulsion system.|Higher engine count shoots first (initiative).",
	RoomData.RoomType.REACTOR: "Power generation.|Powers adjacent rooms (up/down/left/right only).",
	RoomData.RoomType.ARMOR: "Hull plating.|Adds 20 HP per armor room (doesn't need power).",
	RoomData.RoomType.CONDUIT: "Power conduit.|Efficient 1×1 power transmission (doesn't need power).",
	RoomData.RoomType.RELAY: "Power relay.|Extends power grid remotely via pathfinding."
}

func _ready():
	pressed.connect(_on_pressed)
	update_display()

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

	# Extract room name (without symbol)
	var parts = full_label.split(" ", false, 1)
	if parts.size() >= 2:
		name_label.text = parts[1]    # Room name without symbol
	else:
		name_label.text = full_label

	# Get room size
	var size = RoomData.get_shape_size(room_type)

	# Get cost
	var cost = RoomData.costs.get(room_type, 0)

	# Format as "WxH • XBP"
	size_cost_label.text = "%d×%d • %dBP" % [size.x, size.y, cost]

	# Update preview panel and icon
	_update_preview()

## Update preview panel style and icon based on room type
func _update_preview():
	if room_type == RoomData.RoomType.EMPTY:
		return

	# Get room color
	var room_color = RoomData.get_color(room_type)

	# Create StyleBoxFlat for preview panel (outline only, transparent center)
	var preview_style = StyleBoxFlat.new()
	preview_style.bg_color = Color(0, 0, 0, 0)  # Transparent background
	preview_style.border_width_left = 2
	preview_style.border_width_top = 2
	preview_style.border_width_right = 2
	preview_style.border_width_bottom = 2
	preview_style.border_color = room_color

	# Apply style to preview panel
	preview_panel.add_theme_stylebox_override("panel", preview_style)

	# Set icon
	var icon = room_icons.get(room_type, "?")
	preview_icon.text = icon

## Update the count displayed (deprecated - no longer shown in UI)
func set_count(count: int):
	# Count no longer displayed in simplified layout
	pass

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

## Handle rotation button press (deprecated - rotation UI removed)
func _on_rotate_button_pressed():
	# Rotation UI removed in simplified layout
	pass

## Update rotation display on button (deprecated - rotation UI removed)
func update_rotation_display(rotation: int):
	# Rotation UI removed in simplified layout
	pass
