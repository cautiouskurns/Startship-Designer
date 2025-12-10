extends Node

## SaveManager Singleton
## Centralized save/load operations for campaign progress and ship designs

## Signals
signal campaign_loaded()
signal campaign_saved()
signal design_saved(design_name: String)
signal design_loaded(design_name: String)
signal save_error(error_message: String)

## Constants
const SAVE_VERSION = 1
const SAVE_DIR = "user://saves/"
const CAMPAIGN_SAVE_PATH = "user://saves/campaign.json"
const DESIGNS_DIR = "user://saves/designs/"
const MAX_SAVED_DESIGNS = 10
const AUTO_SAVE_ENABLED = true

## Ship Design data class
class ShipDesign:
	var design_name: String = ""
	var mission_index: int = 0
	var budget_used: int = 0
	var grid_data: Array = []  # 2D array of room type enums
	var hull_type: int = 0  # GameState.HullType enum value
	var last_modified: String = ""

	func to_dict() -> Dictionary:
		return {
			"save_version": SAVE_VERSION,
			"design_name": design_name,
			"mission_index": mission_index,
			"budget_used": budget_used,
			"grid_data": grid_data,
			"hull_type": hull_type,
			"last_modified": Time.get_datetime_string_from_system()
		}

	static func from_dict(data: Dictionary) -> ShipDesign:
		var design = ShipDesign.new()
		design.design_name = data.get("design_name", "Unnamed")
		design.mission_index = data.get("mission_index", 0)
		design.budget_used = data.get("budget_used", 0)
		design.grid_data = data.get("grid_data", [])
		design.hull_type = data.get("hull_type", 1)  # Default to CRUISER
		design.last_modified = data.get("last_modified", "")
		return design

func _ready():
	# Create save directories if they don't exist
	_ensure_directories_exist()

	# Auto-load campaign progress on startup
	if AUTO_SAVE_ENABLED:
		load_campaign_progress()

## Ensure save directories exist
func _ensure_directories_exist():
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)
		print("Created save directory: %s" % SAVE_DIR)

	if not DirAccess.dir_exists_absolute(DESIGNS_DIR):
		DirAccess.make_dir_absolute(DESIGNS_DIR)
		print("Created designs directory: %s" % DESIGNS_DIR)

## Save campaign progress to disk
func save_campaign_progress() -> bool:
	_ensure_directories_exist()

	# Get campaign state from CampaignState autoload
	var campaign_data = CampaignState.save_campaign_state()

	# Add metadata
	campaign_data["save_version"] = SAVE_VERSION
	campaign_data["last_saved"] = Time.get_datetime_string_from_system()
	campaign_data["battles_won"] = CampaignState.battles_won
	campaign_data["battles_lost"] = CampaignState.battles_lost
	campaign_data["total_battles"] = CampaignState.total_battles
	campaign_data["ships_deployed"] = CampaignState.ships_deployed

	# Convert to JSON
	var json_string = JSON.stringify(campaign_data, "\t")

	# Write to file
	var file = FileAccess.open(CAMPAIGN_SAVE_PATH, FileAccess.WRITE)
	if not file:
		var error_msg = "Failed to save campaign to: %s" % CAMPAIGN_SAVE_PATH
		push_error(error_msg)
		save_error.emit(error_msg)
		return false

	file.store_string(json_string)
	file.close()

	print("Campaign saved successfully")
	campaign_saved.emit()
	return true

## Load campaign progress from disk
func load_campaign_progress() -> bool:
	# Check if file exists
	if not FileAccess.file_exists(CAMPAIGN_SAVE_PATH):
		print("No campaign save file found, starting fresh")
		return false

	# Read file
	var file = FileAccess.open(CAMPAIGN_SAVE_PATH, FileAccess.READ)
	if not file:
		var error_msg = "Failed to load campaign from: %s" % CAMPAIGN_SAVE_PATH
		push_error(error_msg)
		save_error.emit(error_msg)
		return false

	var json_string = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		var error_msg = "Failed to parse campaign save: %s" % json.get_error_message()
		push_error(error_msg)

		# Delete corrupted file
		DirAccess.remove_absolute(CAMPAIGN_SAVE_PATH)
		print("Deleted corrupted campaign save file")

		save_error.emit("Save data corrupted - starting new campaign")
		return false

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		var error_msg = "Campaign save is not a dictionary"
		push_error(error_msg)
		save_error.emit(error_msg)
		return false

	# Check version compatibility
	var save_version = data.get("save_version", 0)
	if save_version != SAVE_VERSION:
		print("Warning: Save version mismatch (expected %d, got %d)" % [SAVE_VERSION, save_version])
		# Could implement migration here in the future

	# Restore campaign state
	CampaignState.load_campaign_state(data)

	# Restore campaign stats
	CampaignState.battles_won = data.get("battles_won", 0)
	CampaignState.battles_lost = data.get("battles_lost", 0)
	CampaignState.total_battles = data.get("total_battles", 0)
	CampaignState.ships_deployed = data.get("ships_deployed", 0)

	print("Campaign loaded successfully")
	campaign_loaded.emit()
	return true

