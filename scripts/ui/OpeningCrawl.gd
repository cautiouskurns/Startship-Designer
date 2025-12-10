extends Control

## Opening Crawl
## Displays campaign opening text in cinematic style

signal crawl_finished

## UI Elements
@onready var crawl_label: Label = $CenterContainer/VBoxContainer/CrawlLabel
@onready var skip_button: Button = $SkipButton

## Animation settings
var crawl_duration: float = 4.0  # Seconds for full crawl
var auto_continue: bool = true
var continue_delay: float = 2.0  # Delay after crawl before auto-continue

var tween: Tween = null

func _ready():
	# Connect skip button
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)

	# Display opening crawl
	_play_crawl()

## Play the opening crawl animation
func _play_crawl():
	# Get opening crawl text from NarrativeManager
	var crawl_text = NarrativeManager.get_opening_crawl()
	crawl_label.text = crawl_text

	# Start with label invisible
	crawl_label.modulate.a = 0.0

	# Create fade-in animation
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Fade in over 1 second
	tween.tween_property(crawl_label, "modulate:a", 1.0, 1.0)

	# Hold for crawl_duration
	tween.tween_interval(crawl_duration)

	# Fade out over 0.5 seconds
	tween.tween_property(crawl_label, "modulate:a", 0.0, 0.5)

	# Wait brief moment then finish
	tween.tween_interval(0.2)
	tween.tween_callback(_finish_crawl)

## Finish the crawl and transition to campaign map
func _finish_crawl():
	print("OpeningCrawl: Finished, transitioning to Campaign Map")
	crawl_finished.emit()

	# Transition to Campaign Map
	get_tree().change_scene_to_file("res://scenes/campaign/CampaignMap.tscn")

## Handle skip button press
func _on_skip_pressed():
	print("OpeningCrawl: Skipped")

	# Stop tween
	if tween:
		tween.kill()

	# Go directly to finish
	_finish_crawl()
