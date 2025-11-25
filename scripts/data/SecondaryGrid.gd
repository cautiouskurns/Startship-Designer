class_name SecondaryGrid

## Data model for electrical routing and power connections
## Separates electrical connections from physical placement (MainGrid)
## Feature 1.1: Two-Grid Architecture - Electrical Layer (stub for now)
##
## This class will eventually store:
## - Connections from reactors to relays
## - Connections between relays
## - Power routing paths as arrays of tile positions
## - Powered state for each connection
##
## For Feature 1.1, this is just an empty structure to establish the architecture

## Grid dimensions (same coordinate system as MainGrid)
var grid_width: int = 0
var grid_height: int = 0

## Connections dictionary (will be populated in Feature 2.3)
## Key: relay_id (int)
## Value: {source_id: int, path: Array[Vector2i], is_powered: bool}
var connections: Dictionary = {}

## Initialize secondary grid with dimensions
func initialize(width: int, height: int):
	grid_width = width
	grid_height = height
	connections.clear()

## Add a connection from power source to relay (stub for Feature 2.3)
## relay_id: Unique ID of the relay receiving power
## source_id: Unique ID of the power source (reactor or another relay)
## path: Array of Vector2i positions the connection passes through
func add_connection(relay_id: int, source_id: int, path: Array[Vector2i]):
	print("Feature 2.3 DEBUG: add_connection called - relay_id=", relay_id, ", path size=", path.size())
	connections[relay_id] = {
		"source_id": source_id,
		"path": path,
		"is_powered": false
	}
	print("Feature 2.3 DEBUG: Total connections now: ", connections.size())

## Remove a connection (stub for Feature 2.3)
func remove_connection(relay_id: int):
	connections.erase(relay_id)

## Get connection data for a relay (stub for Feature 2.3)
## Returns connection dictionary or empty dict if not found
func get_connection(relay_id: int) -> Dictionary:
	return connections.get(relay_id, {})

## Get all connections (stub for Feature 2.3)
## Returns array of connection dictionaries
func get_all_connections() -> Array:
	print("Feature 2.3 DEBUG: SecondaryGrid has ", connections.size(), " connections stored")
	for relay_id in connections:
		var conn = connections[relay_id]
		print("  Relay ID ", relay_id, ": path has ", conn.get("path", []).size(), " tiles")

	var result = []
	for relay_id in connections:
		result.append(connections[relay_id])
	return result

## Check if a relay is powered (stub for Feature 2.4)
## Will implement proper power calculation in future features
func is_relay_powered(relay_id: int) -> bool:
	var connection = get_connection(relay_id)
	if connection.is_empty():
		return false
	return connection.get("is_powered", false)

## Clear all connections (used when clearing grid)
func clear():
	connections.clear()

## Validate a single connection (Feature 2.4)
## Returns true if connection path is still valid (all tiles traversable, source is reactor)
func validate_connection(relay_id: int, main_grid, placed_rooms: Array) -> bool:
	print("Feature 2.4 DEBUG: Validating connection for relay_id=", relay_id)

	var connection = get_connection(relay_id)
	if connection.is_empty():
		print("  FAIL: No connection found")
		return false

	var path: Array = connection.get("path", [])
	if path.is_empty():
		print("  FAIL: Path is empty")
		return false

	print("  Path has ", path.size(), " tiles")

	# Check if all tiles in path are still traversable
	for i in range(path.size()):
		var pos = path[i]
		# Check bounds
		if not main_grid.is_in_bounds(pos.x, pos.y):
			print("  FAIL: Tile ", i, " at ", pos, " is out of bounds")
			return false

		# Get tile and check traversability
		var tile = main_grid.get_tile_at(pos.x, pos.y)
		if not tile:
			print("  FAIL: Tile ", i, " at ", pos, " is null")
			return false

		var room_type = tile.get_room_type()
		print("  Tile ", i, " at ", pos, ": room_type=", room_type)
		# Use PowerPathfinder's traversal cost to determine if tile is still traversable
		var cost = PowerPathfinder.get_tile_cost(room_type)
		if cost == INF:
			print("  FAIL: Tile ", i, " at ", pos, " has room type ", room_type, " (blocked, cost=INF)")
			return false  # Tile blocked by non-traversable room

	# Check if source (first tile in path) is still a reactor
	var source_pos = path[0]
	var source_tile = main_grid.get_tile_at(source_pos.x, source_pos.y)
	if not source_tile or source_tile.get_room_type() != RoomData.RoomType.REACTOR:
		print("  FAIL: Source tile at ", source_pos, " is not a reactor (type=", source_tile.get_room_type() if source_tile else "null", ")")
		return false

	print("  PASS: Connection is valid")
	return true

## Update powered state for all connections (Feature 2.4)
## Call this whenever grid changes (place/remove rooms)
func update_all_powered_states(main_grid, placed_rooms: Array):
	print("Feature 2.4 DEBUG: Updating powered states for ", connections.size(), " connections")
	for relay_id in connections:
		var is_valid = validate_connection(relay_id, main_grid, placed_rooms)
		connections[relay_id]["is_powered"] = is_valid
		print("  Relay ID ", relay_id, ": is_powered = ", is_valid)
