class_name BattleResult extends Resource

## Stores the complete replay data for an entire combat encounter
## Contains snapshots of ship states at the end of each turn plus combat outcome

## Mission index this battle was fought in (0 = Patrol, 1 = Convoy, 2 = Fleet)
var mission_index: int = 0

## Total number of turns the battle lasted
var total_turns: int = 0

## Did the player win?
var player_won: bool = false

## Array of turn-by-turn state snapshots
var turn_snapshots: Array[TurnSnapshot] = []

## Initialize with mission index
func _init(mission: int = 0):
	mission_index = mission

## Add a turn snapshot to the battle history
func add_turn_snapshot(snapshot: TurnSnapshot):
	turn_snapshots.append(snapshot)
	total_turns = turn_snapshots.size()

## Get snapshot for a specific turn (null if out of range)
func get_turn_snapshot(turn: int) -> TurnSnapshot:
	if turn >= 0 and turn < turn_snapshots.size():
		return turn_snapshots[turn]
	return null

## Get summary of battle for debugging
func get_summary() -> String:
	var outcome = "VICTORY" if player_won else "DEFEAT"
	return "Mission %d - %s after %d turns (%d snapshots)" % [
		mission_index, outcome, total_turns, turn_snapshots.size()
	]

## Get total event count across all turns
func get_total_events() -> int:
	var count = 0
	for snapshot in turn_snapshots:
		count += snapshot.events.size()
	return count