## Save ship design to disk
func save_ship_design(design: ShipDesign) -> bool:
	if design.design_name.strip_edges().is_empty():
		save_error.emit("Design name cannot be empty")
		return false

	_ensure_directories_exist()

	# Check design limit and delete oldest if needed
	_enforce_design_limit()

	# Sanitize filename
	var filename = _sanitize_filename(design.design_name)
	var filepath = DESIGNS_DIR + filename + ".json"

	# Convert to JSON
	var json_string = JSON.stringify(design.to_dict(), "\t")

	# Write to file
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if not file:
		var error_msg = "Failed to save design to: %s" % filepath
		push_error(error_msg)
		save_error.emit(error_msg)
		return false

	file.store_string(json_string)
	file.close()

	print("Ship design '%s' saved to %s" % [design.design_name, filepath])
	design_saved.emit(design.design_name)
	return true

## Load ship design from disk
func load_ship_design(design_name: String) -> ShipDesign:
	var filename = _sanitize_filename(design_name)
	var filepath = DESIGNS_DIR + filename + ".json"

	# Check if file exists
	if not FileAccess.file_exists(filepath):
		var error_msg = "Design file not found: %s" % filepath
		push_error(error_msg)
		save_error.emit(error_msg)
		return null

	# Read file
	var file = FileAccess.open(filepath, FileAccess.READ)
	if not file:
		var error_msg = "Failed to open design file: %s" % filepath
		push_error(error_msg)
		save_error.emit(error_msg)
		return null

	var json_string = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		var error_msg = "Failed to parse design save: %s" % json.get_error_message()
		push_error(error_msg)
		save_error.emit("Load failed - file corrupted")
		return null

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		save_error.emit("Design save is not a dictionary")
		return null

	# Create design from data
	var design = ShipDesign.from_dict(data)

	print("Ship design '%s' loaded from %s" % [design.design_name, filepath])
	design_loaded.emit(design.design_name)
	return design

## Get list of all saved designs
func get_saved_designs() -> Array[ShipDesign]:
	var designs: Array[ShipDesign] = []

	# Check if directory exists
	if not DirAccess.dir_exists_absolute(DESIGNS_DIR):
		return designs

	# List all .json files in designs directory
	var dir = DirAccess.open(DESIGNS_DIR)
	if not dir:
		push_error("Failed to open designs directory: %s" % DESIGNS_DIR)
		return designs

	dir.list_dir_begin()
	var filename = dir.get_next()

	while filename != "":
		if not dir.current_is_dir() and filename.ends_with(".json"):
			# Load design
			var design_name = filename.trim_suffix(".json")
			var design = load_ship_design(design_name)
			if design:
				designs.append(design)
		filename = dir.get_next()

	dir.list_dir_end()

	# Sort by last modified (newest first)
	designs.sort_custom(func(a, b): return a.last_modified > b.last_modified)

	return designs

## Delete a saved design
func delete_design(design_name: String) -> bool:
	var filename = _sanitize_filename(design_name)
	var filepath = DESIGNS_DIR + filename + ".json"

	# Check if file exists
	if not FileAccess.file_exists(filepath):
		var error_msg = "Design file not found: %s" % filepath
		push_error(error_msg)
		save_error.emit(error_msg)
		return false

	# Delete file
	var error = DirAccess.remove_absolute(filepath)
	if error != OK:
		var error_msg = "Failed to delete design file: %s (error %d)" % [filepath, error]
		push_error(error_msg)
		save_error.emit(error_msg)
		return false

	print("Ship design '%s' deleted" % design_name)
	return true

## Enforce max saved designs limit (delete oldest if exceeded)
func _enforce_design_limit():
	var designs = get_saved_designs()

	# Delete oldest designs if we exceed the limit
	while designs.size() >= MAX_SAVED_DESIGNS:
		var oldest = designs[-1]  # Last in sorted array (oldest)
		print("Max designs limit reached, deleting oldest: %s" % oldest.design_name)
		delete_design(oldest.design_name)
		designs.pop_back()

## Sanitize filename (remove special characters, lowercase, replace spaces with _)
func _sanitize_filename(name: String) -> String:
	# Convert to lowercase
	var sanitized = name.to_lower()

	# Replace spaces with underscores
	sanitized = sanitized.replace(" ", "_")

	# Remove special characters (keep only alphanumeric and underscores)
	var result = ""
	for c in sanitized:
		if c.is_valid_identifier() or c == "_":
			result += c

	# Ensure not empty
	if result.is_empty():
		result = "unnamed_design"

	return result
