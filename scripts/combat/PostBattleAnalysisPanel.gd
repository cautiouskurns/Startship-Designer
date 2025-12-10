extends Control

## Post-Battle Analysis Panel - Shows detailed combat statistics and improvement suggestions
## Appears automatically after battle conclusion

signal analysis_closed
signal review_requested

## UI References
@onready var background_overlay: ColorRect = $BackgroundOverlay
@onready var main_panel: PanelContainer = $MainPanel
@onready var outcome_banner: HBoxContainer = $MainPanel/VBoxContainer/OutcomeBanner
@onready var outcome_label: Label = $MainPanel/VBoxContainer/OutcomeBanner/OutcomeLabel
@onready var battle_duration_label: Label = $MainPanel/VBoxContainer/OutcomeBanner/BattleDurationLabel
@onready var scroll_container: ScrollContainer = $MainPanel/VBoxContainer/ScrollContainer
@onready var stats_section: VBoxContainer = $MainPanel/VBoxContainer/ScrollContainer/Content/StatsSection
@onready var suggestions_section: VBoxContainer = $MainPanel/VBoxContainer/ScrollContainer/Content/SuggestionsSection
@onready var continue_button: Button = $MainPanel/VBoxContainer/ContinueButton

## Battle data
var battle_result: BattleResult = null
var player_stats: Dictionary = {}
var enemy_stats: Dictionary = {}
var performance_metrics: Dictionary = {}

## Helper systems
var stats_calculator: BattleStatsCalculator = null
var suggestion_generator: SuggestionGenerator = null

func _ready():
	# Hide initially
	visible = false

	# Connect button
	continue_button.pressed.connect(_on_continue_pressed)

	# Initialize helper systems
	stats_calculator = BattleStatsCalculator.new()
	suggestion_generator = SuggestionGenerator.new()

	print("PostBattleAnalysisPanel ready")

## Display the panel with battle results
func show_analysis(result: BattleResult, player_ship: ShipData, enemy_ship: ShipData):
	battle_result = result

	print("Showing post-battle analysis - Player won: ", result.player_won)

	# Calculate stats
	player_stats = stats_calculator.calculate_ship_stats(player_ship)
	enemy_stats = stats_calculator.calculate_ship_stats(enemy_ship)
	performance_metrics = stats_calculator.calculate_performance_metrics(result, player_ship, enemy_ship)

	# Update UI
	_update_outcome_banner(result.player_won, result.total_turns)
	_populate_stats_section()
	_populate_suggestions_section()

	# Show panel with animation
	visible = true
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

	# Animate stats after panel appears
	await get_tree().create_timer(0.3).timeout
	_animate_stats()

## Update outcome banner
func _update_outcome_banner(player_won: bool, total_turns: int):
	if player_won:
		outcome_label.text = "VICTORY"
		outcome_label.add_theme_color_override("font_color", Color(0.51, 0.81, 0.4))  # Success green
	else:
		outcome_label.text = "DEFEAT"
		outcome_label.add_theme_color_override("font_color", Color(1.0, 0.43, 0.43))  # Danger red

	battle_duration_label.text = "Battle Duration: %d turns" % total_turns

## Populate stats section with performance metrics
func _populate_stats_section():
	# Clear existing stats
	for child in stats_section.get_children():
		child.queue_free()

	# Add stat categories
	_add_stat_category("OFFENSIVE PERFORMANCE", [
		{"label": "Total Damage Dealt", "value": performance_metrics.get("total_damage_dealt", 0), "rating": _rate_stat("damage", performance_metrics.get("total_damage_dealt", 0))},
		{"label": "Average Damage Per Turn", "value": performance_metrics.get("avg_damage_per_turn", 0), "rating": _rate_stat("avg_damage", performance_metrics.get("avg_damage_per_turn", 0))},
		{"label": "Weapon Efficiency", "value": "%d%%" % performance_metrics.get("weapon_efficiency", 0), "rating": _rate_stat("efficiency", performance_metrics.get("weapon_efficiency", 0))}
	])

	_add_stat_category("DEFENSIVE PERFORMANCE", [
		{"label": "Total Damage Taken", "value": performance_metrics.get("total_damage_taken", 0), "rating": _rate_stat("damage_taken", performance_metrics.get("total_damage_taken", 0))},
		{"label": "Damage Absorbed by Shields", "value": performance_metrics.get("damage_absorbed", 0), "rating": _rate_stat("absorption", performance_metrics.get("damage_absorbed", 0))},
		{"label": "Shield Efficiency", "value": "%d%%" % performance_metrics.get("shield_efficiency", 0), "rating": _rate_stat("efficiency", performance_metrics.get("shield_efficiency", 0))}
	])

	_add_stat_category("RESOURCE EFFICIENCY", [
		{"label": "Rooms Lost", "value": performance_metrics.get("rooms_lost", 0), "rating": _rate_stat("rooms_lost", performance_metrics.get("rooms_lost", 0))},
		{"label": "HP Remaining", "value": "%d%%" % performance_metrics.get("hp_remaining_pct", 0), "rating": _rate_stat("hp_remaining", performance_metrics.get("hp_remaining_pct", 0))},
		{"label": "Power Efficiency", "value": "%d%%" % performance_metrics.get("power_efficiency", 0), "rating": _rate_stat("efficiency", performance_metrics.get("power_efficiency", 0))}
	])

