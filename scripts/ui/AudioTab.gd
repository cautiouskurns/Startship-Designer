extends VBoxContainer

## AudioTab - Manages audio volume sliders for Master/SFX/Music

@onready var master_slider: HSlider = $MasterVolumeContainer/SliderRow/MasterVolumeSlider
@onready var master_value_label: Label = $MasterVolumeContainer/SliderRow/MasterValueLabel

@onready var sfx_slider: HSlider = $SFXVolumeContainer/SliderRow/SFXVolumeSlider
@onready var sfx_value_label: Label = $SFXVolumeContainer/SliderRow/SFXValueLabel

@onready var music_slider: HSlider = $MusicVolumeContainer/SliderRow/MusicVolumeSlider
@onready var music_value_label: Label = $MusicVolumeContainer/SliderRow/MusicValueLabel

func _ready():
	# Set up sliders
	_setup_slider(master_slider, "master")
	_setup_slider(sfx_slider, "sfx")
	_setup_slider(music_slider, "music")

	# Connect signals
	master_slider.value_changed.connect(_on_master_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)

	# Load current values
	load_values()

## Set up a slider with default properties
func _setup_slider(slider: HSlider, bus_name: String):
	if not slider:
		return

	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = SettingsManager.get_volume(bus_name)

## Load current volume values from SettingsManager
func load_values():
	if master_slider:
		master_slider.value = SettingsManager.get_volume("master")
		_update_label(master_value_label, master_slider.value)

	if sfx_slider:
		sfx_slider.value = SettingsManager.get_volume("sfx")
		_update_label(sfx_value_label, sfx_slider.value)

	if music_slider:
		music_slider.value = SettingsManager.get_volume("music")
		_update_label(music_value_label, music_slider.value)

## Update a value label to show percentage
func _update_label(label: Label, value: float):
	if label:
		label.text = str(int(value * 100)) + "%"

## Called when master volume slider changes
func _on_master_volume_changed(value: float):
	SettingsManager.set_volume("master", value)
	_update_label(master_value_label, value)

	# Play feedback sound
	if AudioManager:
		AudioManager.play_button_click()

## Called when SFX volume slider changes
func _on_sfx_volume_changed(value: float):
	SettingsManager.set_volume("sfx", value)
	_update_label(sfx_value_label, value)

	# Play feedback sound
	if AudioManager:
		AudioManager.play_button_click()

## Called when music volume slider changes
func _on_music_volume_changed(value: float):
	SettingsManager.set_volume("music", value)
	_update_label(music_value_label, value)
