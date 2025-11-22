extends Control

## Grid dimensions
const GRID_WIDTH = 8
const GRID_HEIGHT = 6
const TILE_SIZE = 64

## Budget values
var max_budget: int = 30  # Hard-coded for Phase 1
var current_budget: int = 0

## Grid container node
@onready var grid_container: Node2D = $GridContainer

## Budget UI elements
@onready var budget_label: Label = $BudgetPanel/BudgetLabel
@onready var remaining_label: Label = $BudgetPanel/RemainingLabel

## Launch button
@onready var launch_button: Button = $LaunchButton

## Preload GridTile scene
var grid_tile_scene = preload("res://scenes/components/GridTile.tscn")

## Store all grid tiles
var grid_tiles: Array[GridTile] = []

func _ready():
	_create_grid()
	_update_budget_display()

func _create_grid():
	"""Create an 8x6 grid of tiles"""
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			# Instantiate a new tile
			var tile: GridTile = grid_tile_scene.instantiate()

			# Set grid coordinates
			tile.grid_x = x
			tile.grid_y = y

			# Position the tile
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)

			# Add to grid container
			grid_container.add_child(tile)

			# Store reference
			grid_tiles.append(tile)

## Calculate current budget from all placed rooms
func calculate_current_budget() -> int:
	var total = 0
	for tile in grid_tiles:
		var room_type = tile.get_room_type()
		if room_type != RoomData.RoomType.EMPTY:
			total += RoomData.get_cost(room_type)
	return total

## Update the budget display labels
func _update_budget_display():
	current_budget = calculate_current_budget()
	var remaining = max_budget - current_budget

	# Update budget label
	budget_label.text = "BUDGET: %d/%d" % [current_budget, max_budget]

	# Update remaining label with color
	remaining_label.text = "Remaining: %d" % remaining
	remaining_label.add_theme_color_override("font_color", _get_remaining_color(remaining))

## Get color for remaining budget based on value
func _get_remaining_color(remaining: int) -> Color:
	if remaining > 5:
		return Color(0.290, 0.886, 0.290)  # Green #4AE24A
	elif remaining >= 1:
		return Color(0.886, 0.831, 0.290)  # Yellow #E2D44A
	else:
		return Color(0.886, 0.290, 0.290)  # Red #E24A4A
