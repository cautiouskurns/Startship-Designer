class_name TurnSnapshot extends Resource

## Stores the complete state of both ships at the end of a combat turn
## Used for battle replay system to recreate each moment of combat

## Turn number (0-indexed)
var turn_number: int = 0

## Player ship state snapshot
var player_hull_hp: int = 0
var player_active_room_ids: Array[int] = []    # Room instance IDs that still exist (not destroyed)
var player_powered_room_ids: Array[int] = []   # Room instance IDs that are currently powered

## Enemy ship state snapshot
var enemy_hull_hp: int = 0
var enemy_active_room_ids: Array[int] = []
var enemy_powered_room_ids: Array[int] = []

## Events that occurred during this turn (text descriptions)
## Example: ["PLAYER attacks with 3 weapon(s)", "Damage: 30 (-15 shields) = 15", "ENEMY's Weapon destroyed!"]
var events: Array[String] = []

## Initialize snapshot with turn number
func _init(turn: int = 0):
	turn_number = turn

## Add event text to this turn's event log
func add_event(event_text: String):
	events.append(event_text)

## Get a summary string for debugging
func get_summary() -> String:
	return "Turn %d: Player HP=%d (%d rooms, %d powered) | Enemy HP=%d (%d rooms, %d powered) | Events: %d" % [
		turn_number,
		player_hull_hp, player_active_room_ids.size(), player_powered_room_ids.size(),
		enemy_hull_hp, enemy_active_room_ids.size(), enemy_powered_room_ids.size(),
		events.size()
	]
