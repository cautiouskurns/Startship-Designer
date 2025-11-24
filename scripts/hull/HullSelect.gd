extends Control

## Hull selection screen - choose ship hull type before designing

## Hull cards
@onready var frigate_card: HullCard = $HullCards/FrigateCard
@onready var cruiser_card: HullCard = $HullCards/CruiserCard
@onready var battleship_card: HullCard = $HullCards/BattleshipCard
@onready var free_design_card: HullCard = $HullCards/FreeDesignCard

## Design choice panel and buttons (for template hulls)
@onready var design_choice_panel: ColorRect = $DesignChoicePanel
@onready var hull_label: Label = $DesignChoicePanel/Panel/HullLabel
@onready var new_design_button: Button = $DesignChoicePanel/Panel/NewDesignButton
@onready var load_template_button: Button = $DesignChoicePanel/Panel/LoadTemplateButton
@onready var choice_back_button: Button = $DesignChoicePanel/Panel/BackButton


## Template panel
@onready var template_list_panel = $TemplateListPanel

## Track selected hull
var selected_hull: GameState.HullType

func _ready():
	# Setup hull cards
	if frigate_card:
		frigate_card.setup(GameState.HullType.FRIGATE)
		frigate_card.hull_selected.connect(_on_hull_selected)

	if cruiser_card:
		cruiser_card.setup(GameState.HullType.CRUISER)
		cruiser_card.hull_selected.connect(_on_hull_selected)

	if battleship_card:
		battleship_card.setup(GameState.HullType.BATTLESHIP)
		battleship_card.hull_selected.connect(_on_hull_selected)

	# Setup free design card
	if free_design_card:
		free_design_card.setup_free_design()
		free_design_card.hull_selected.connect(_on_free_design_selected)

	# Connect choice panel buttons
	new_design_button.pressed.connect(_on_new_design_pressed)
	load_template_button.pressed.connect(_on_load_template_pressed)
	choice_back_button.pressed.connect(_on_choice_back_pressed)

	# Connect template panel signals
	template_list_panel.template_selected.connect(_on_template_selected)
	template_list_panel.start_fresh_requested.connect(_on_new_design_pressed)

## Handle hull selection from any card
func _on_hull_selected(hull_type: GameState.HullType):
	# Play button click sound
	AudioManager.play_button_click()

	# Save selected hull
	selected_hull = hull_type
	GameState.set_hull(hull_type)

	# Update label and show choice panel
	hull_label.text = GameState.get_hull_name(hull_type)
	design_choice_panel.visible = true

## Handle "NEW DESIGN" button - start fresh
func _on_new_design_pressed():
	AudioManager.play_button_click()

	# Hide panels
	design_choice_panel.visible = false
	template_list_panel.hide_panel()

	# Load Ship Designer
	get_tree().change_scene_to_file("res://scenes/designer/ShipDesigner.tscn")

## Handle "LOAD TEMPLATE" button - show template list
func _on_load_template_pressed():
	AudioManager.play_button_click()

	# Show template list panel
	template_list_panel.show_panel()

## Handle template selected - load designer with template
func _on_template_selected(template):
	AudioManager.play_button_click()

	# Store template to load in GameState (we'll need to add this)
	GameState.template_to_load = template

	# Load Ship Designer (it will check for template_to_load in _ready)
	get_tree().change_scene_to_file("res://scenes/designer/ShipDesigner.tscn")

## Handle "BACK" button on choice panel
func _on_choice_back_pressed():
	AudioManager.play_button_click()
	design_choice_panel.visible = false

## Handle free design card selected - go straight to designer with 18×16 grid
func _on_free_design_selected(_hull_type):
	AudioManager.play_button_click()

	# Set FREE_DESIGN hull in GameState (uses 18×16 from ShipGrid.gd)
	GameState.set_hull(GameState.HullType.FREE_DESIGN)

	# Make sure no template is set (we want blank grid)
	GameState.template_to_load = null

	# Load Ship Designer directly (blank 18×16 grid)
	get_tree().change_scene_to_file("res://scenes/designer/ShipDesigner.tscn")
