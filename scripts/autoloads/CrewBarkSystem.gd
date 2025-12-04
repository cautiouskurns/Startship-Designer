extends Node

## CrewBarkSystem - Autoload singleton for crew bark management
## Handles event detection, bark selection, priority queue, and cooldown management
## Part of Phase 1.1: Triggering System

## Emitted when a bark should be displayed (UI listens to this)
signal bark_triggered(bark: BarkData)

## Emitted when queue size changes (for debugging/UI)
signal bark_queue_updated(queue_size: int)

## Constants
const BARK_COOLDOWN = 2.0  # Minimum seconds between barks
const MAX_QUEUE_SIZE = 5   # Maximum queued barks (drop lowest priority if exceeded)

## State
var bark_queue: Array[BarkData] = []      # Priority queue of pending barks
var used_barks: Dictionary = {}           # {bark_text: true} - prevents repetition
var cooldown_timer: Timer                 # Timer for bark spacing

## Debug flag
var debug_enabled: bool = true

func _ready():
	name = "CrewBarkSystem"  # Ensure consistent name for autoload

	# Create cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(cooldown_timer)

	if debug_enabled:
		print("[CrewBarkSystem] Initialized - waiting for combat signals")
		var stats = BarkSelector.get_bark_stats()
		print("[CrewBarkSystem] Bark Database loaded: %d total barks" % stats["total_barks"])
		print("  - Damage Reports: %d" % stats["damage_reports"])
		print("  - Tactical Updates: %d" % stats["tactical_updates"])
		print("  - System Status: %d" % stats["system_status"])
		print("  - Crew Stress: %d" % stats["crew_stress"])
		print("  - Victory/Defeat: %d" % stats["victory_defeat"])

## Called when combat scene starts (connect signals)
func connect_to_combat(combat_node: Node) -> void:
	if not combat_node:
		push_error("[CrewBarkSystem] Cannot connect to null combat node")
		return

	# Connect to combat signals
	if not combat_node.component_destroyed.is_connected(_on_component_destroyed):
		combat_node.component_destroyed.connect(_on_component_destroyed)
	if not combat_node.hp_threshold_crossed.is_connected(_on_hp_threshold_crossed):
		combat_node.hp_threshold_crossed.connect(_on_hp_threshold_crossed)
	if not combat_node.battle_started.is_connected(_on_battle_started):
		combat_node.battle_started.connect(_on_battle_started)
	if not combat_node.battle_ended.is_connected(_on_battle_ended):
		combat_node.battle_ended.connect(_on_battle_ended)

	if debug_enabled:
		print("[CrewBarkSystem] Connected to combat signals")

## Event handler: Component destroyed
func _on_component_destroyed(ship: String, component_type: RoomData.RoomType) -> void:
	# Only bark for player ship
	if ship != "player":
		return

	if debug_enabled:
		print("[CrewBarkSystem] Component destroyed: %s on %s" % [RoomData.get_label(component_type), ship])

	# Select appropriate bark
	var bark = BarkSelector.select_for_component_destroyed(component_type)
	if bark:
		queue_bark(bark)
	else:
		if debug_enabled:
			print("[CrewBarkSystem] No bark found for component: %s" % RoomData.get_label(component_type))

## Event handler: HP threshold crossed
func _on_hp_threshold_crossed(ship: String, threshold: int, current_hp: int) -> void:
	if ship != "player":
		return

	if debug_enabled:
		print("[CrewBarkSystem] HP threshold crossed: %d%% (HP: %d) on %s" % [threshold, current_hp, ship])

	var bark = BarkSelector.select_for_hp_threshold(threshold)
	if bark:
		queue_bark(bark)

## Event handler: Battle started
func _on_battle_started() -> void:
	# Reset state for new battle
	bark_queue.clear()
	used_barks.clear()
	cooldown_timer.stop()
	BarkSelector.reset_used_barks()

	if debug_enabled:
		print("[CrewBarkSystem] Battle started - state reset")

## Event handler: Battle ended
func _on_battle_ended(victory: bool) -> void:
	if debug_enabled:
		print("[CrewBarkSystem] Battle ended - victory: %s" % victory)

	# Queue victory/defeat bark
	var bark = BarkSelector.select_for_victory() if victory else BarkSelector.select_for_defeat()
	if bark:
		queue_bark(bark)

	# Note: Don't clear queue here - let final bark play

## Queue a bark for playback
func queue_bark(bark: BarkData) -> void:
	if not bark:
		return

	# Check if this bark was already used this battle
	if used_barks.has(bark.text):
		if debug_enabled:
			print("[CrewBarkSystem] Bark already used, skipping: '%s'" % bark.text)
		return

	if debug_enabled:
		print("[CrewBarkSystem] Queueing bark [%s]: '%s'" % [BarkData.priority_to_string(bark.priority), bark.text])

	# Add to queue
	bark_queue.append(bark)

	# Sort by priority (highest first)
	bark_queue.sort_custom(func(a, b): return a.priority > b.priority)

	# Enforce queue size limit (drop lowest priority)
	while bark_queue.size() > MAX_QUEUE_SIZE:
		var dropped = bark_queue.pop_back()
		if debug_enabled:
			print("[CrewBarkSystem] Queue full - dropped [%s]: '%s'" % [BarkData.priority_to_string(dropped.priority), dropped.text])

	# Try to process queue immediately
	_process_queue()

	# Emit queue update signal
	bark_queue_updated.emit(bark_queue.size())

## Process bark queue (play next bark if cooldown expired)
func _process_queue() -> void:
	# Can't play if queue empty
	if bark_queue.is_empty():
		return

	# Can't play if cooldown active
	if cooldown_timer.time_left > 0:
		if debug_enabled:
			print("[CrewBarkSystem] Cooldown active (%.1fs remaining), bark queued" % cooldown_timer.time_left)
		return

	# Get highest priority bark
	var bark = bark_queue.pop_front()

	# Mark as used (prevent repetition)
	used_barks[bark.text] = true

	if debug_enabled:
		print("[CrewBarkSystem] Playing bark [%s/%s]: '%s'" % [
			BarkData.role_to_string(bark.role),
			BarkData.priority_to_string(bark.priority),
			bark.text
		])

	# Emit bark for UI to display
	bark_triggered.emit(bark)

	# Start cooldown
	cooldown_timer.start(BARK_COOLDOWN)

	# Update queue UI
	bark_queue_updated.emit(bark_queue.size())

## Cooldown expired - try to play next bark
func _on_cooldown_timeout() -> void:
	if debug_enabled and not bark_queue.is_empty():
		print("[CrewBarkSystem] Cooldown expired - processing next bark")

	_process_queue()

## Get current queue state (for debugging)
func get_queue_status() -> Dictionary:
	return {
		"queue_size": bark_queue.size(),
		"cooldown_remaining": cooldown_timer.time_left,
		"used_barks_count": used_barks.size(),
	}

## Clear all state (for testing)
func reset() -> void:
	bark_queue.clear()
	used_barks.clear()
	cooldown_timer.stop()
	BarkSelector.reset_used_barks()
	if debug_enabled:
		print("[CrewBarkSystem] Full reset performed")
