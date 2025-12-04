extends Panel
class_name RoomPalettePanel

## Panel containing room type selection buttons with category filtering

signal room_type_selected(room_type: RoomData.RoomType)
signal rotation_requested  # Phase 7.3 - emitted when rotation button is pressed

## References to category tab buttons
@onready var power_tab: Button = $VBoxContainer/TabsMargin/CategoryTabBar/PowerTab
@onready var weapons_tab: Button = $VBoxContainer/TabsMargin/CategoryTabBar/WeaponsTab
@onready var defense_tab: Button = $VBoxContainer/TabsMargin/CategoryTabBar/DefenseTab
@onready var propulsion_tab: Button = $VBoxContainer/TabsMargin/CategoryTabBar/PropulsionTab
@onready var command_tab: Button = $VBoxContainer/TabsMargin/CategoryTabBar/CommandTab
@onready var utility_tab: Button = $VBoxContainer/TabsMargin/CategoryTabBar/UtilityTab
@onready var structure_tab: Button = $VBoxContainer/TabsMargin/CategoryTabBar/StructureTab

## References to category header labels
@onready var category_name_label: Label = $VBoxContainer/CategoryHeaderMargin/CategoryHeader/PaddingMargin/VBoxContainer/CategoryNameLabel
@onready var category_desc_label: Label = $VBoxContainer/CategoryHeaderMargin/CategoryHeader/PaddingMargin/VBoxContainer/CategoryDescLabel

## Container for dynamically generated buttons
@onready var buttons_container: VBoxContainer = $VBoxContainer/ButtonsMargin/ScrollContainer/ButtonsContainer

## Track currently selected button
var selected_button: RoomTypeButton = null

## All buttons for easy iteration (dynamically populated)
var all_buttons: Array[RoomTypeButton] = []

## Reference to RoomTypeButton scene for instantiation
const RoomTypeButtonScene = preload("res://scenes/designer/components/RoomTypeButton.tscn")

## Category tab buttons array for easy iteration
var category_tabs: Array[Button] = []

## Current active category (Feature 01: Seven-Category Structure)
var current_category: ComponentCategory.Category = ComponentCategory.Category.POWER_SYSTEMS

func _ready():
	category_tabs = [power_tab, weapons_tab, defense_tab, propulsion_tab, command_tab, utility_tab, structure_tab]

	# Connect category tab button signals (Feature 01: Seven-Category Structure)
	power_tab.pressed.connect(_on_category_tab_pressed.bind(ComponentCategory.Category.POWER_SYSTEMS))
	weapons_tab.pressed.connect(_on_category_tab_pressed.bind(ComponentCategory.Category.WEAPONS))
	defense_tab.pressed.connect(_on_category_tab_pressed.bind(ComponentCategory.Category.DEFENSE))
	propulsion_tab.pressed.connect(_on_category_tab_pressed.bind(ComponentCategory.Category.PROPULSION))
	command_tab.pressed.connect(_on_category_tab_pressed.bind(ComponentCategory.Category.COMMAND_CONTROL))
	utility_tab.pressed.connect(_on_category_tab_pressed.bind(ComponentCategory.Category.UTILITY_SUPPORT))
	structure_tab.pressed.connect(_on_category_tab_pressed.bind(ComponentCategory.Category.STRUCTURE))

	# Apply initial category filter (show Power Systems by default)
	filter_by_category(current_category)

## Handle room type button press
func _on_room_type_button_pressed(room_type: RoomData.RoomType):
	# Update selection highlights
	for button in all_buttons:
		button.set_selected(button.room_type == room_type)

	# Track selected button
	for button in all_buttons:
		if button.room_type == room_type:
			selected_button = button
			break

	# Forward signal
	emit_signal("room_type_selected", room_type)

## Update room counts for all buttons
func update_counts(counts: Dictionary):
	for button in all_buttons:
		var count = counts.get(button.room_type, 0)
		button.set_count(count)

## Update button availability based on what can be placed
func update_availability(available_types: Array):
	for button in all_buttons:
		var is_available = button.room_type in available_types
		button.set_available(is_available)

## Clear selection (deselect all buttons)
func clear_selection():
	for button in all_buttons:
		button.set_selected(false)
	selected_button = null

