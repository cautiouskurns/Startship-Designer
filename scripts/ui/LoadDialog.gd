extends Panel

## LoadDialog
## Modal dialog for loading and managing saved ship designs

## Signals
signal design_loaded(design: SaveManager.ShipDesign)
signal cancelled()

## Node references
@onready var title_label = $MarginContainer/VBoxContainer/Title
@onready var scroll_container = $MarginContainer/VBoxContainer/ScrollContainer
@onready var design_list = $MarginContainer/VBoxContainer/ScrollContainer/DesignList
@onready var delete_button = $MarginContainer/VBoxContainer/ButtonContainer/DeleteButton
@onready var cancel_button = $MarginContainer/VBoxContainer/ButtonContainer/CancelButton
@onready var load_button = $MarginContainer/VBoxContainer/ButtonContainer/LoadButton
@onready var no_designs_label = $MarginContainer/VBoxContainer/NoDesignsLabel

## Design entry scene (created dynamically)
const DESIGN_ENTRY_SCENE = preload("res://scenes/ui/DesignEntry.tscn")

## State
var selected_design: SaveManager.ShipDesign = null
var design_entries: Array = []

func _ready():
	# Connect signals
	delete_button.pressed.connect(_on_delete_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	load_button.pressed.connect(_on_load_pressed)

	# Initial state
	delete_button.disabled = true
	load_button.disabled = true
	no_designs_label.hide()

	# Load designs
	_refresh_design_list()

	# Animate appearance
	modulate.a = 0
	scale = Vector2(0.9, 0.9)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Refresh the list of saved designs
func _refresh_design_list():
	# Clear existing entries
	for entry in design_entries:
		entry.queue_free()
	design_entries.clear()

	# Get saved designs from SaveManager
	var designs = SaveManager.get_saved_designs()

	if designs.is_empty():
		no_designs_label.text = "No saved designs found"
		no_designs_label.show()
		scroll_container.hide()
		delete_button.disabled = true
		load_button.disabled = true
		return

	no_designs_label.hide()
	scroll_container.show()

	# Create entry for each design
	for design in designs:
		var entry = _create_design_entry(design)
		design_list.add_child(entry)
		design_entries.append(entry)

## Create a design entry UI element
func _create_design_entry(design: SaveManager.ShipDesign) -> Control:
	# Create a PanelContainer for the entry
	var entry = PanelContainer.new()
	entry.custom_minimum_size = Vector2(450, 60)

	# Add a margin container
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	entry.add_child(margin)

	# Create HBoxContainer for layout
	var hbox = HBoxContainer.new()
	margin.add_child(hbox)

	# Icon (simple label for now, could be actual icon later)
	var icon = Label.new()
	icon.text = "📋"
	icon.add_theme_font_size_override("font_size", 24)
	hbox.add_child(icon)

	# Add spacing
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(10, 0)
	hbox.add_child(spacer1)

	# Info VBox
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	# Design name
	var name_label = Label.new()
	name_label.text = design.design_name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_label)

	# Details (mission, budget, date)
	var details_label = Label.new()
	var mission_name = GameState.get_mission_name(design.mission_index)
	details_label.text = "M%d: %s | %d pts | %s" % [
		design.mission_index + 1,
		mission_name,
		design.budget_used,
		_format_date(design.last_modified)
	]
	details_label.add_theme_font_size_override("font_size", 12)
	details_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(details_label)

	# Make entry clickable
	var button = Button.new()
	button.flat = true
	button.custom_minimum_size = entry.custom_minimum_size
	entry.add_child(button)
	button.mouse_filter = Control.MOUSE_FILTER_PASS

	# Store design reference in metadata
	entry.set_meta("design", design)
	entry.set_meta("button", button)

	# Connect click signal
	button.pressed.connect(_on_entry_selected.bind(entry))

	return entry

## Format timestamp for display
func _format_date(timestamp: String) -> String:
	if timestamp.is_empty():
		return "Unknown"

	# Simplified date formatting (just show date, not time)
	# Timestamp format from Godot: "2024-12-08T15:30:45"
	if timestamp.length() >= 10:
		return timestamp.substr(0, 10)  # Return "2024-12-08"
	return timestamp

## Event handlers
func _on_entry_selected(entry: Control):
	# Deselect previous entry
	for e in design_entries:
		var panel = e as PanelContainer
		if panel:
			var stylebox = StyleBoxFlat.new()
			stylebox.bg_color = Color(0.17, 0.17, 0.17)  # #2C2C2C
			panel.add_theme_stylebox_override("panel", stylebox)

	# Highlight selected entry
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.24, 0.24, 0.24)  # #3C3C3C (lighter)
	stylebox.border_width_all = 2
	stylebox.border_color = Color(0.29, 0.88, 0.88)  # Cyan #4AE2E2
	entry.add_theme_stylebox_override("panel", stylebox)

	# Store selected design
	selected_design = entry.get_meta("design")

	# Enable buttons
	delete_button.disabled = false
	load_button.disabled = false

func _on_load_pressed():
	if not selected_design:
		return

	design_loaded.emit(selected_design)
	_close_dialog()

func _on_delete_pressed():
	if not selected_design:
		return

	# Simple confirmation (could add a confirmation dialog later)
	var confirmed = true  # TODO: Add confirmation dialog

	if confirmed:
		var success = SaveManager.delete_design(selected_design.design_name)
		if success:
			selected_design = null
			_refresh_design_list()

func _on_cancel_pressed():
	cancelled.emit()
	_close_dialog()

## Close dialog with animation
func _close_dialog():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.15)
	await tween.finished
	queue_free()
