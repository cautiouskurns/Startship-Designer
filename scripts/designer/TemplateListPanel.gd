extends ColorRect

## Panel for browsing and loading templates (Phase 10.8)

signal template_selected(template: ShipTemplate)

@onready var template_list: VBoxContainer = $Panel/ScrollContainer/TemplateList
@onready var no_templates_label: Label = $Panel/NoTemplatesLabel
@onready var close_button: Button = $Panel/CloseButton
@onready var hull_filter: Label = $Panel/HullFilter

func _ready():
	# Connect close button
	close_button.pressed.connect(_on_close_pressed)

	# Listen for template changes
	TemplateManager.templates_changed.connect(_refresh_list)

## Show the panel
func show_panel():
	visible = true
	_refresh_list()

## Hide the panel
func hide_panel():
	visible = false

## Refresh the template list for current hull
func _refresh_list():
	# Clear existing list
	for child in template_list.get_children():
		child.queue_free()

	# Get templates for current hull
	var templates = TemplateManager.get_templates_for_hull(GameState.current_hull)

	# Update hull filter label
	hull_filter.text = "Showing templates for %s" % GameState.get_hull_name(GameState.current_hull)

	# Show/hide no templates message
	if templates.is_empty():
		no_templates_label.visible = true
		return
	else:
		no_templates_label.visible = false

	# Create template items
	for template in templates:
		var item = _create_template_item(template)
		template_list.add_child(item)

## Create a template item panel with load/delete buttons
func _create_template_item(template: ShipTemplate) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(700, 80)

	# Template name label
	var name_label = Label.new()
	name_label.text = template.template_name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1))
	name_label.position = Vector2(10, 10)
	name_label.size = Vector2(400, 25)
	panel.add_child(name_label)

	# Template summary label (budget, weapons, etc.)
	var summary_label = Label.new()
	summary_label.text = template.get_summary()
	summary_label.add_theme_font_size_override("font_size", 14)
	summary_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	summary_label.position = Vector2(10, 35)
	summary_label.size = Vector2(400, 20)
	panel.add_child(summary_label)

	# Created date label
	var date_label = Label.new()
	date_label.text = "Created: %s" % template.created_date.split("T")[0]  # Show just date, not time
	date_label.add_theme_font_size_override("font_size", 12)
	date_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	date_label.position = Vector2(10, 55)
	date_label.size = Vector2(400, 20)
	panel.add_child(date_label)

	# Load button
	var load_button = Button.new()
	load_button.text = "LOAD"
	load_button.add_theme_font_size_override("font_size", 16)
	load_button.position = Vector2(520, 15)
	load_button.size = Vector2(80, 50)
	load_button.pressed.connect(_on_load_template.bind(template))
	panel.add_child(load_button)

	# Delete button
	var delete_button = Button.new()
	delete_button.text = "DELETE"
	delete_button.add_theme_font_size_override("font_size", 16)
	delete_button.add_theme_color_override("font_color", Color(0.886, 0.290, 0.290))
	delete_button.position = Vector2(610, 15)
	delete_button.size = Vector2(80, 50)
	delete_button.pressed.connect(_on_delete_template.bind(template))
	panel.add_child(delete_button)

	return panel

func _on_load_template(template: ShipTemplate):
	template_selected.emit(template)
	hide_panel()

func _on_delete_template(template: ShipTemplate):
	# Delete from manager
	TemplateManager.delete_player_template(template.template_name)
	# List will refresh automatically via signal

func _on_close_pressed():
	hide_panel()
