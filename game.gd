extends Control

const CellScene := preload("res://cell.tscn")
const PuzzleGen := preload("res://puzzle_generator.gd")
const PuzzleConfig := preload("res://resources/puzzle_config.gd")

# Lazy-loaded themes (loaded on first access)
static var _default_theme: Theme
static var _high_contrast_theme: Theme

# StringName constants for translation keys (interned, faster lookup)
const TR_EASY := &"EASY"
const TR_MEDIUM := &"MEDIUM"
const TR_HARD := &"HARD"
const TR_TARGET_SUM := &"TARGET_SUM"
const TR_STATUS_CORRECT := &"STATUS_CORRECT"
const TR_STATUS_WRONG := &"STATUS_WRONG"
const TR_STATUS_FILL := &"STATUS_FILL"
const TR_ROW := &"ROW"
const TR_COL := &"COL"
const TR_DIAG_MAIN := &"DIAG_MAIN"
const TR_DIAG_ANTI := &"DIAG_ANTI"
const TR_A11Y_DIFFICULTY := &"A11Y_DIFFICULTY"
const TR_A11Y_SEED := &"A11Y_SEED"
const TR_A11Y_NEW_GAME := &"A11Y_NEW_GAME"
const TR_A11Y_TARGET := &"A11Y_TARGET"
const TR_A11Y_STATUS := &"A11Y_STATUS"
const TR_A11Y_GRID := &"A11Y_GRID"

@onready
var grid_container: GridContainer = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/GridContainer
@onready
var target_label: Label = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/TargetLabel
@onready
var status_label: Label = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/StatusLabel
@onready
var difficulty_option: OptionButton = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/HBoxContainer/DifficultyOption
@onready
var seed_input: LineEdit = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/HBoxContainer/SeedInput
@onready
var new_game_btn: Button = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/HBoxContainer/NewGameBtn
@onready
var sum_indicators: Control = $VBoxContainer/CenterContainer/GamePanel/MarginContainer/VBoxContainer/SumIndicators

var generator: RefCounted
var current_puzzle: Dictionary = {}
var cells: Array[Node] = []
var current_seed: int = -1
var puzzle_start_time: float = 0.0
var puzzle_completed: bool = false

# Sum indicator labels
var row_sums: Array[Label] = []
var col_sums: Array[Label] = []
var diag_sums: Array[Label] = []


func _ready() -> void:
	_apply_locale()
	_apply_theme()
	_setup_accessibility()
	_setup_difficulty_options()
	_setup_sum_indicators()
	_setup_focus_neighbors()
	new_game_btn.pressed.connect(_on_new_game_pressed)

	if GameState.has_active_session():
		_resume_session()
	else:
		_start_new_game()


func _apply_locale() -> void:
	var locale: String = GameState.get_setting("locale", "en")
	TranslationServer.set_locale(locale)


func _apply_theme() -> void:
	var high_contrast: bool = GameState.get_setting("high_contrast", false)
	if high_contrast:
		theme = _get_high_contrast_theme()
	else:
		theme = _get_default_theme()


static func _get_default_theme() -> Theme:
	if not _default_theme:
		_default_theme = load("res://themes/default_theme.tres")
	return _default_theme


static func _get_high_contrast_theme() -> Theme:
	if not _high_contrast_theme:
		_high_contrast_theme = load("res://themes/high_contrast_theme.tres")
	return _high_contrast_theme


func set_high_contrast(enabled: bool) -> void:
	GameState.set_setting("high_contrast", enabled)
	_apply_theme()


func _setup_accessibility() -> void:
	# Godot 4.5+ screen reader support via AccessKit
	difficulty_option.set_accessibility_name(tr(TR_A11Y_DIFFICULTY))
	seed_input.set_accessibility_name(tr(TR_A11Y_SEED))
	new_game_btn.set_accessibility_name(tr(TR_A11Y_NEW_GAME))
	target_label.set_accessibility_name(tr(TR_A11Y_TARGET))
	status_label.set_accessibility_name(tr(TR_A11Y_STATUS))
	grid_container.set_accessibility_name(tr(TR_A11Y_GRID))


