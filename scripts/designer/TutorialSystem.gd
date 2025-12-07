extends Node
class_name TutorialSystem

## Manages tutorial sequence and state for first-time players
## Shows sequential popup instructions for Mission 1

signal tutorial_completed
signal tutorial_skipped

## Tutorial state
var current_step: int = 0
var total_steps: int = 12
var is_active: bool = false
var is_skipped: bool = false

## References
var ship_designer: Control = null
var tutorial_popup: TutorialPopup = null

## Tutorial step definitions
var tutorial_steps: Array[Dictionary] = []

## Preload popup scene
const TutorialPopupScene = preload("res://scenes/designer/components/TutorialPopup.tscn")

func _ready():
	# Setup tutorial step data
	_setup_step_data()

## Start tutorial from step 1
func start_tutorial(designer: Control):
	ship_designer = designer
	is_active = true
	is_skipped = false
	current_step = 0

	print("Tutorial started")

	# Create tutorial popup instance
	tutorial_popup = TutorialPopupScene.instantiate()
	tutorial_popup.skip_requested.connect(_on_skip_requested)
	tutorial_popup.acknowledged.connect(_on_popup_acknowledged)
	tutorial_popup.continue_pressed.connect(_on_continue_pressed)
	add_child(tutorial_popup)

	# Show first step
	show_step(0)

## Show specific tutorial step
func show_step(step_num: int):
	if step_num < 0 or step_num >= tutorial_steps.size():
		# All steps complete
		_complete_tutorial()
		return

	current_step = step_num
	var step_data = tutorial_steps[step_num]

	print("Tutorial: Showing step %d - %s" % [step_num + 1, step_data["title"]])

	# Get target node if path provided (can be Control or Node2D)
	var target_node: Node = null
	if step_data.has("target_path") and step_data["target_path"] != "":
		target_node = ship_designer.get_node_or_null(step_data["target_path"])
		if not target_node:
			push_warning("Tutorial step %d: Target node not found: %s" % [step_num, step_data["target_path"]])

	# Setup and show popup
	tutorial_popup.setup(
		step_num + 1,  # 1-indexed for display
		step_data["title"],
		step_data["message"],
		target_node,
		step_data.get("arrow", TutorialPopup.ArrowDirection.NONE),
		step_data.get("wait_for", "")
	)

	tutorial_popup.show_popup()

## Advance to next step
func advance_step():
	show_step(current_step + 1)

## Check if event completes current step
func check_step_completion(event: String):
	if not is_active or is_skipped:
		return

	if tutorial_popup and tutorial_popup.check_completion(event):
		print("Tutorial: Step %d completed with event: %s" % [current_step + 1, event])
		# Hide current popup
		await tutorial_popup.hide_popup()
		# Advance to next step
		advance_step()

## Skip tutorial entirely
func skip_tutorial():
	if is_skipped:
		return

	print("Tutorial skipped by player")
	is_skipped = true
	is_active = false

	# Hide popup
	if tutorial_popup:
		tutorial_popup.hide_popup()

	# Emit signal
	tutorial_skipped.emit()

## Complete tutorial successfully
func _complete_tutorial():
	print("Tutorial completed!")
	is_active = false

	# Hide popup
	if tutorial_popup:
		tutorial_popup.hide_popup()

	# Emit signal
	tutorial_completed.emit()

## Handle skip button pressed
func _on_skip_requested():
	skip_tutorial()

## Handle popup acknowledged (for simple steps)
func _on_popup_acknowledged():
	check_step_completion("popup_acknowledged")

## Handle continue button pressed
func _on_continue_pressed():
	check_step_completion("popup_acknowledged")

