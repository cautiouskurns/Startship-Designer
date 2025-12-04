extends Panel
class_name RadioChatterBox

## Radio Chatter Box UI - displays crew barks in top-right corner
## Part of Phase 1.3: UI Presentation
## Handles fade-in, display, and fade-out animations for crew barks

signal bark_display_complete()

## Label references (will be set in _ready if children exist, or created dynamically)
var role_label: Label = null
var bark_label: Label = null
var margin_container: MarginContainer = null
var hbox_container: HBoxContainer = null

## Animation state
var display_tween: Tween = null
var is_displaying: bool = false

## Display timings (in seconds)
const FADE_IN_DURATION = 0.3
const DISPLAY_DURATION = 3.0
const FADE_OUT_DURATION = 0.5

## Bark queue (if multiple barks arrive during display)
var bark_queue: Array[BarkData] = []

## Debug/test mode (set to false to disable test bark)
var debug_mode: bool = false

func _ready():
	print("[RadioChatterBox] === INITIALIZING ===")
	print("[RadioChatterBox] Panel size: %s" % size)
	print("[RadioChatterBox] Panel position: %s" % position)
	print("[RadioChatterBox] Panel visible: %s" % visible)

	# Set up visual styling
	_setup_style()

	# Create UI structure if not already in scene
	_setup_ui_structure()

	# Force layout update after one frame
	await get_tree().process_frame
	_force_layout_update()

	# Connect to bark system
	if CrewBarkSystem:
		CrewBarkSystem.bark_triggered.connect(_on_bark_triggered)
		print("[RadioChatterBox] ✓ Connected to CrewBarkSystem")
		print("[RadioChatterBox] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("[RadioChatterBox] 📻 CREW BARKS SYSTEM READY")
		print("[RadioChatterBox] To see barks: LET THE ENEMY DAMAGE YOUR SHIP!")
		print("[RadioChatterBox] - Lose shields → 'Shields are down!'")
		print("[RadioChatterBox] - Lose weapons → 'Weapons offline!'")
		print("[RadioChatterBox] - HP below 75% → 'Hull integrity compromised!'")
		print("[RadioChatterBox] - HP below 50% → 'We can't take much more!'")
		print("[RadioChatterBox] - HP below 25% → 'Critical damage!'")
		print("[RadioChatterBox] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	else:
		push_error("[RadioChatterBox] ✗ CrewBarkSystem not found!")

	# TEST MODE: Show a test bark after 2 seconds to verify visibility
	if debug_mode:
		print("[RadioChatterBox] Debug mode enabled - will show test bark in 2 seconds")
		await get_tree().create_timer(2.0).timeout
		_show_test_bark()
	else:
		# Initial state: hidden
		visible = false
		modulate.a = 0.0

## Set up panel styling
func _setup_style():
	# Create StyleBoxFlat for background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.059, 0.078, 0.098, 0.90)  # #0F1419 at 90% opacity
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.29, 0.89, 0.89, 1.0)  # Cyan #4AE2E2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.shadow_size = 2
	style.shadow_color = Color(0, 0, 0, 0.5)

	add_theme_stylebox_override("panel", style)

## Set up UI structure (labels, containers)
func _setup_ui_structure():
	# Check if structure already exists (from scene)
	margin_container = get_node_or_null("MarginContainer")

	if not margin_container:
		# Create structure dynamically
		margin_container = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_left", 10)
		margin_container.add_theme_constant_override("margin_right", 10)
		margin_container.add_theme_constant_override("margin_top", 10)
		margin_container.add_theme_constant_override("margin_bottom", 10)
		# Set anchors to fill parent
		margin_container.anchor_left = 0.0
		margin_container.anchor_top = 0.0
		margin_container.anchor_right = 1.0
		margin_container.anchor_bottom = 1.0
		margin_container.offset_left = 0.0
		margin_container.offset_top = 0.0
		margin_container.offset_right = 0.0
		margin_container.offset_bottom = 0.0
		add_child(margin_container)

		hbox_container = HBoxContainer.new()
		hbox_container.add_theme_constant_override("separation", 5)
		hbox_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		margin_container.add_child(hbox_container)

		# Role label
		role_label = Label.new()
		role_label.add_theme_color_override("font_color", Color(0.29, 0.89, 0.89, 1.0))  # Cyan
		role_label.add_theme_font_size_override("font_size", 18)  # Larger for visibility
		role_label.add_theme_constant_override("outline_size", 2)  # Add outline
		role_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))  # Black outline
		role_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		role_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		hbox_container.add_child(role_label)

		# Bark label
		bark_label = Label.new()
		bark_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))  # White
		bark_label.add_theme_font_size_override("font_size", 20)  # Larger for visibility
		bark_label.add_theme_constant_override("outline_size", 2)  # Add outline
		bark_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))  # Black outline
		bark_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bark_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		bark_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bark_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		bark_label.custom_minimum_size = Vector2(200, 0)  # Ensure minimum width
		hbox_container.add_child(bark_label)

		print("[RadioChatterBox] Created dynamic UI structure with labels")
	else:
		# Get existing structure
		hbox_container = margin_container.get_node_or_null("HBoxContainer")
		if hbox_container:
			role_label = hbox_container.get_node_or_null("RoleLabel")
			bark_label = hbox_container.get_node_or_null("BarkLabel")
		print("[RadioChatterBox] Using existing scene UI structure")