func _setup_difficulty_options() -> void:
	difficulty_option.clear()
	difficulty_option.add_item(tr(TR_EASY), PuzzleGen.Difficulty.EASY)
	difficulty_option.add_item(tr(TR_MEDIUM), PuzzleGen.Difficulty.MEDIUM)
	difficulty_option.add_item(tr(TR_HARD), PuzzleGen.Difficulty.HARD)
	difficulty_option.select(1)  # Default to Medium


func _setup_focus_neighbors() -> void:
	# Enable focus on all controls
	difficulty_option.focus_mode = Control.FOCUS_ALL
	seed_input.focus_mode = Control.FOCUS_ALL
	new_game_btn.focus_mode = Control.FOCUS_ALL

	# Set up horizontal focus flow: difficulty -> seed -> new game
	difficulty_option.focus_neighbor_right = seed_input.get_path()
	seed_input.focus_neighbor_left = difficulty_option.get_path()
	seed_input.focus_neighbor_right = new_game_btn.get_path()
	new_game_btn.focus_neighbor_left = seed_input.get_path()

	# Wrap around
	new_game_btn.focus_neighbor_right = difficulty_option.get_path()
	difficulty_option.focus_neighbor_left = new_game_btn.get_path()


func _setup_sum_indicators() -> void:
	# Create labels for row sums (right side)
	for i in 3:
		var lbl := Label.new()
		lbl.name = "Row%d" % i
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(40, 0)
		row_sums.append(lbl)
		sum_indicators.add_child(lbl)

	# Create labels for column sums (bottom)
	for i in 3:
		var lbl := Label.new()
		lbl.name = "Col%d" % i
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(80, 0)
		col_sums.append(lbl)
		sum_indicators.add_child(lbl)

	# Create labels for diagonal sums
	for i in 2:
		var lbl := Label.new()
		lbl.name = "Diag%d" % i
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(60, 0)
		diag_sums.append(lbl)
		sum_indicators.add_child(lbl)


func _start_new_game() -> void:
	puzzle_completed = false
	puzzle_start_time = Time.get_ticks_msec() / 1000.0

	# Parse seed
	var seed_val := -1
	if seed_input.text.length() > 0 and seed_input.text.is_valid_int():
		seed_val = int(seed_input.text)

	current_seed = seed_val
	generator = PuzzleGen.new(seed_val)

	# Generate target sum (multiple of 3, between 12 and 30 for reasonable numbers)
	var base_targets := [12, 15, 18, 21, 24, 27, 30]
	var target_sum: int = base_targets[generator.rng.randi() % base_targets.size()]

	var difficulty: int = difficulty_option.get_selected_id()
	current_puzzle = generator.generate(target_sum, difficulty)

	GameState.record_attempt()
	_setup_grid()
	_update_display()
	_save_current_session()


func _resume_session() -> void:
	puzzle_completed = false
	puzzle_start_time = Time.get_ticks_msec() / 1000.0

	var session: Dictionary = GameState.session
	current_puzzle = session.get("puzzle", {})
	current_seed = session.get("seed", -1)
	var saved_grid: Array = session.get("grid", [])
	var difficulty: int = session.get("difficulty", PuzzleGen.Difficulty.MEDIUM)

	# Restore difficulty selection
	for i in difficulty_option.item_count:
		if difficulty_option.get_item_id(i) == difficulty:
			difficulty_option.select(i)
			break

	# Restore seed input
	if current_seed >= 0:
		seed_input.text = str(current_seed)

	_setup_grid()

	# Restore saved values to editable cells
	if saved_grid.size() == 9:
		for i in 9:
			if cells[i].is_editable and saved_grid[i] > 0:
				cells[i].input.text = str(saved_grid[i])
				cells[i].current_value = saved_grid[i]

	_update_display()


func _setup_grid() -> void:
	# Pool cells: reuse existing, create only if needed
	var need_cells := 9 - cells.size()

	# Create missing cells (first run only)
	for i in need_cells:
		var cell := CellScene.instantiate()
		cell.value_changed.connect(_on_cell_value_changed)
		grid_container.add_child(cell)
		cells.append(cell)

	# Reset all cells with new puzzle data
	for i in 9:
		var cell: Node = cells[i]
		cell.clear_highlight()
		cell.setup(i, current_puzzle.solution[i], not current_puzzle.visible_mask[i])


