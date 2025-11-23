extends ScrollContainer
class_name CombatLog

## Combat log that displays all actions taken during combat

@onready var log_container: VBoxContainer = $VBoxContainer

## Color constants
const COLOR_PLAYER = Color(0.290, 0.886, 0.886)    # Cyan #4AE2E2
const COLOR_ENEMY = Color(0.886, 0.290, 0.290)     # Red #E24A4A
const COLOR_DAMAGE = Color(0.886, 0.627, 0.290)    # Orange #E2A04A
const COLOR_SHIELD = Color(0.290, 0.565, 0.886)    # Blue #4A90E2
const COLOR_DESTROYED = Color(0.886, 0.831, 0.290) # Yellow #E2D44A
const COLOR_VICTORY = Color(0.290, 0.886, 0.290)   # Green #4AE24A
const COLOR_NEUTRAL = Color(0.667, 0.667, 0.667)   # Gray #AAAAAA

## Add a generic log entry with custom color
func add_entry(text: String, color: Color = COLOR_NEUTRAL):
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 14)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_container.add_child(label)

	# Auto-scroll to bottom (deferred to ensure layout updates first)
	scroll_to_bottom.call_deferred()

## Scroll to bottom of log
func scroll_to_bottom():
	await get_tree().process_frame
	scroll_vertical = int(get_v_scroll_bar().max_value)

## Log initiative determination
func add_initiative(winner: String, player_engines: int, enemy_engines: int, bonus_text: String = ""):
	add_entry("=== INITIATIVE ===", COLOR_NEUTRAL)
	if winner == "player":
		var text = "Player shoots first! (%d engines vs %d)" % [player_engines, enemy_engines]
		if bonus_text != "":
			text += " " + bonus_text
		add_entry(text, COLOR_PLAYER)
	else:
		add_entry("Enemy shoots first! (%d engines vs %d)" % [enemy_engines, player_engines], COLOR_ENEMY)
	add_entry("", COLOR_NEUTRAL)  # Blank line

## Log combat start
func add_combat_start():
	add_entry("=== COMBAT START ===", COLOR_VICTORY)
	add_entry("", COLOR_NEUTRAL)  # Blank line

## Log turn start
func add_turn_start(turn: int, is_player: bool):
	var attacker = "PLAYER" if is_player else "ENEMY"
	var color = COLOR_PLAYER if is_player else COLOR_ENEMY
	add_entry("--- Turn %d: %s ---" % [turn, attacker], color)

## Log attack details
func add_attack(attacker: String, weapons: int, damage: int, shields_absorbed: int, net_damage: int):
	var color = COLOR_PLAYER if attacker == "PLAYER" else COLOR_ENEMY

	# Show weapon count and base damage
	add_entry("%s attacks with %d weapon(s)" % [attacker, weapons], color)

	# Show damage breakdown
	if shields_absorbed > 0:
		add_entry("  Damage: %d (-%d shields) = %d" % [damage, shields_absorbed, net_damage], COLOR_DAMAGE)
	else:
		add_entry("  Damage: %d (no shields!)" % damage, COLOR_DAMAGE)

## Log synergy bonuses
func add_synergy_bonus(bonus_type: String, bonus_amount: int, affected_count: int):
	add_entry("  +%d%% %s (%d rooms)" % [bonus_amount, bonus_type, affected_count], COLOR_SHIELD)

## Log room destroyed
func add_room_destroyed(room_type: String, defender: String):
	var color = COLOR_PLAYER if defender == "ENEMY" else COLOR_ENEMY
	add_entry("  %s's %s destroyed!" % [defender, room_type], COLOR_DESTROYED)

## Log reactor destroyed (special case)
func add_reactor_destroyed(defender: String):
	var color = COLOR_PLAYER if defender == "ENEMY" else COLOR_ENEMY
	add_entry("  %s's REACTOR destroyed! Power grid recalculated." % defender, COLOR_DESTROYED)

## Log durability resist
func add_durability_resist(room_type: String, defender: String):
	add_entry("  %s's %s resisted destruction! (Durability synergy)" % [defender, room_type], COLOR_SHIELD)

## Log HP remaining
func add_hp_remaining(defender: String, current_hp: int, max_hp: int):
	var color = COLOR_PLAYER if defender == "PLAYER" else COLOR_ENEMY
	add_entry("  %s HP: %d / %d" % [defender, current_hp, max_hp], color)

## Log victory/defeat
func add_victory(winner: String):
	add_entry("", COLOR_NEUTRAL)  # Blank line
	add_entry("=== COMBAT END ===", COLOR_NEUTRAL)
	if winner == "player":
		add_entry("VICTORY! Player wins!", COLOR_VICTORY)
	else:
		add_entry("DEFEAT! Enemy wins!", COLOR_ENEMY)

## Clear all log entries
func clear_log():
	for child in log_container.get_children():
		child.queue_free()
