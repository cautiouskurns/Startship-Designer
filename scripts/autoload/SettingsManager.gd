extends Node

## SettingsManager Singleton
## Manages game settings (audio, video, controls) and persistence

const SETTINGS_FILE = "user://settings.cfg"

# Settings data structure
var settings = {
	"audio": {
		"master_volume": 1.0,  # 0.0 to 1.0
		"sfx_volume": 0.85,
		"music_volume": 0.6
	},
	"video": {
		"resolution": Vector2i(1920, 1080),
		"fullscreen": false
	},
	"controls": {
		"camera_up": KEY_W,
		"camera_down": KEY_S,
		"camera_left": KEY_A,
		"camera_right": KEY_D,
		"zoom_in": KEY_EQUAL,
		"zoom_out": KEY_MINUS
	}
}

# Signals
signal settings_changed()
signal settings_saved()
signal settings_cancelled()

func _ready():
	load_settings()
	apply_settings()

## Save settings to disk
func save_settings():
	var config = ConfigFile.new()

	# Audio
	config.set_value("audio", "master_volume", settings["audio"]["master_volume"])
	config.set_value("audio", "sfx_volume", settings["audio"]["sfx_volume"])
	config.set_value("audio", "music_volume", settings["audio"]["music_volume"])

	# Video
	config.set_value("video", "resolution_x", settings["video"]["resolution"].x)
	config.set_value("video", "resolution_y", settings["video"]["resolution"].y)
	config.set_value("video", "fullscreen", settings["video"]["fullscreen"])

	# Controls
	for action in settings["controls"].keys():
		config.set_value("controls", action, settings["controls"][action])

	var err = config.save(SETTINGS_FILE)
	if err == OK:
		settings_saved.emit()
		print("Settings saved successfully")
	else:
		push_error("Failed to save settings: " + str(err))

## Load settings from disk
func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE)

	if err != OK:
		print("No settings file found, using defaults")
		return

	# Audio
	settings["audio"]["master_volume"] = config.get_value("audio", "master_volume", 1.0)
	settings["audio"]["sfx_volume"] = config.get_value("audio", "sfx_volume", 0.85)
	settings["audio"]["music_volume"] = config.get_value("audio", "music_volume", 0.6)

	# Video
	var res_x = config.get_value("video", "resolution_x", 1920)
	var res_y = config.get_value("video", "resolution_y", 1080)
	settings["video"]["resolution"] = Vector2i(res_x, res_y)
	settings["video"]["fullscreen"] = config.get_value("video", "fullscreen", false)

	# Controls
	for action in settings["controls"].keys():
		settings["controls"][action] = config.get_value("controls", action, settings["controls"][action])

	print("Settings loaded successfully")

## Apply settings to the game
func apply_settings():
	apply_audio_settings()
	apply_video_settings()
	apply_control_settings()
	settings_changed.emit()

## Apply audio settings
func apply_audio_settings():
	# Check if audio busses exist, if not use direct volume control on AudioManager
	var master_bus = AudioServer.get_bus_index("Master")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	var music_bus = AudioServer.get_bus_index("Music")

	if master_bus != -1:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(settings["audio"]["master_volume"]))

	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(settings["audio"]["sfx_volume"]))

	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(settings["audio"]["music_volume"]))

	# Fallback: control AudioManager directly if busses don't exist
	if AudioManager and music_bus == -1:
		var music_volume_db = linear_to_db(settings["audio"]["music_volume"] * settings["audio"]["master_volume"])
		AudioManager.set_music_volume(music_volume_db)

## Apply video settings
func apply_video_settings():
	# Apply fullscreen mode
	if settings["video"]["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# Set window size
		get_window().size = settings["video"]["resolution"]

## Apply control settings (remap InputMap)
func apply_control_settings():
	# Create InputMap actions if they don't exist
	for action in settings["controls"].keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)

		# Clear existing events
		InputMap.action_erase_events(action)

		# Add new key binding
		var event = InputEventKey.new()
		event.keycode = settings["controls"][action]
		InputMap.action_add_event(action, event)

## Get current volume for a specific bus (0.0 to 1.0)
func get_volume(bus_name: String) -> float:
	match bus_name:
		"master":
			return settings["audio"]["master_volume"]
		"sfx":
			return settings["audio"]["sfx_volume"]
		"music":
			return settings["audio"]["music_volume"]
		_:
			return 1.0

## Set volume for a specific bus (0.0 to 1.0)
func set_volume(bus_name: String, value: float):
	value = clamp(value, 0.0, 1.0)

	match bus_name:
		"master":
			settings["audio"]["master_volume"] = value
		"sfx":
			settings["audio"]["sfx_volume"] = value
		"music":
			settings["audio"]["music_volume"] = value

	apply_audio_settings()

## Check if a key is already bound to another action
func is_key_bound(keycode: int, exclude_action: String = "") -> String:
	for action in settings["controls"].keys():
		if action != exclude_action and settings["controls"][action] == keycode:
			return action
	return ""

## Set keybind for an action
func set_keybind(action: String, keycode: int) -> bool:
	# Check for conflicts
	var conflicting_action = is_key_bound(keycode, action)
	if conflicting_action != "":
		push_warning("Key already bound to: " + conflicting_action)
		return false

	# Reserved keys
	if keycode == KEY_ESCAPE:
		push_warning("ESC key is reserved")
		return false

	# Set the binding
	settings["controls"][action] = keycode
	apply_control_settings()
	return true

## Get keybind for an action
func get_keybind(action: String) -> int:
	if settings["controls"].has(action):
		return settings["controls"][action]
	return KEY_NONE

## Get available resolutions (16:9 aspect ratios)
func get_available_resolutions() -> Array[Vector2i]:
	return [
		Vector2i(1280, 720),
		Vector2i(1920, 1080),
		Vector2i(2560, 1440),
		Vector2i(3840, 2160)
	]

## Set resolution
func set_resolution(resolution: Vector2i):
	settings["video"]["resolution"] = resolution
	apply_video_settings()

## Set fullscreen mode
func set_fullscreen(enabled: bool):
	settings["video"]["fullscreen"] = enabled
	apply_video_settings()
