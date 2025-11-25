class_name PowerPathfinder

## A* pathfinding for electrical routing through the main grid
## Feature 2.2: Routes power from reactors to relays through safe passages

## Traversable room types (can route power through these)
const TRAVERSABLE_TYPES = [
	RoomData.RoomType.EMPTY,
	RoomData.RoomType.ARMOR,
	RoomData.RoomType.CONDUIT,
	RoomData.RoomType.RELAY,
	RoomData.RoomType.REACTOR
]

## Get cost for traversing a tile type (higher = less preferred)
## Returns INF for blocked tiles (WEAPON, SHIELD, ENGINE, BRIDGE)
static func get_tile_cost(room_type: RoomData.RoomType) -> float:
	match room_type:
		RoomData.RoomType.EMPTY:
			return 1.0  # Open space - neutral
		RoomData.RoomType.CONDUIT:
			return 1.0  # Structure - preferred protected route
		RoomData.RoomType.ARMOR:
			return 1.5  # Safe but tight
		RoomData.RoomType.REACTOR:
			return 1.0  # Start point
		RoomData.RoomType.RELAY:
			return 1.0  # End point
		_:
			# Blocked tiles: BRIDGE, WEAPON, SHIELD, ENGINE (too dense for wiring)
			return INF

## Manhattan distance heuristic for A*
static func heuristic(a: Vector2i, b: Vector2i) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)

## Find path from start to end using A* algorithm
## Returns array of Vector2i positions from start to end, or empty array if no path exists
static func find_path(start: Vector2i, end: Vector2i, main_grid: MainGrid) -> Array[Vector2i]:
	# A* data structures
	var open_set: Array[Vector2i] = [start]
	var came_from: Dictionary = {}  # Vector2i -> Vector2i (parent tracking)
	var g_score: Dictionary = {}    # Vector2i -> float (actual cost from start)
	var f_score: Dictionary = {}    # Vector2i -> float (g_score + heuristic)

	# Initialize start node scores
	g_score[start] = 0.0
	f_score[start] = heuristic(start, end)

	# A* main loop
	while not open_set.is_empty():
		# Find node in open_set with lowest f_score
		var current = _get_lowest_f_score(open_set, f_score)

		# Reached goal - reconstruct and return path
		if current == end:
			return _reconstruct_path(came_from, current)

		# Move current from open set to closed set (implicit - just remove from open)
		open_set.erase(current)

		# Check all 4-directional neighbors
		var neighbors = _get_neighbors(current, main_grid)
		for neighbor in neighbors:
			# Get tile at neighbor position
			var tile = main_grid.get_tile_at(neighbor.x, neighbor.y)
			if not tile:
				continue

			# Get room type and check if traversable
			var room_type = tile.get_room_type()
			var tile_cost = get_tile_cost(room_type)

			# Skip blocked tiles (infinite cost)
			if tile_cost == INF:
				continue

			# Calculate tentative g_score through this path
			var tentative_g = g_score.get(current, INF) + tile_cost

			# This path to neighbor is better than any previous one
			if tentative_g < g_score.get(neighbor, INF):
				# Update path tracking
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + heuristic(neighbor, end)

				# Add neighbor to open set if not already there
				if not neighbor in open_set:
					open_set.append(neighbor)

	# No path found - return empty array
	return []

## Get 4-directional neighbors of a position (up, right, down, left)
static func _get_neighbors(pos: Vector2i, main_grid: MainGrid) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions = [
		Vector2i(0, -1),  # Up
		Vector2i(1, 0),   # Right
		Vector2i(0, 1),   # Down
		Vector2i(-1, 0)   # Left
	]

	for dir in directions:
		var neighbor = pos + dir
		if main_grid.is_in_bounds(neighbor.x, neighbor.y):
			neighbors.append(neighbor)

	return neighbors

## Get node with lowest f_score from open set
static func _get_lowest_f_score(open_set: Array[Vector2i], f_score: Dictionary) -> Vector2i:
	var lowest = open_set[0]
	var lowest_score = f_score.get(lowest, INF)

	for node in open_set:
		var score = f_score.get(node, INF)
		if score < lowest_score:
			lowest = node
			lowest_score = score

	return lowest

## Reconstruct path from came_from dictionary (backtrack from goal to start)
static func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [current]

	# Backtrack from goal to start
	while current in came_from:
		current = came_from[current]
		path.insert(0, current)  # Insert at beginning to build path forwards

	return path