## Define all 12 tutorial steps
func _setup_step_data():
	tutorial_steps = [
		# Step 1: Welcome
		{
			"title": "Welcome to Starship Designer",
			"message": "You are the chief engineer. Your mission: Build a ship to defeat enemy raiders in auto-battle.\n\nClick 'Continue' to begin your tutorial.",
			"target_path": "",
			"arrow": TutorialPopup.ArrowDirection.NONE,
			"wait_for": "popup_acknowledged"
		},

		# Step 2: Grid Introduction
		{
			"title": "Ship Construction Grid",
			"message": "This is your ship grid. Each square can hold one component tile.\n\nComponents work together to create a functional warship.",
			"target_path": "ShipGrid",
			"arrow": TutorialPopup.ArrowDirection.DOWN,
			"wait_for": "popup_acknowledged"
		},

		# Step 3: Power Tab
		{
			"title": "Power Systems",
			"message": "First, we need power! Click the 'POWER SYSTEMS' tab to see power components.\n\n(Look for the tab on the left side of the screen)",
			"target_path": "RoomPalettePanel/VBoxContainer/TabsMargin/CategoryTabBar/PowerTab",
			"arrow": TutorialPopup.ArrowDirection.RIGHT,
			"wait_for": "power_tab_clicked"
		},

		# Step 4: Select Reactor
		{
			"title": "Select Reactor",
			"message": "Click on a REACTOR component to select it.\n\nReactors power adjacent tiles (up/down/left/right) with green energy lines.",
			"target_path": "RoomPalettePanel",
			"arrow": TutorialPopup.ArrowDirection.RIGHT,
			"wait_for": "reactor_selected"
		},

		# Step 5: Place Reactor
		{
			"title": "Place Reactor",
			"message": "Now click any tile on the grid to place the reactor.\n\nWatch for the green power lines showing which tiles are powered!",
			"target_path": "ShipGrid",
			"arrow": TutorialPopup.ArrowDirection.DOWN,
			"wait_for": "reactor_placed"
		},

		# Step 6: Command Tab
		{
			"title": "Command Systems",
			"message": "Great! Power is online. Now we need command systems.\n\nClick the 'COMMAND & CONTROL' tab.",
			"target_path": "RoomPalettePanel/VBoxContainer/TabsMargin/CategoryTabBar/CommandTab",
			"arrow": TutorialPopup.ArrowDirection.RIGHT,
			"wait_for": "command_tab_clicked"
		},

		# Step 7: Place Bridge
		{
			"title": "Place Bridge",
			"message": "Every ship needs a BRIDGE (2×2 size).\n\nSelect and place it ADJACENT to the reactor so it has power (green glow).\n\nYou need a powered Bridge to launch!",
			"target_path": "RoomPalettePanel",
			"arrow": TutorialPopup.ArrowDirection.RIGHT,
			"wait_for": "bridge_placed"
		},

		# Step 8: Weapons Tab
		{
			"title": "Offensive Systems",
			"message": "Time to add firepower!\n\nClick the 'WEAPONS' tab to see offensive systems.",
			"target_path": "RoomPalettePanel/VBoxContainer/TabsMargin/CategoryTabBar/WeaponsTab",
			"arrow": TutorialPopup.ArrowDirection.RIGHT,
			"wait_for": "weapons_tab_clicked"
		},

		# Step 9: Place Weapon
		{
			"title": "Place Weapon",
			"message": "Select a weapon and place it in a powered tile (green glow).\n\nWeapons can only go in FORWARD columns (right side of grid).",
			"target_path": "RoomPalettePanel",
			"arrow": TutorialPopup.ArrowDirection.RIGHT,
			"wait_for": "weapon_placed"
		},

		# Step 10: Defense Tab & Shield
		{
			"title": "Defensive Systems",
			"message": "Add defense! Click the 'DEFENSE' tab, select a SHIELD, and place it in a powered tile.\n\nShields absorb damage before your hull takes hits.",
			"target_path": "RoomPalettePanel/VBoxContainer/TabsMargin/CategoryTabBar/DefenseTab",
			"arrow": TutorialPopup.ArrowDirection.RIGHT,
			"wait_for": "shield_placed"
		},

		# Step 11: Budget Panel
		{
			"title": "Build Points Budget",
			"message": "Watch your Build Points (BP)! This shows how much budget you've used.\n\nDon't go over the limit, or you won't be able to launch!",
			"target_path": "BudgetPanel",
			"arrow": TutorialPopup.ArrowDirection.UP,
			"wait_for": "popup_acknowledged"
		},

		# Step 12: Launch Button
		{
			"title": "Launch Your Ship!",
			"message": "When you have a powered Bridge and stay within budget, the LAUNCH button activates.\n\nClick it to watch your ship fight! Don't worry - you can redesign after combat if you lose.",
			"target_path": "BottomMenuBar/MenuBarContainer/LaunchButton",
			"arrow": TutorialPopup.ArrowDirection.UP,
			"wait_for": "popup_acknowledged"
		}
	]

	total_steps = tutorial_steps.size()
	print("Tutorial: Loaded %d steps" % total_steps)