## Force layout update to ensure containers fill the panel
func _force_layout_update():
	if margin_container:
		# Explicitly set size to match panel
		margin_container.size = size
		print("[RadioChatterBox] Forced margin_container size to: %s" % size)

	if hbox_container:
		print("[RadioChatterBox] HBox size: %s" % hbox_container.size)

	if role_label:
		print("[RadioChatterBox] Role label size: %s" % role_label.size)

	if bark_label:
		print("[RadioChatterBox] Bark label size: %s" % bark_label.size)

## Signal handler: bark triggered
func _on_bark_triggered(bark: BarkData):
	if is_displaying:
		# Queue bark for later display
		bark_queue.append(bark)
		print("[RadioChatterBox] Bark queued (currently displaying)")
	else:
		# Display immediately
		_display_bark(bark)

## Display a bark with fade animation
func _display_bark(bark: BarkData):
	if not bark:
		print("[RadioChatterBox] Warning: Received null bark!")
		return

	# Cancel existing tween
	if display_tween:
		display_tween.kill()

	# Set content
	if role_label:
		role_label.text = "[%s]" % BarkData.role_to_string(bark.role)
		print("[RadioChatterBox] Set role_label text: %s (size: %s)" % [role_label.text, role_label.size])
	else:
		print("[RadioChatterBox] Warning: role_label is null!")

	if bark_label:
		bark_label.text = bark.text
		print("[RadioChatterBox] Set bark_label text: %s (size: %s)" % [bark_label.text, bark_label.size])
	else:
		print("[RadioChatterBox] Warning: bark_label is null!")

	# Mark as displaying
	is_displaying = true

	# Reset state
	visible = true
	modulate.a = 0.0

	print("[RadioChatterBox] Displaying bark: [%s] '%s' - Panel size: %s, visible: %s" % [BarkData.role_to_string(bark.role), bark.text, size, visible])

	# Create fade sequence
	display_tween = create_tween()

	# Fade in (0.3s)
	display_tween.tween_property(self, "modulate:a", 1.0, FADE_IN_DURATION).set_ease(Tween.EASE_OUT)

	# Hold (3.0s)
	display_tween.tween_interval(DISPLAY_DURATION)

	# Fade out (0.5s)
	display_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_DURATION).set_ease(Tween.EASE_IN)

	# Complete callback
	display_tween.tween_callback(_on_display_complete)

	# Add to combat log
	_add_to_combat_log(bark)

## Called when display animation completes
func _on_display_complete():
	visible = false
	is_displaying = false
	bark_display_complete.emit()

	print("[RadioChatterBox] Display complete")

	# Process queue if barks are waiting
	if not bark_queue.is_empty():
		var next_bark = bark_queue.pop_front()
		print("[RadioChatterBox] Processing queued bark (%d remaining)" % bark_queue.size())
		_display_bark(next_bark)

## Add bark to combat log
func _add_to_combat_log(bark: BarkData):
	# Find CombatLog in parent tree
	var combat_node = get_parent()
	while combat_node and not combat_node.name == "Combat":
		combat_node = combat_node.get_parent()

	if not combat_node:
		print("[RadioChatterBox] Warning: Could not find Combat node for logging")
		return

	var combat_log = combat_node.get_node_or_null("CombatLog")
	if combat_log and combat_log.has_method("add_bark_entry"):
		var current_turn = combat_node.turn_count if "turn_count" in combat_node else 0
		combat_log.add_bark_entry(current_turn, BarkData.role_to_string(bark.role), bark.text)
	else:
		print("[RadioChatterBox] Warning: CombatLog not found or doesn't have add_bark_entry method")

## Clear queue (called on battle end)
func clear_queue():
	bark_queue.clear()
	if display_tween:
		display_tween.kill()
	visible = false
	modulate.a = 0.0
	is_displaying = false

## TEST: Show a test bark to verify everything works
func _show_test_bark():
	print("[RadioChatterBox] === SHOWING TEST BARK ===")

	# Create a test bark
	var test_bark = BarkData.create(
		"TEST: Radio chatter system online!",
		BarkData.CrewRole.OPERATIONS,
		BarkData.BarkPriority.HIGH,
		BarkData.BarkCategory.SYSTEM_STATUS
	)

	# Display it
	_display_bark(test_bark)

	print("[RadioChatterBox] Test bark display initiated")
	print("[RadioChatterBox] Panel visible: %s, modulate: %s" % [visible, modulate])
	print("[RadioChatterBox] Panel global_position: %s" % global_position)
