extends Control

## Grid dimensions
const GRID_WIDTH = 8
const GRID_HEIGHT = 6
const TILE_SIZE = 64

## Grid container node
@onready var grid_container: Node2D = $GridContainer

## Preload GridTile scene
var grid_tile_scene = preload("res://scenes/components/GridTile.tscn")

## Store all grid tiles
var grid_tiles: Array[GridTile] = []

func _ready():
	_create_grid()

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
