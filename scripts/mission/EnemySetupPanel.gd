extends ColorRect

## Panel for assigning enemy templates to missions (Phase 10.8)

@onready var mission_rows = [
	$Panel/Mission0Row,
	$Panel/Mission1Row,
	$Panel/Mission2Row
]

@onready var status_labels = [
	$Panel/Mission0Row/StatusLabel,
	$Panel/Mission1Row/StatusLabel,
	$Panel/Mission2Row/StatusLabel
]

@onready var assign_buttons = [
	$Panel/Mission0Row/AssignButton,
	$Panel/Mission1Row/AssignButton,
	$Panel/Mission2Row/AssignButton
]

@onready var clear_buttons = [
	$Panel/Mission0Row/ClearButton,
	$Panel/Mission1Row/ClearButton,
	$Panel/Mission2Row/ClearButton
]

@onready var close_button: Button = $Panel/CloseButton
@onready var template_selector: Panel = $Panel/TemplateSelector
@onready var selector_title: Label = $Panel/TemplateSelector/SelectorTitle
@onready var template_list: VBoxContainer = $Panel/TemplateSelector/TemplateList

var current_mission_for_selector: int = -1

func _ready():
	# Connect close button
	close_button.pressed.connect(_on_close_pressed)

	# Connect mission buttons
	for i in range(3):
		assign_buttons[i].pressed.connect(_on_assign_pressed.bind(i))
		clear_buttons[i].pressed.connect(_on_clear_pressed.bind(i))

	# Listen for enemy assignment changes
	TemplateManager.enemy_assignments_changed.connect(_refresh_display)
	TemplateManager.templates_changed.connect(_refresh_display)

## Show the panel
func show_panel():
	visible = true
	template_selector.visible = false
	_refresh_display()

## Hide the panel
func hide_panel():
	visible = false
	template_selector.visible = false

## Refresh display for all missions
func _refresh_display():
	for mission_index in range(3):
		_update_mission_status(mission_index)

## Update status label for a mission
func _update_mission_status(mission_index: int):
	var assignment = TemplateManager.get_enemy_assignment(mission_index)

	if assignment.is_empty():
		# No assignment - auto-generated
		status_labels[mission_index].text = "Auto-Generated"
		status_labels[mission_index].add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		clear_buttons[mission_index].disabled = true
	else:
		# Template assigned
		var template = TemplateManager.get_player_template(assignment)
		if template:
			status_labels[mission_index].text = "Template: %s (%s)" % [template.template_name, GameState.get_hull_name(template.hull_type)]
			status_labels[mission_index].add_theme_color_override("font_color", Color(0.290, 0.886, 0.886))  # Cyan
		else:
			# Template not found (deleted?)
			status_labels[mission_index].text = "Template not found!"
			status_labels[mission_index].add_theme_color_override("font_color", Color(0.886, 0.290, 0.290))  # Red

		clear_buttons[mission_index].disabled = false

## Handle assign button press
func _on_assign_pressed(mission_index: int):
	current_mission_for_selector = mission_index

	# Show template selector
	selector_title.text = "Select template for %s:" % GameState.get_mission_name(mission_index)
	template_selector.visible = true

	# Populate template list
	_populate_template_list()

## Handle clear button press
func _on_clear_pressed(mission_index: int):
	TemplateManager.clear_enemy_assignment(mission_index)

## Populate template selector with all available templates
func _populate_template_list():
	# Clear existing list
	for child in template_list.get_children():
		child.queue_free()

	# Get all player templates
	var templates = TemplateManager.get_player_templates()

	if templates.is_empty():
		var no_templates = Label.new()
		no_templates.text = "No templates saved. Create templates in Ship Designer first."
		no_templates.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		no_templates.add_theme_font_size_override("font_size", 14)
		no_templates.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		template_list.add_child(no_templates)
		return

	# Create button for each template
	for template in templates:
		var template_button = Button.new()
		template_button.text = "%s - %s" % [template.template_name, template.get_summary()]
		template_button.add_theme_font_size_override("font_size", 14)
		template_button.custom_minimum_size = Vector2(800, 40)
		template_button.pressed.connect(_on_template_selected.bind(template.template_name))
		template_list.add_child(template_button)

## Handle template selection
func _on_template_selected(template_name: String):
	if current_mission_for_selector >= 0:
		TemplateManager.set_enemy_assignment(current_mission_for_selector, template_name)
		template_selector.visible = false
		current_mission_for_selector = -1

func _on_close_pressed():
	hide_panel()
