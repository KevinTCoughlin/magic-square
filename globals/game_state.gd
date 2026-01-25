extends Node

## Autoload singleton for game state persistence.
## Saves session, stats, and settings to user://save.json.

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1

signal state_loaded
signal state_saved

# Session state (current puzzle in progress)
var session: Dictionary = {}

# Player statistics
var stats: Dictionary = {
	"completed": 0,
	"attempted": 0,
	"best_times": {},
}

# User settings
var settings: Dictionary = {
	"locale": "en",
	"high_contrast": false,
}

var _has_active_session: bool = false


func _ready() -> void:
	load_state()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_state()
		get_tree().quit()


## Save current session (puzzle in progress)
func save_session(puzzle: Dictionary, grid: Array[int], seed_value: int, difficulty: int) -> void:
	session = {
		"puzzle": puzzle,
		"grid": grid,
		"seed": seed_value,
		"difficulty": difficulty,
	}
	_has_active_session = true
	save_state()


## Clear session (puzzle completed or abandoned)
func clear_session() -> void:
	session = {}
	_has_active_session = false
	save_state()


## Check if there's an active session to resume
func has_active_session() -> bool:
	return _has_active_session and not session.is_empty()


## Record a completed puzzle
func record_completion(difficulty: int, time_seconds: float) -> void:
	stats.completed += 1

	var difficulty_key := str(difficulty)
	if not stats.best_times.has(difficulty_key):
		stats.best_times[difficulty_key] = time_seconds
	else:
		var current_best: float = stats.best_times[difficulty_key]
		if time_seconds < current_best:
			stats.best_times[difficulty_key] = time_seconds

	clear_session()


## Record a puzzle attempt (started but not necessarily completed)
func record_attempt() -> void:
	stats.attempted += 1
	save_state()


## Update a setting
func set_setting(key: String, value: Variant) -> void:
	settings[key] = value
	save_state()


## Get a setting with default fallback
func get_setting(key: String, default: Variant = null) -> Variant:
	return settings.get(key, default)


## Save all state to disk
func save_state() -> void:
	var data := {
		"version": SAVE_VERSION,
		"session": session,
		"stats": stats,
		"settings": settings,
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		state_saved.emit()
	else:
		push_warning("GameState: Failed to save state to %s" % SAVE_PATH)


## Load state from disk
func load_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		state_loaded.emit()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_warning("GameState: Failed to open save file")
		state_loaded.emit()
		return

	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(content)
	if error != OK:
		push_warning("GameState: Failed to parse save file: %s" % json.get_error_message())
		state_loaded.emit()
		return

	var data: Dictionary = json.data
	if data.get("version", 0) != SAVE_VERSION:
		push_warning("GameState: Save file version mismatch, resetting")
		state_loaded.emit()
		return

	session = data.get("session", {})
	stats = data.get("stats", stats)
	settings = data.get("settings", settings)
	_has_active_session = not session.is_empty()

	state_loaded.emit()


## Reset all state (for debugging/testing)
func reset_all() -> void:
	session = {}
	stats = {"completed": 0, "attempted": 0, "best_times": {}}
	settings = {"locale": "en", "high_contrast": false}
	_has_active_session = false
	save_state()
