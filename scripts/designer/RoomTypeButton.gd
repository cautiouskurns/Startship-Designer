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
	# Original Components
	RoomData.RoomType.BRIDGE: "★",
	RoomData.RoomType.WEAPON: "▶",
	RoomData.RoomType.SHIELD: "◆",
	RoomData.RoomType.ENGINE: "▲",
	RoomData.RoomType.REACTOR: "⊕",
	RoomData.RoomType.ARMOR: "■",
	RoomData.RoomType.CONDUIT: "─",
	RoomData.RoomType.RELAY: "◈",

	# Energy Weapons
	RoomData.RoomType.PHASER_ARRAY: "▷",
	RoomData.RoomType.HEAVY_PHASER: "►",
	RoomData.RoomType.PULSE_LASER: "➤",
	RoomData.RoomType.BEAM_LANCE: "⟩",
	RoomData.RoomType.ION_CANNON: "⊳",

	# Projectile Weapons
	RoomData.RoomType.TORPEDO_LAUNCHER: "◉",
	RoomData.RoomType.MISSILE_POD: "●",
	RoomData.RoomType.RAILGUN: "○",
	RoomData.RoomType.AUTOCANNON: "◎",

	# Defensive Weapons
	RoomData.RoomType.POINT_DEFENSE: "◈",
	RoomData.RoomType.FLAK_BATTERY: "◇",
	RoomData.RoomType.INTERCEPTOR_BAY: "◆",

	# Specialty Weapons
	RoomData.RoomType.EMP_EMITTER: "⚡",
	RoomData.RoomType.TRACTOR_BEAM: "⊗",

	# Shields
	RoomData.RoomType.STANDARD_SHIELD: "◆",
	RoomData.RoomType.LIGHT_SHIELD: "◇",
	RoomData.RoomType.HEAVY_SHIELD: "◈",
	RoomData.RoomType.FAST_RECHARGE_SHIELD: "❖",
	RoomData.RoomType.HARDENED_SHIELD: "◆",

	# Armor
	RoomData.RoomType.HULL_PLATING: "▪",
	RoomData.RoomType.LIGHT_ARMOR: "▫",
	RoomData.RoomType.HEAVY_ARMOR: "▬",
	RoomData.RoomType.REACTIVE_ARMOR: "▣",
	RoomData.RoomType.ABLATIVE_ARMOR: "▢",

	# Defense Specialty
	RoomData.RoomType.ECM_SUITE: "⚛",
	RoomData.RoomType.CHAFF_LAUNCHER: "✦",
	RoomData.RoomType.DAMAGE_CONTROL: "⊕",

	# Main Engines
	RoomData.RoomType.STANDARD_ENGINE: "▲",
	RoomData.RoomType.HIGH_THRUST_ENGINE: "▴",
	RoomData.RoomType.EFFICIENT_ENGINE: "△",
	RoomData.RoomType.ARMORED_ENGINE: "▲",

	# Maneuvering
	RoomData.RoomType.THRUSTERS: "▴",
	RoomData.RoomType.REACTION_CONTROL: "▵",
	RoomData.RoomType.COMBAT_THRUSTERS: "▴",

	# FTL Systems
	RoomData.RoomType.JUMP_DRIVE: "◉",
	RoomData.RoomType.FAST_SPOOL_DRIVE: "◎",
	RoomData.RoomType.EMERGENCY_JUMP: "○",
	RoomData.RoomType.ARMORED_DRIVE: "●",

	# Propulsion Specialty
	RoomData.RoomType.AFTERBURNER: "⚡",
	RoomData.RoomType.GRAVITY_WELL: "⊗",

	# Command
	RoomData.RoomType.AUXILIARY_CONTROL: "☆",
	RoomData.RoomType.COMBAT_INFO_CENTER: "★",
	RoomData.RoomType.FLAG_BRIDGE: "✦",

	# Sensors
	RoomData.RoomType.SENSOR_ARRAY: "◉",
	RoomData.RoomType.ADVANCED_SENSORS: "◎",
	RoomData.RoomType.LONG_RANGE_SCANNERS: "⊙",
	RoomData.RoomType.TARGET_PAINTER: "⊕",

	# Computer Systems
	RoomData.RoomType.COMPUTER_CORE: "■",
	RoomData.RoomType.TACTICAL_COMPUTER: "▣",
	RoomData.RoomType.AI_CORE: "◆",

	# Command Specialty
	RoomData.RoomType.CLOAKING_DEVICE: "◇",
	RoomData.RoomType.STEALTH_HULL: "◈",

	# Hull Components
	RoomData.RoomType.REINFORCED_HULL: "□",
	RoomData.RoomType.LIGHTWEIGHT_FRAME: "▢",

	# Compartmentalization
	RoomData.RoomType.BULKHEAD: "▬",
	RoomData.RoomType.BLAST_DOOR: "▣",
	RoomData.RoomType.AIRLOCK: "○",

	# Structure Specialty
	RoomData.RoomType.DECOY_MODULE: "◎",
	RoomData.RoomType.STEALTH_PLATING: "▪",
	RoomData.RoomType.SPACED_ARMOR: "▬"
}

