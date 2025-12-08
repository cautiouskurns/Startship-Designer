extends Button
class_name SectorNode

## Individual sector display on campaign map
## Shows icon, name, threat level, and visual state

signal sector_clicked(sector_id: CampaignState.SectorID)

## Sector configuration
@export var sector_id: CampaignState.SectorID = CampaignState.SectorID.COMMAND

## UI elements
@onready var icon_label: Label = $Panel/VBoxContainer/IconLabel
@onready var name_label: Label = $Panel/VBoxContainer/NameLabel
@onready var threat_bar: ProgressBar = $Panel/VBoxContainer/ThreatBar
@onready var panel: Panel = $Panel
@onready var pulse_timer: Timer = $PulseTimer

## Visual state
var current_threat: int = 0
var previous_threat: int = 0
var is_lost_state: bool = false
var pulse_phase: float = 0.0
var is_selected: bool = false

func _ready():
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pulse_timer.timeout.connect(_on_pulse_timeout)

	# Configure threat bar
	threat_bar.min_value = 0
	threat_bar.max_value = 4
	threat_bar.value = 0

	# Start pulse timer for threatened sectors
	pulse_timer.start()

	update_display()

## Update visual display based on sector state
func update_display():
	if not CampaignState:
		return

	# Get sector data
	var sector_data = CampaignState.get_sector(sector_id)
	var sector_def = CampaignState.get_sector_definition(sector_id)

	if not sector_data or not sector_def:
		return

	# Update icon and name
	icon_label.text = sector_def.get("icon", "❓")
	name_label.text = sector_def.get("name", "Unknown")

	# Update threat level
	previous_threat = current_threat
	current_threat = sector_data.threat_level
	is_lost_state = sector_data.is_lost

	# Animate threat change if it changed
	if previous_threat != current_threat and previous_threat != 0:
		animate_threat_change(previous_threat, current_threat)
	else:
		# No animation needed, just set the value
		threat_bar.value = current_threat

	# Update visual state based on threat
	_update_visual_state()

## Update visual state (colors, border, pulse)
func _update_visual_state():
	var style = StyleBoxFlat.new()

	# Determine state colors
	if is_lost_state:
		# Lost state: gray, semi-transparent
		style.bg_color = Color(0.101, 0.101, 0.101, 0.3)
		style.border_color = Color(0.424, 0.424, 0.424, 0.8)
		modulate = Color(0.5, 0.5, 0.5, 0.6)
		disabled = false  # Lost sectors can be selected to recapture

	elif current_threat >= 3:
		# Critical: red, fast pulse
		style.bg_color = Color(0.101, 0.101, 0.101, 0.4)
		style.border_color = Color(0.886, 0.290, 0.290, 1.0)  # Red
		modulate = Color(1, 1, 1)
		disabled = false

	elif current_threat >= 2:
		# Threatened: yellow, slow pulse
		style.bg_color = Color(0.101, 0.101, 0.101, 0.4)
		style.border_color = Color(0.886, 0.831, 0.290, 1.0)  # Yellow
		modulate = Color(1, 1, 1)
		disabled = false

	elif current_threat >= 1:
		# Light threat: yellow-green
		style.bg_color = Color(0.101, 0.101, 0.101, 0.4)
		style.border_color = Color(0.686, 0.886, 0.290, 1.0)  # Yellow-green
		modulate = Color(1, 1, 1)
		disabled = false

	else:
		# Secure: green
		style.bg_color = Color(0.101, 0.101, 0.101, 0.4)
		style.border_color = Color(0.290, 0.886, 0.290, 1.0)  # Green
		modulate = Color(1, 1, 1)
		disabled = false  # Secure sectors can still be selected

	# Command sector is always disabled (can't be defended)
	if sector_id == CampaignState.SectorID.COMMAND:
		disabled = true

	# Override border color if selected (cyan pulse)
	if is_selected:
		style.border_color = Color(0.290, 0.886, 0.886, 1.0)  # Cyan
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
	else:
		# Apply normal border
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2

	panel.add_theme_stylebox_override("panel", style)

	# Update threat bar color
	_update_threat_bar_color()

## Update threat bar color based on threat level
func _update_threat_bar_color():
	var bar_style = StyleBoxFlat.new()

	if current_threat >= 3:
		bar_style.bg_color = Color(0.886, 0.290, 0.290)  # Red
	elif current_threat >= 2:
		bar_style.bg_color = Color(0.886, 0.831, 0.290)  # Yellow
	elif current_threat >= 1:
		bar_style.bg_color = Color(0.686, 0.886, 0.290)  # Yellow-green
	else:
		bar_style.bg_color = Color(0.290, 0.886, 0.290)  # Green

	threat_bar.add_theme_stylebox_override("fill", bar_style)

## Handle pulse animation for threatened/critical sectors and selected sectors
func _on_pulse_timeout():
	# Pulse for selected sectors OR threatened sectors
	if not is_selected and current_threat < 2:
		# No pulse for unselected, secure sectors
		return

	pulse_phase += 0.1

	# Pulse speed depends on state
	var pulse_speed = 1.0 if (is_selected or current_threat >= 3) else 0.5
	var pulse_amount = sin(pulse_phase * pulse_speed) * 0.15 + 1.0

	# Apply pulse to modulate (brightness)
	if not is_lost_state:
		modulate = Color(pulse_amount, pulse_amount, pulse_amount)

## Handle button press
func _on_pressed():
	AudioManager.play_button_click()
	emit_signal("sector_clicked", sector_id)

## Handle mouse enter (hover)
func _on_mouse_entered():
	if not disabled:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_show_tooltip()

## Handle mouse exit
func _on_mouse_exited():
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	_hide_tooltip()

## Show sector tooltip
func _show_tooltip():
	# TODO: Implement tooltip with sector details
	pass

## Hide sector tooltip
func _hide_tooltip():
	# TODO: Hide tooltip
	pass

## Select this sector (visual feedback for player choice)
func select():
	is_selected = true
	_update_visual_state()

## Deselect this sector (remove selection visual)
func deselect():
	is_selected = false
	_update_visual_state()

## Animate threat level change with visual feedback
func animate_threat_change(old_value: int, new_value: int):
	# Determine if threat increased or decreased
	var threat_increased = new_value > old_value

	# Create tween for smooth threat bar animation
	var tween = create_tween()
	tween.set_parallel(true)  # Run animations in parallel

	# Animate threat bar from old to new value
	tween.tween_property(threat_bar, "value", new_value, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Flash the sector with appropriate color
	var flash_color: Color
	if threat_increased:
		# Red flash for threat increase
		flash_color = Color(1.5, 0.3, 0.3, 1.0)
	else:
		# Green flash for threat decrease
		flash_color = Color(0.3, 1.5, 0.3, 1.0)

	# Flash animation: modulate to flash color and back
	tween.tween_property(self, "modulate", flash_color, 0.15)
	tween.chain().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.35)

	# Scale pulse effect
	var original_scale = scale
	tween.tween_property(self, "scale", original_scale * 1.1, 0.15)
	tween.chain().tween_property(self, "scale", original_scale, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
