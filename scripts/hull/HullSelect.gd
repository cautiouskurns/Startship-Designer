extends Control

## Hull selection screen - choose ship hull type before designing

## Hull cards
@onready var frigate_card: HullCard = $HullCards/FrigateCard
@onready var cruiser_card: HullCard = $HullCards/CruiserCard
@onready var battleship_card: HullCard = $HullCards/BattleshipCard

func _ready():
	# Setup each card with its hull type
	if frigate_card:
		frigate_card.setup(GameState.HullType.FRIGATE)
		frigate_card.hull_selected.connect(_on_hull_selected)

	if cruiser_card:
		cruiser_card.setup(GameState.HullType.CRUISER)
		cruiser_card.hull_selected.connect(_on_hull_selected)

	if battleship_card:
		battleship_card.setup(GameState.HullType.BATTLESHIP)
		battleship_card.hull_selected.connect(_on_hull_selected)

## Handle hull selection from any card
func _on_hull_selected(hull_type: GameState.HullType):
	# Save selected hull to GameState
	GameState.set_hull(hull_type)

	# Load Ship Designer
	get_tree().change_scene_to_file("res://scenes/designer/ShipDesigner.tscn")