func _on_cell_value_changed(_cell_index: int, _new_value: int) -> void:
	_update_display()
	if not puzzle_completed:
		_save_current_session()


func _save_current_session() -> void:
	var current_grid: Array[int] = []
	for cell in cells:
		current_grid.append(cell.get_value())

	var difficulty: int = difficulty_option.get_selected_id()
	GameState.save_session(current_puzzle, current_grid, current_seed, difficulty)


func _update_display() -> void:
	var target: int = current_puzzle.target_sum
	target_label.text = tr(TR_TARGET_SUM) % target

	# Get current grid values
	var current_grid: Array[int] = []
	for cell in cells:
		current_grid.append(cell.get_value())

	# Calculate and display sums
	_update_sum_indicators(current_grid, target)

	# Validate and update status
	var all_filled := true
	for val in current_grid:
		if val == 0:
			all_filled = false
			break

	if all_filled:
		var validation: Dictionary = PuzzleGen.validate_solution(current_grid, target)
		if validation.valid:
			status_label.text = tr(TR_STATUS_CORRECT)
			status_label.add_theme_color_override(&"font_color", Color(0.2, 0.8, 0.3))
			if not puzzle_completed:
				puzzle_completed = true
				var elapsed := (Time.get_ticks_msec() / 1000.0) - puzzle_start_time
				var difficulty: int = difficulty_option.get_selected_id()
				GameState.record_completion(difficulty, elapsed)
		else:
			status_label.text = tr(TR_STATUS_WRONG)
			status_label.add_theme_color_override(&"font_color", Color(0.9, 0.4, 0.3))

		# Highlight cells based on validation
		_highlight_cells(validation)
	else:
		status_label.text = tr(TR_STATUS_FILL)
		status_label.remove_theme_color_override(&"font_color")
		for cell in cells:
			cell.clear_highlight()


func _update_sum_indicators(grid: Array[int], target: int) -> void:
	# Row sums
	for row in 3:
		var sum := grid[row * 3] + grid[row * 3 + 1] + grid[row * 3 + 2]
		row_sums[row].text = "%s: %d" % [tr(TR_ROW) % (row + 1), sum]
		_color_sum_label(row_sums[row], sum, target)

	# Column sums
	for col in 3:
		var sum := grid[col] + grid[col + 3] + grid[col + 6]
		col_sums[col].text = "%s: %d" % [tr(TR_COL) % (col + 1), sum]
		_color_sum_label(col_sums[col], sum, target)

	# Diagonal sums
	var diag1 := grid[0] + grid[4] + grid[8]
	var diag2 := grid[2] + grid[4] + grid[6]
	diag_sums[0].text = "%s: %d" % [tr(TR_DIAG_MAIN), diag1]
	diag_sums[1].text = "%s: %d" % [tr(TR_DIAG_ANTI), diag2]
	_color_sum_label(diag_sums[0], diag1, target)
	_color_sum_label(diag_sums[1], diag2, target)


func _color_sum_label(lbl: Label, sum: int, target: int) -> void:
	if sum == target:
		lbl.add_theme_color_override("font_color", Color(0.2, 0.8, 0.3))
	elif sum > target:
		lbl.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3))
	else:
		lbl.remove_theme_color_override("font_color")


func _highlight_cells(_validation: Dictionary) -> void:
	for cell in cells:
		if not cell.is_editable:
			continue
		var is_correct: bool = cell.get_value() == cell.correct_value
		cell.set_highlight(is_correct)


func _on_new_game_pressed() -> void:
	_start_new_game()


## Load a puzzle from a PuzzleConfig resource file.
func load_puzzle_from_resource(config: Resource) -> void:
	if not config or not config.is_valid():
		push_warning("Invalid PuzzleConfig resource")
		return

	puzzle_completed = false
	puzzle_start_time = Time.get_ticks_msec() / 1000.0
	current_seed = -1
	current_puzzle = config.to_puzzle_dict()

	# Update difficulty selection to match
	for i in difficulty_option.item_count:
		if difficulty_option.get_item_id(i) == current_puzzle.difficulty:
			difficulty_option.select(i)
			break

	seed_input.text = ""
	GameState.record_attempt()
	_setup_grid()
	_update_display()
	_save_current_session()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