## Tooltip data for each room type
static var tooltip_data = {
	# Original Components
	RoomData.RoomType.BRIDGE: "Command center. Required. Self-powered.|Losing Bridge = instant defeat.",
	RoomData.RoomType.WEAPON: "Offensive system.|Deals 10 damage per powered weapon.",
	RoomData.RoomType.SHIELD: "Defensive system.|Absorbs up to 15 damage per powered shield.",
	RoomData.RoomType.ENGINE: "Propulsion system.|Higher engine count shoots first (initiative).",
	RoomData.RoomType.REACTOR: "Power generation.|Powers adjacent rooms (up/down/left/right only).",
	RoomData.RoomType.ARMOR: "Hull plating.|Adds 20 HP per armor room (doesn't need power).",
	RoomData.RoomType.CONDUIT: "Power conduit.|Efficient 1×1 power transmission (doesn't need power).",
	RoomData.RoomType.RELAY: "Power relay.|Extends power grid remotely via pathfinding.",

	# Energy Weapons
	RoomData.RoomType.PHASER_ARRAY: "Wide-arc energy weapon.|Moderate damage, rapid fire capability.",
	RoomData.RoomType.HEAVY_PHASER: "High-power directed energy weapon.|High damage, requires significant power.",
	RoomData.RoomType.PULSE_LASER: "Rapid-fire laser system.|Fast firing rate, moderate damage per shot.",
	RoomData.RoomType.BEAM_LANCE: "Focused beam weapon.|Precise, long-range energy projection.",
	RoomData.RoomType.ION_CANNON: "Disruption weapon.|Damages systems and disables power grid.",

	# Projectile Weapons
	RoomData.RoomType.TORPEDO_LAUNCHER: "Heavy projectile system.|High damage, slow reload.",
	RoomData.RoomType.MISSILE_POD: "Multi-warhead launcher.|Fires multiple guided projectiles.",
	RoomData.RoomType.RAILGUN: "Kinetic accelerator.|Extreme velocity projectile weapon.",
	RoomData.RoomType.AUTOCANNON: "Rapid-fire ballistic weapon.|High rate of fire, moderate damage.",

	# Defensive Weapons
	RoomData.RoomType.POINT_DEFENSE: "Anti-missile system.|Intercepts incoming projectiles.",
	RoomData.RoomType.FLAK_BATTERY: "Area denial weapon.|Defensive screen against missiles.",
	RoomData.RoomType.INTERCEPTOR_BAY: "Fighter launch bay.|Deploys defensive interceptors.",

	# Specialty Weapons
	RoomData.RoomType.EMP_EMITTER: "Electromagnetic pulse weapon.|Disables electronic systems temporarily.",
	RoomData.RoomType.TRACTOR_BEAM: "Gravity manipulation system.|Holds or repositions targets.",

	# Shields
	RoomData.RoomType.STANDARD_SHIELD: "Standard deflector shield.|Balanced protection and efficiency.",
	RoomData.RoomType.LIGHT_SHIELD: "Compact shield generator.|Lower protection, less power required.",
	RoomData.RoomType.HEAVY_SHIELD: "Reinforced shield system.|Maximum protection, high power cost.",
	RoomData.RoomType.FAST_RECHARGE_SHIELD: "Quick-recovery shield.|Rapid regeneration between hits.",
	RoomData.RoomType.HARDENED_SHIELD: "Resistant shielding.|Extra protection against specific attacks.",

	# Armor
	RoomData.RoomType.HULL_PLATING: "Basic hull reinforcement.|Minimal HP bonus, lightweight.",
	RoomData.RoomType.LIGHT_ARMOR: "Light ablative plating.|Modest protection, low mass.",
	RoomData.RoomType.HEAVY_ARMOR: "Thick armor plating.|Maximum HP bonus, heavy.",
	RoomData.RoomType.REACTIVE_ARMOR: "Explosive-reactive plating.|Enhanced protection against projectiles.",
	RoomData.RoomType.ABLATIVE_ARMOR: "Sacrificial outer layer.|Absorbs damage through erosion.",

	# Defense Specialty
	RoomData.RoomType.ECM_SUITE: "Electronic countermeasures.|Reduces enemy weapon accuracy.",
	RoomData.RoomType.CHAFF_LAUNCHER: "Decoy dispenser.|Confuses missile targeting systems.",
	RoomData.RoomType.DAMAGE_CONTROL: "Repair systems.|Restores damaged components during combat.",

	# Main Engines
	RoomData.RoomType.STANDARD_ENGINE: "Standard ion drive.|Balanced thrust and efficiency.",
	RoomData.RoomType.HIGH_THRUST_ENGINE: "Overdrive propulsion.|Maximum acceleration, high power cost.",
	RoomData.RoomType.EFFICIENT_ENGINE: "Low-consumption drive.|Extended operation, modest thrust.",
	RoomData.RoomType.ARMORED_ENGINE: "Protected propulsion.|Reinforced against damage.",

	# Maneuvering
	RoomData.RoomType.THRUSTERS: "Maneuvering thrusters.|Improves turn rate and dodging.",
	RoomData.RoomType.REACTION_CONTROL: "RCS package.|Fine attitude control.",
	RoomData.RoomType.COMBAT_THRUSTERS: "High-power RCS.|Enhanced combat maneuverability.",

	# FTL Systems
	RoomData.RoomType.JUMP_DRIVE: "Faster-than-light drive.|Enables interstellar travel.",
	RoomData.RoomType.FAST_SPOOL_DRIVE: "Quick-charge FTL.|Reduced jump preparation time.",
	RoomData.RoomType.EMERGENCY_JUMP: "Compact jump drive.|Emergency escape capability.",
	RoomData.RoomType.ARMORED_DRIVE: "Protected FTL system.|Reinforced against damage.",

	# Propulsion Specialty
	RoomData.RoomType.AFTERBURNER: "Boost system.|Temporary extreme acceleration.",
	RoomData.RoomType.GRAVITY_WELL: "FTL interdiction.|Prevents enemy jump escapes.",

	# Command
	RoomData.RoomType.AUXILIARY_CONTROL: "Backup bridge.|Secondary command center.",
	RoomData.RoomType.COMBAT_INFO_CENTER: "Tactical command.|Enhanced battle coordination.",
	RoomData.RoomType.FLAG_BRIDGE: "Fleet command center.|Coordinates multiple vessels.",

	# Sensors
	RoomData.RoomType.SENSOR_ARRAY: "Standard sensors.|Detection and tracking systems.",
	RoomData.RoomType.ADVANCED_SENSORS: "Enhanced detection.|Long-range precision tracking.",
	RoomData.RoomType.LONG_RANGE_SCANNERS: "Deep space sensors.|Extended detection range.",
	RoomData.RoomType.TARGET_PAINTER: "Weapon guidance.|Improves weapon accuracy.",

	# Computer Systems
	RoomData.RoomType.COMPUTER_CORE: "Ship's computer.|Coordinates all systems.",
	RoomData.RoomType.TACTICAL_COMPUTER: "Combat AI.|Enhances weapon targeting.",
	RoomData.RoomType.AI_CORE: "Advanced AI system.|Autonomous ship operations.",

	# Command Specialty
	RoomData.RoomType.CLOAKING_DEVICE: "Stealth field generator.|Makes ship invisible to sensors.",
	RoomData.RoomType.STEALTH_HULL: "Low-profile design.|Reduces sensor signature.",

	# Hull Components
	RoomData.RoomType.REINFORCED_HULL: "Structural reinforcement.|Strengthens hull integrity.",
	RoomData.RoomType.LIGHTWEIGHT_FRAME: "Reduced-mass structure.|Improves speed and efficiency.",

	# Compartmentalization
	RoomData.RoomType.BULKHEAD: "Internal wall.|Limits damage spread.",
	RoomData.RoomType.BLAST_DOOR: "Reinforced barrier.|Heavy-duty damage containment.",
	RoomData.RoomType.AIRLOCK: "Pressurized hatch.|Enables EVA operations.",

	# Structure Specialty
	RoomData.RoomType.DECOY_MODULE: "False signature generator.|Creates decoy targets.",
	RoomData.RoomType.STEALTH_PLATING: "Radar-absorbent material.|Reduces detection range.",
	RoomData.RoomType.SPACED_ARMOR: "Multi-layer protection.|Enhanced against projectiles."
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

	# Check tech level availability
	_update_tech_availability()

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

## Check tech level and grey out if not available
func _update_tech_availability():
	var room_tech_level = RoomData.get_tech_level(room_type)
	var current_tech_level = GameState.current_tech_level

	# If room requires higher tech level than unlocked, grey it out
	if room_tech_level > current_tech_level:
		disabled = true
		modulate = Color(0.3, 0.3, 0.3, 0.6)  # More transparent for locked components
	else:
		# Component is available
		disabled = false
		if not is_selected:
			modulate = Color(1, 1, 1)

## Handle button press
func _on_pressed():
	emit_signal("room_type_selected", room_type)

## Handle mouse entering button - start tooltip timer
func _on_mouse_entered_tooltip():
	tooltip_timer.start()

## Handle tooltip timer timeout - show tooltip
func _on_tooltip_timeout():
	# Position tooltip to the right of the button using global coordinates
	# Since top_level=true, we need to position in global space
	var button_global_pos = global_position
	var button_size = size

	# Position to the right of button with small gap
	tooltip_panel.global_position = button_global_pos + Vector2(button_size.x + 10, 0)

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
	var description = ""
	if parts.size() > 0:
		description = parts[0]

	# Add tech level requirement if locked
	var room_tech_level = RoomData.get_tech_level(room_type)
	var current_tech_level = GameState.current_tech_level
	if room_tech_level > current_tech_level:
		description += "\n\n[LOCKED - Requires Tech Level %d]" % room_tech_level

	tooltip_description_label.text = description

	# Set stats - get from JSON data dynamically
	var stats_text = _generate_stats_text()
	if stats_text != "":
		tooltip_stats_label.text = stats_text
	elif parts.size() > 1:
		# Fallback to hardcoded text if no stats found
		tooltip_stats_label.text = parts[1]

## Generate stats text from component data
func _generate_stats_text() -> String:
	var stats = RoomData.get_stats(room_type)
	if stats.is_empty():
		return ""

	var category = RoomData.get_category(room_type)
	var lines = []

	# Weapons category
	if category == ComponentCategory.Category.WEAPONS:
		if stats.has("damage"):
			lines.append("Damage: %d" % stats["damage"])
		if stats.has("fire_rate"):
			lines.append("Fire Rate: %.1fx" % stats["fire_rate"])
		if stats.has("range"):
			lines.append("Range: %s" % stats["range"])
		if stats.has("attack_type"):
			lines.append("Type: %s" % stats["attack_type"])
		if stats.has("special") and stats["special"] != "":
			lines.append("Special: %s" % stats["special"])

	# Defense category (shields and armor)
	elif category == ComponentCategory.Category.DEFENSE:
		if stats.has("absorption"):
			lines.append("Shield Absorption: %d" % stats["absorption"])
		if stats.has("recharge_rate"):
			lines.append("Recharge Rate: %d/turn" % stats["recharge_rate"])
		if stats.has("capacity"):
			lines.append("Capacity: %d" % stats["capacity"])
		if stats.has("hp_bonus"):
			lines.append("HP Bonus: +%d" % stats["hp_bonus"])
		if stats.has("damage_reduction"):
			lines.append("Damage Reduction: %d" % stats["damage_reduction"])
		if stats.has("evasion_bonus"):
			lines.append("Evasion: +%d%%" % stats["evasion_bonus"])

	# Propulsion category (engines)
	elif category == ComponentCategory.Category.PROPULSION:
		if stats.has("thrust"):
			lines.append("Thrust: %d" % stats["thrust"])
		if stats.has("dodge_chance"):
			lines.append("Dodge: +%d%%" % stats["dodge_chance"])
		if stats.has("speed"):
			lines.append("Speed: %d" % stats["speed"])
		if stats.has("jump_range"):
			lines.append("Jump Range: %d LY" % stats["jump_range"])
		if stats.has("spool_time"):
			lines.append("Spool Time: %d turns" % stats["spool_time"])

	# Command category
	elif category == ComponentCategory.Category.COMMAND_CONTROL:
		if stats.has("accuracy_bonus"):
			lines.append("Accuracy: +%d%%" % stats["accuracy_bonus"])
		if stats.has("fire_rate_bonus"):
			lines.append("Fire Rate: +%d%%" % stats["fire_rate_bonus"])
		if stats.has("damage_bonus"):
			lines.append("Damage: +%d%%" % stats["damage_bonus"])
		if stats.has("evasion_bonus"):
			lines.append("Evasion: +%d%%" % stats["evasion_bonus"])
		if stats.has("detection_range"):
			lines.append("Detection: %d" % stats["detection_range"])
		if stats.has("stealth_rating"):
			lines.append("Stealth: %d" % stats["stealth_rating"])

	# Structure category
	elif category == ComponentCategory.Category.STRUCTURE:
		if stats.has("hp_bonus"):
			lines.append("HP Bonus: +%d" % stats["hp_bonus"])
		if stats.has("damage_reduction"):
			lines.append("Damage Reduction: %d" % stats["damage_reduction"])
		if stats.has("breach_resistance"):
			lines.append("Breach Resistance: %d%%" % stats["breach_resistance"])

	return "\n".join(lines)

## Handle rotation button press (deprecated - rotation UI removed)
func _on_rotate_button_pressed():
	# Rotation UI removed in simplified layout
	pass

## Update rotation display on button (deprecated - rotation UI removed)
func update_rotation_display(rotation: int):
	# Rotation UI removed in simplified layout
	pass
