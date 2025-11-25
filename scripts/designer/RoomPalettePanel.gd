extends Panel
class_name RoomPalettePanel

## Panel containing room type selection buttons

signal room_type_selected(room_type: RoomData.RoomType)
signal rotation_requested  # Phase 7.3 - emitted when rotation button is pressed

## References to room type buttons
@onready var bridge_button: RoomTypeButton = $VBoxContainer/BridgeButton
@onready var weapon_button: RoomTypeButton = $VBoxContainer/WeaponButton
@onready var shield_button: RoomTypeButton = $VBoxContainer/ShieldButton
@onready var engine_button: RoomTypeButton = $VBoxContainer/EngineButton
@onready var reactor_button: RoomTypeButton = $VBoxContainer/ReactorButton
@onready var armor_button: RoomTypeButton = $VBoxContainer/ArmorButton
@onready var conduit_button: RoomTypeButton = $VBoxContainer/ConduitButton
@onready var relay_button: RoomTypeButton = $VBoxContainer/RelayButton  # Feature 1.2

## Track currently selected button
var selected_button: RoomTypeButton = null

## All buttons for easy iteration
var all_buttons: Array[RoomTypeButton] = []

func _ready():
	all_buttons = [bridge_button, weapon_button, shield_button, engine_button, reactor_button, armor_button, conduit_button, relay_button]  # Feature 1.2: Added relay_button

	# Connect signals from all buttons
	for button in all_buttons:
		button.room_type_selected.connect(_on_room_type_button_pressed)
		button.rotation_requested.connect(_on_rotation_button_pressed)  # Phase 7.3

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