## Add a stat category section
func _add_stat_category(title: String, stats: Array):
	# Category header
	var header = Label.new()
	header.text = title
	header.add_theme_font_size_override("font_size", 20)
	header.add_theme_color_override("font_color", Color(0.4, 0.62, 1.0))  # Accent blue
	stats_section.add_child(header)

	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	stats_section.add_child(spacer)

	# Add each stat
	for stat_data in stats:
		var stat_widget = _create_stat_widget(stat_data)
		stats_section.add_child(stat_widget)

## Create a stat display widget
func _create_stat_widget(stat_data: Dictionary) -> Control:
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(0, 40)

	# Label
	var label = Label.new()
	label.text = stat_data["label"]
	label.custom_minimum_size = Vector2(300, 0)
	label.add_theme_font_size_override("font_size", 16)
	container.add_child(label)

	# Value
	var value_label = Label.new()
	value_label.text = str(stat_data["value"])
	value_label.custom_minimum_size = Vector2(100, 0)
	value_label.add_theme_font_size_override("font_size", 16)
	value_label.add_theme_color_override("font_color", _get_rating_color(stat_data["rating"]))
	container.add_child(value_label)

	# Performance bar
	var bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(200, 20)
	bar.max_value = 100
	bar.value = stat_data["rating"]
	bar.show_percentage = false
	_style_progress_bar(bar, stat_data["rating"])
	container.add_child(bar)

	return container

## Populate suggestions section
func _populate_suggestions_section():
	# Clear existing suggestions
	for child in suggestions_section.get_children():
		child.queue_free()

	# Section header
	var header = Label.new()
	header.text = "IMPROVEMENT SUGGESTIONS"
	header.add_theme_font_size_override("font_size", 24)
	header.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))  # Warning yellow
	suggestions_section.add_child(header)

	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	suggestions_section.add_child(spacer)

	# Generate suggestions
	var suggestions = suggestion_generator.generate_suggestions(performance_metrics, player_stats, battle_result.player_won)

	# Add each suggestion
	for i in range(min(suggestions.size(), 5)):  # Limit to 5 suggestions
		var suggestion_card = _create_suggestion_card(i + 1, suggestions[i])
		suggestions_section.add_child(suggestion_card)

		# Add spacing between cards
		if i < suggestions.size() - 1:
			var card_spacer = Control.new()
			card_spacer.custom_minimum_size = Vector2(0, 15)
			suggestions_section.add_child(card_spacer)

## Create a suggestion card
func _create_suggestion_card(number: int, suggestion: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 80)

	# Style the card
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	style.border_color = Color(1.0, 0.84, 0.0, 0.5)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	card.add_theme_stylebox_override("panel", style)

	# Content
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var vbox = VBoxContainer.new()
	margin.add_child(vbox)

	# Title with number
	var title_label = Label.new()
	title_label.text = "%d. %s" % [number, suggestion.get("title", "Suggestion")]
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	vbox.add_child(title_label)

	# Description
	var desc_label = Label.new()
	desc_label.text = suggestion.get("description", "")
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	# Hover effect
	card.mouse_entered.connect(func():
		var hover_tween = create_tween()
		hover_tween.tween_property(card, "position:y", card.position.y - 5, 0.1)
	)
	card.mouse_exited.connect(func():
		var hover_tween = create_tween()
		hover_tween.tween_property(card, "position:y", card.position.y + 5, 0.1)
	)

	return card

## Animate stats appearing
func _animate_stats():
	# Animate stats appearing with staggered timing
	var delay = 0.0
	for child in stats_section.get_children():
		if child is HBoxContainer:
			child.modulate.a = 0.0
			var tween = create_tween()
			tween.tween_interval(delay)
			tween.tween_property(child, "modulate:a", 1.0, 0.3)
			delay += 0.1

## Rate a stat performance (0-100)
func _rate_stat(stat_type: String, value: float) -> float:
	match stat_type:
		"damage":
			return clamp(value / 100.0 * 100, 0, 100)
		"avg_damage":
			return clamp(value / 30.0 * 100, 0, 100)
		"damage_taken":
			return clamp((200 - value) / 200.0 * 100, 0, 100)  # Inverse - less is better
		"absorption":
			return clamp(value / 50.0 * 100, 0, 100)
		"efficiency":
			return clamp(value, 0, 100)
		"rooms_lost":
			return clamp((10 - value) / 10.0 * 100, 0, 100)  # Inverse
		"hp_remaining":
			return clamp(value, 0, 100)
	return 50.0  # Default middle rating

## Get color based on rating
func _get_rating_color(rating: float) -> Color:
	if rating >= 70:
		return Color(0.51, 0.81, 0.4)  # Green
	elif rating >= 40:
		return Color(1.0, 0.79, 0.29)  # Yellow
	else:
		return Color(1.0, 0.43, 0.43)  # Red

## Style progress bar based on rating
func _style_progress_bar(bar: ProgressBar, rating: float):
	var style = StyleBoxFlat.new()
	style.bg_color = _get_rating_color(rating)
	bar.add_theme_stylebox_override("fill", style)

## Handle continue button press
func _on_continue_pressed():
	print("Continue button pressed - closing analysis panel")

	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished

	visible = false
	analysis_closed.emit()