## Get currently selected room type
func get_selected_room_type() -> RoomData.RoomType:
	if selected_button:
		return selected_button.room_type
	return RoomData.RoomType.EMPTY

## Handle rotation button press (Phase 7.3)
func _on_rotation_button_pressed(room_type: RoomData.RoomType):
	# Forward rotation signal to ShipDesigner
	emit_signal("rotation_requested")

## Update rotation display on selected button (Phase 7.3)
func update_rotation_display(rotation: int):
	# Update rotation display on the currently selected button
	if selected_button:
		selected_button.update_rotation_display(rotation)

## Handle category tab press (Feature 01: Seven-Category Structure)
func _on_category_tab_pressed(category: ComponentCategory.Category):
	filter_by_category(category)

## Filter room type buttons by category (Feature 01: Seven-Category Structure)
func filter_by_category(category: ComponentCategory.Category):
	current_category = category

	# Clear existing buttons
	_clear_buttons()

	# Generate buttons for this category
	_generate_buttons_for_category(category)

	# Update category header display
	_update_category_header(category)

	# Update tab visual states
	_update_tab_styles(category)

## Clear all dynamically generated buttons
func _clear_buttons():
	# Disconnect and remove all existing buttons
	for button in all_buttons:
		if button.room_type_selected.is_connected(_on_room_type_button_pressed):
			button.room_type_selected.disconnect(_on_room_type_button_pressed)
		if button.rotation_requested.is_connected(_on_rotation_button_pressed):
			button.rotation_requested.disconnect(_on_rotation_button_pressed)
		button.queue_free()

	all_buttons.clear()
	selected_button = null

## Generate buttons for all room types in the given category
func _generate_buttons_for_category(category: ComponentCategory.Category):
	# Get all room types in this category
	var room_types_in_category: Array[RoomData.RoomType] = []

	# Iterate through all room types from RoomData enum
	# We'll check each type in the labels dictionary (which has all defined types)
	for room_type in RoomData.labels.keys():
		# Skip EMPTY
		if room_type == RoomData.RoomType.EMPTY:
			continue

		var room_category = RoomData.get_category(room_type)
		if room_category == category:
			room_types_in_category.append(room_type)

	# Create a button for each room type
	for room_type in room_types_in_category:
		var button: RoomTypeButton = RoomTypeButtonScene.instantiate()
		button.room_type = room_type

		# Connect signals
		button.room_type_selected.connect(_on_room_type_button_pressed)
		button.rotation_requested.connect(_on_rotation_button_pressed)

		# Add to container
		buttons_container.add_child(button)
		all_buttons.append(button)

## Update category header labels (Feature 01: Seven-Category Structure)
func _update_category_header(category: ComponentCategory.Category):
	var display_name = ComponentCategory.get_category_display_name(category)
	var description = ComponentCategory.get_category_description(category)
	var color = ComponentCategory.get_category_color(category)

	category_name_label.text = display_name
	category_name_label.add_theme_color_override("font_color", color)
	category_desc_label.text = description

## Update tab button styles to show active tab (Feature 01: Seven-Category Structure)
func _update_tab_styles(active_category: ComponentCategory.Category):
	# Get style resources
	var active_style = get_theme_stylebox("normal", "Button").duplicate() if power_tab.has_theme_stylebox_override("normal") else null
	var inactive_style = get_theme_stylebox("normal", "Button").duplicate() if weapons_tab.has_theme_stylebox_override("normal") else null

	# Map categories to their tab buttons
	var category_to_tab = {
		ComponentCategory.Category.POWER_SYSTEMS: power_tab,
		ComponentCategory.Category.WEAPONS: weapons_tab,
		ComponentCategory.Category.DEFENSE: defense_tab,
		ComponentCategory.Category.PROPULSION: propulsion_tab,
		ComponentCategory.Category.COMMAND_CONTROL: command_tab,
		ComponentCategory.Category.UTILITY_SUPPORT: utility_tab,
		ComponentCategory.Category.STRUCTURE: structure_tab
	}

	# Update each tab's style based on whether it's active
	for cat in category_to_tab.keys():
		var tab = category_to_tab[cat]
		if cat == active_category:
			# Active tab - use active style from scene
			tab.add_theme_stylebox_override("normal", tab.get_theme_stylebox("normal"))
		else:
			# Inactive tab - already set in scene
			pass
